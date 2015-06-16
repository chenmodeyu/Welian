//
//  ChatRoomUserListViewController.m
//  Welian
//
//  Created by weLian on 15/6/15.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ChatRoomUserListViewController.h"
#import "UserInfoViewController.h"

#import "MJRefresh.h"
#import "ActivityUserViewCell.h"
#import "NotstringView.h"

@interface ChatRoomUserListViewController ()

@property (strong,nonatomic) ChatRoomInfo *chatRoomInfo;
@property (strong,nonatomic) NSMutableArray *datasource;

@property (assign,nonatomic) NSInteger pageIndex;
@property (assign,nonatomic) NSInteger pageSize;
@property (assign,nonatomic) NSInteger totalNum;
//@property (assign,nonatomic) NSInteger allPages;

@property (strong,nonatomic) NotstringView *noDataNotView;//提醒

@end

@implementation ChatRoomUserListViewController

- (void)dealloc
{
    _chatRoomInfo = nil;
    _datasource = nil;
}

- (NotstringView *)noDataNotView
{
    if (!_noDataNotView) {
        _noDataNotView = [[NotstringView alloc] initWithFrame:self.tableView.frame withTitleStr:@"该聊天室暂无在线人员！"];
    }
    return _noDataNotView;
}

- (instancetype)initWithStyle:(UITableViewStyle)style ChatRoomInfo:(ChatRoomInfo *)chatRoomInfo
{
    self = [super init];
    if (self) {
        self.chatRoomInfo = chatRoomInfo;
        self.title = [NSString stringWithFormat:@"聊天室成员%@",_chatRoomInfo.joinUserCount.integerValue > 0 ? [NSString stringWithFormat:@"(%@)",_chatRoomInfo.joinUserCount] : @""];
        self.pageIndex = 1;
        self.pageSize = KCellConut;
        self.datasource = [NSMutableArray array];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //显示导航条
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //隐藏tableiView分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //下拉刷新
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(loadReflshData)];
    //上提加载更多
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataArray)];
    // 隐藏当前的上拉刷新控件
    self.tableView.footer.hidden = YES;
    //自动下拉刷新数据
    [self.tableView.header beginRefreshing];
    //加载数据
