//
//  WLFriendsRequestListController.m
//  Welian
//
//  Created by dong on 15/6/15.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "WLFriendsRequestListController.h"
#import "NewFriendViewCell.h"
#import "NotstringView.h"
#import "UserInfoViewController.h"

@interface WLFriendsRequestListController ()
@property (strong,nonatomic) NSArray *datasource;
@property (strong,nonatomic) NotstringView *notHasDataView;//无消息提醒
@end

@implementation WLFriendsRequestListController

//没有聊天记录提醒
- (NotstringView *)notHasDataView
{
    if (!_notHasDataView) {
        _notHasDataView = [[NotstringView alloc] initWithFrame:CGRectMake(0.f, ViewCtrlTopBarHeight, self.view.width, self.view.height - ViewCtrlTopBarHeight) withTitStr:@"没有消息记录" andImageName:@"remind_big_nostring"];
    }
    return _notHasDataView;
}

//获取好友消息
- (void)loadNewFriendData
{
    //加载数据
    self.datasource = [NSMutableArray arrayWithArray:[[LogInUser getCurrentLoginUser] allMyNewFriends]];
    if (_datasource.count > 0) {
        self.notHasDataView.hidden = YES;
    }else{
        self.notHasDataView.hidden = NO;
    }
    [self.tableView reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setTableFooterView:[UIView new]];
    [self loadNewFriendData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewFriendUser *friendUser = _datasource[indexPath.row];
    CGFloat cellheight = [NewFriendViewCell configureWithName:friendUser.name message:friendUser.msg];
    return cellheight>60.0f?cellheight:60.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CELL_Identifier = @"New_Friend_Cell";
    NewFriendViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_Identifier];
    if (!cell) {
        cell = [[NewFriendViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_Identifier];
    }
    cell.indexPath = indexPath;
    cell.nFriendUser = _datasource[indexPath.row];
    WEAKSELF
    [cell setNewFriendBlock:^(FriendOperateType type,NewFriendUser *newFriendUser,NSIndexPath *indexPath){
        [weakSelf newFriendOperate:type newFriendUser:newFriendUser indexPath:indexPath];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewFriendUser *friendM = _datasource[indexPath.row];
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] initWithBaseUserM:(IBaseUserM *)friendM OperateType:friendM.operateType HidRightBtn:NO];
    WEAKSELF
    userInfoVC.acceptFriendBlock = ^(){
        [weakSelf newFriendOperate:FriendOperateTypeAccept newFriendUser:friendM indexPath:indexPath];
    };
    [self.navigationController pushViewController:userInfoVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
            NewFriendUser *friendM = _datasource[indexPath.row];
                //删除本地数据库数据
                [friendM MR_deleteEntity];
                [[friendM managedObjectContext] MR_saveToPersistentStoreAndWait];
    }
}


/**
 *  新的好友关系操作
 *
 *  @param type          按钮操作类型
 *  @param newFriendUser 新的好友对象
 *  @param indexPath     对应的tableview
 */
- (void)newFriendOperate:(FriendOperateType)type newFriendUser:(NewFriendUser *)newFriendUser indexPath:(NSIndexPath *)indexPath
{
    if (type == FriendOperateTypeAdd) {
        //添加好友，发送添加成功，状态变成待验证
        LogInUser *loginUser = [LogInUser getCurrentLoginUser];
        if (!loginUser) {
            return;
        }
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"好友验证" message:[NSString stringWithFormat:@"发送至好友：%@",newFriendUser.name]];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[alert textFieldAtIndex:0] setText:[NSString stringWithFormat:@"我是%@的%@",loginUser.company,loginUser.position]];
        [alert bk_addButtonWithTitle:@"取消" handler:nil];
        [alert bk_addButtonWithTitle:@"发送" handler:^{
            //发送好友请求
            [WLHUDView showHUDWithStr:@"发送中..." dim:NO];
            [WeLianClient requestAddFriendWithID:newFriendUser.uid
                                         Message:[alert textFieldAtIndex:0].text
                                         Success:^(id resultInfo) {
                                             //发送邀请成功，修改状态，刷新列表
                                             NewFriendUser *nowFriendUser = [newFriendUser updateOperateType:FriendOperateTypeWait];
                                             
                                             //改变数组，刷新列表
                                             NSMutableArray *allDatas = [NSMutableArray arrayWithArray:_datasource];
                                             [allDatas replaceObjectAtIndex:indexPath.row withObject:nowFriendUser];
                                             self.datasource = [NSArray arrayWithArray:allDatas];
                                             //刷新列表
                                             [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                             [WLHUDView showSuccessHUD:@"好友请求已发送"];
                                         } Failed:^(NSError *error) {
                                             if (error) {
                                                 [WLHUDView showErrorHUD:error.localizedDescription];
                                             }else{
                                                 [WLHUDView showErrorHUD:@"发送失败，请重试"];
                                             }
                                         }];
        }];
        [alert show];
    }
    
    if (type == FriendOperateTypeAccept) {
        //接受好友请求
        [WLHUDView showHUDWithStr:@"添加中..." dim:NO];
        [WeLianClient confirmAddFriendWithID:newFriendUser.uid
                                     Success:^(id resultInfo) {
                                         [newFriendUser setIsAgree:@(1)];
                                         //更新好友列表数据库
                                         MyFriendUser *myFriendUser = [MyFriendUser createWithNewFriendUser:newFriendUser];
                                         
                                         //发送邀请成功，修改状态，刷新列表
                                         NewFriendUser *nowFriendUser = [newFriendUser updateOperateType:FriendOperateTypeAdded];
                                         //            if (self.userBasicVC) {
                                         //                [self.userBasicVC addSucceed];
                                         //            }
                                         //改变数组，刷新列表
                                         NSMutableArray *allDatas = [NSMutableArray arrayWithArray:_datasource];
                                         [allDatas replaceObjectAtIndex:indexPath.row withObject:nowFriendUser];
                                         
                                         self.datasource = [NSArray arrayWithArray:allDatas];
                                         [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                         
                                         //刷新好友列表
                                         [KNSNotification postNotificationName:KupdataMyAllFriends object:self];
                                         
                                         //通知接受好友请求
                                         [KNSNotification postNotificationName:[NSString stringWithFormat:kAccepteFriend,newFriendUser.uid] object:nil];
                                         
                                         //接受后，本地创建一条消息
                                         //本地创建好像
                                         [ChatMessage createChatMessageForAddFriend:myFriendUser];
                                         
                                         [WLHUDView showSuccessHUD:[NSString stringWithFormat:@"你已添加%@为好友",newFriendUser.name]];
                                     } Failed:^(NSError *error) {
                                         if (error) {
                                             [WLHUDView showErrorHUD:error.localizedDescription];
                                         }else{
                                             [WLHUDView showErrorHUD:@"添加失败，请重试"];
                                         }
                                     }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
