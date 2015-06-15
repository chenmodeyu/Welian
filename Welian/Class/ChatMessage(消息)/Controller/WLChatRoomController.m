//
//  WLChatRoomController.m
//  Welian
//
//  Created by dong on 15/6/12.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "WLChatRoomController.h"
#import "UserInfoViewController.h"
#import "ChatRoomSettingViewController.h"
#import "ChatRoomUserListViewController.h"

#import "ShareFriendsController.h"
#import "PublishStatusController.h"
#import "NavViewController.h"

#import "WLActivityView.h"
#import "ShareEngine.h"

@interface WLChatRoomController ()

@property (strong,nonatomic) ChatRoomInfo *chatRoomInfo;

@end

@implementation WLChatRoomController

- (void)dealloc
{
    _chatRoomInfo = nil;
}

- (NSString *)title
{
    return _chatRoomInfo.title;
}

- (instancetype)initWithChatRoomInfo:(ChatRoomInfo *)chatRoomInfo
{
    self = [super init];
    if (self) {
        self.chatRoomInfo = chatRoomInfo;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = _chatRoomInfo.title;
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *userItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_member"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(chatRoomUserItemClicked)];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_more"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(shareItemClicked)];
    
    //添加创建活动按钮
    if (_chatRoomInfo.role.boolValue || _chatRoomInfo.shareUrl.length > 0) {
        self.navigationItem.rightBarButtonItems = @[moreItem,userItem];
    }else{
        self.navigationItem.rightBarButtonItems = @[userItem];
    }
    
}

#pragma mark - Private
//查看聊天室人员
- (void)chatRoomUserItemClicked
{
    //隐藏键盘
    [[self.view findFirstResponder] resignFirstResponder];
    
    ChatRoomUserListViewController *chatUserVC = [[ChatRoomUserListViewController alloc] initWithStyle:UITableViewStylePlain ChatRoomInfo:_chatRoomInfo];
    [self.navigationController pushViewController:chatUserVC animated:YES];
}

//更多操作按钮
- (void)shareItemClicked
{
    //隐藏键盘
    [[self.view findFirstResponder] resignFirstResponder];
    
    NSArray *buttons = nil;
    //自己创建的聊天室
    if (_chatRoomInfo.role.boolValue) {
        buttons = @[@(ShareTypeSetting),@(ShareTypeDelete)];
    }
//    WEAKSELF
    NSArray *shareArray = _chatRoomInfo.shareUrl.length > 0 ? @[@(ShareTypeWeixinFriend),@(ShareTypeWeixinCircle)] : nil;
    WLActivityView *wlActivity = [[WLActivityView alloc] initWithOneSectionArray:buttons andTwoArray:shareArray];
    wlActivity.wlShareBlock = ^(ShareType type){
        NSString *desc = [NSString stringWithFormat:@"我在[%@]聊天室，口令：%@，欢迎加入…",_chatRoomInfo.title,_chatRoomInfo.code];
        UIImage *shareImage = [UIImage imageNamed:@"home_repost_xiangmu"];
        NSString *title = @"邀请您加入微链聊天室";
        switch (type) {
//            case ShareTypeWLFriend:
//            {
//                ShareFriendsController *shareFVC = [[ShareFriendsController alloc] init];
////                shareFVC.cardM = newCardM;
//                NavViewController *navShareFVC = [[NavViewController alloc] initWithRootViewController:shareFVC];
//                [self presentViewController:navShareFVC animated:YES completion:nil];
//                //回调发送成功
//                //                [shareFVC setShareSuccessBlock:^(void){
//                //                    [WLHUDView showSuccessHUD:@"分享成功！"];
//                //                }];
//                WEAKSELF
//                [shareFVC setSelectFriendBlock:^(MyFriendUser *friendUser){
//                    [weakSelf shareToWeLianFriendWithCardStatuModel:newCardM friend:friendUser];
//                }];
//            }
//                break;
//            case ShareTypeWLCircle:
//            {
//                PublishStatusController *publishShareVC = [[PublishStatusController alloc] initWithType:PublishTypeForward];
////                publishShareVC.statusCard = newCardM;
//                NavViewController *navShareFVC = [[NavViewController alloc] initWithRootViewController:publishShareVC];
//                [self presentViewController:navShareFVC animated:YES completion:nil];
//                //回调发送成功
//                [publishShareVC setPublishBlock:^(void){
//                    [WLHUDView showSuccessHUD:@"分享成功！"];
//                }];
//                
//            }
//                break;
            case ShareTypeWeixinFriend:
            {
                
                [[ShareEngine sharedShareEngine] sendWeChatMessage:title
                                                    andDescription:desc
                                                           WithUrl:_chatRoomInfo.shareUrl
                                                          andImage:shareImage WithScene:weChat];
            }
                break;
            case ShareTypeWeixinCircle:
            {
                [[ShareEngine sharedShareEngine] sendWeChatMessage:desc
                                                    andDescription:@""
                                                           WithUrl:_chatRoomInfo.shareUrl
                                                          andImage:shareImage WithScene:weChatFriend];
            }
                break;
            case ShareTypeDelete:
            {
                //删除
                [UIAlertView bk_showAlertViewWithTitle:@""
                                               message:@"确认删除当前聊天室？"
                                     cancelButtonTitle:@"取消"
                                     otherButtonTitles:@[@"删除"]
                                               handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                   if (buttonIndex == 0) {
                                                       return ;
                                                   }else{
                                                       [self deleteChatRoom];
                                                   }
                                               }];
            }
                break;
            case ShareTypeSetting:
            {
                //设置
                ChatRoomSettingViewController *roomSettingVC = [[ChatRoomSettingViewController alloc] initWithRoomType:ChatRoomSetTypeChange ChatRoomInfo:_chatRoomInfo];
                [self.navigationController pushViewController:roomSettingVC animated:YES];
            }
                break;
            default:
                break;
        }
    };
    [wlActivity show];
}

- (void)deleteChatRoom
{
    //删除项目
    [WeLianClient chatroomQuitWithId:_chatRoomInfo.chatroomid
                             Success:^(id resultInfo) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     
                                     //本地删除
                                     [_chatRoomInfo MR_deleteEntity];
                                     ///通知刷新列表
                                     [KNSNotification postNotificationName:@"NeedRloadChatRoomList" object:nil];
                                     [self.navigationController popViewControllerAnimated:YES];
                                 });
                             } Failed:^(NSError *error) {
                                 
                             }];
}

#pragma mark override
/**
 *  点击头像事件
 *
 *  @param userId 用户的ID
 */
- (void)didTapCellPortrait:(NSString *)userId
{
    IBaseUserM *userMode = [[IBaseUserM alloc] init];
    //自己发送
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    if (userId.integerValue == loginUser.uid.integerValue) {
        userMode = [loginUser toIBaseUserModelInfo];
    }else{
        //好友头像
        MyFriendUser *friendUser = [loginUser getMyfriendUserWithUid:@(userId.integerValue)];
        userMode = [friendUser toIBaseUserModelInfo];
    }
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] initWithBaseUserM:userMode OperateType:userMode.friendship.integerValue == 1 ? @(10) : nil HidRightBtn:NO];
    [self.navigationController pushViewController:userInfoVC animated:YES];
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