//    [self initData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //微信联系人
    static NSString *cellIdentifier = @"Chat_Room_UserList_Cell";
    
    ActivityUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ActivityUserViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.indexPath = indexPath;
    cell.baseUser = _datasource[indexPath.row];
    WEAKSELF
    [cell setAddFriendBlock:^(NSIndexPath *indexPath){
        [weakSelf addFriendWithIndex:indexPath];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IBaseUserM *baseUser = _datasource[indexPath.row];
    //    NSDictionary *info = _datasource[indexPath.row];
    //    NSString *uid = info[@"uid"];
    //friendship /**  好友关系，1好友，2好友的好友,-1自己，0没关系   */
    //    NSString *friendship = info[@"friendship"];
    if(baseUser.uid != nil){
        //        IBaseUserM *baseUser = [[IBaseUserM alloc] init];
        //        baseUser.name = info[@"name"];
        //        baseUser.uid = info[@"uid"];
        //        baseUser.friendship = @([info[@"friendship"] integerValue]);
        //系统联系人
        //        UserInfoBasicVC *userInfoVC = [[UserInfoBasicVC alloc] initWithStyle:UITableViewStyleGrouped andUsermode:baseUser isAsk:NO];
        
        UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] initWithBaseUserM:baseUser OperateType:nil HidRightBtn:NO];
        [self.navigationController pushViewController:userInfoVC animated:YES];
        
        //添加好友成功
        [userInfoVC setAddFriendBlock:^(){
            NSMutableDictionary *infoDic =  [NSMutableDictionary dictionaryWithDictionary:_datasource[indexPath.row]];
            //重置好友关系
            [infoDic setValue:@"4" forKey:@"friendship"];
            //改变数组，刷新列表
            [self.datasource replaceObjectAtIndex:indexPath.row withObject:infoDic];
            //刷新列表
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - Private
//获取数据
- (void)initData
{
    [WeLianClient getChatroomMembersWithId:_chatRoomInfo.chatroomid
                                      Page:@(_pageIndex)
                                      Size:@(_pageSize)
                                   Success:^(id resultInfo) {
                                       //隐藏加载更多动画
                                       [self.tableView.header endRefreshing];
                                       [self.tableView.footer endRefreshing];
                                       
                                       self.totalNum = [resultInfo[@"total"] integerValue];
                                       self.chatRoomInfo = [_chatRoomInfo updateJoinUserCount:@(_totalNum)];
                                       
//                                       self.title = [NSString stringWithFormat:@"聊天室成员(%@)",_chatRoomInfo.joinUserCount];
                                       self.title = [NSString stringWithFormat:@"聊天室成员%@",_chatRoomInfo.joinUserCount.integerValue > 0 ? [NSString stringWithFormat:@"(%@)",_chatRoomInfo.joinUserCount] : @""];
                                       
                                       ///通知刷新列表 刷新聊天室人数
                                       [KNSNotification postNotificationName:@"NeedRloadChatRoomList" object:nil];
                                       
                                       NSArray *result = resultInfo[@"members"];
                                       NSArray *records = [IBaseUserM objectsWithInfo:result];
                                       
                                       if (records.count) {
                                           [self.datasource addObjectsFromArray:records];
                                       }
                                       
                                       //设置是否可以下拉刷新
                                       if ([records count] != _pageSize) {
                                           self.tableView.footer.hidden = YES;
                                       }else{
                                           _pageIndex++;
                                           self.tableView.footer.hidden = NO;
                                       }
                                       
                                       if (_datasource.count > 0) {
                                           [_noDataNotView removeFromSuperview];
                                       }else{
                                           [self.tableView addSubview:self.noDataNotView];
                                           [self.tableView sendSubviewToBack:self.noDataNotView];
                                       }
                                       
                                       [self.tableView reloadData];
                                   } Failed:^(NSError *error) {
                                       //隐藏加载更多动画
                                       [self.tableView.header endRefreshing];
                                       [self.tableView.footer endRefreshing];
                                   }];
}

- (void)loadReflshData
{
    self.pageIndex = 1;
    self.datasource = [NSMutableArray array];
    [self initData];
}

//加载更多数据
- (void)loadMoreDataArray
{
    [self initData];
}

- (void)addFriendWithIndex:(NSIndexPath *)indexPath
{
    //friendship /**  好友关系，1好友，2好友的好友,-1自己，0没关系   */
    IBaseUserM *baseUser = _datasource[indexPath.row];
    
    if(baseUser.uid != nil && baseUser.friendship.integerValue != 1){
        //添加
        DLog(@"添加好友");
        NSString *wlname = baseUser.wlname.length == 0 ? baseUser.name : baseUser.wlname;
        
        //添加好友，发送添加成功，状态变成待验证
        LogInUser *loginUser = [LogInUser getCurrentLoginUser];
        if (!loginUser) {
            return;
        }
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"好友验证" message:[NSString stringWithFormat:@"发送至好友：%@",wlname]];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[alert textFieldAtIndex:0] setText:[NSString stringWithFormat:@"我是%@的%@",loginUser.company,loginUser.position]];
        [alert bk_addButtonWithTitle:@"取消" handler:nil];
        [alert bk_addButtonWithTitle:@"发送" handler:^{
            //发送好友请求
            [WLHUDView showHUDWithStr:@"发送中..." dim:NO];
            [WeLianClient requestAddFriendWithID:baseUser.uid
                                         Message:[alert textFieldAtIndex:0].text
                                         Success:^(id resultInfo) {
                                             //                                             NSMutableDictionary *infoDic =  [NSMutableDictionary dictionaryWithDictionary:_datasource[indexPath.row]];
                                             //                                             [infoDic setValue:@"4" forKey:@"friendship"];
                                             //重置好友关系
                                             IBaseUserM *newUser = _datasource[indexPath.row];
                                             newUser.friendship = @(4);
                                             
                                             //                //发送邀请成功，修改状态，刷新列表
                                             //                NeedAddUser *addUser = [needAddUser updateFriendShip:4];
                                             //改变数组，刷新列表
                                             [self.datasource replaceObjectAtIndex:indexPath.row withObject:newUser];
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
}

@end
