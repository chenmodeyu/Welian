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
    [KNSNotification removeObserver:self];
}

- (instancetype)initWithChatRoomInfo:(ChatRoomInfo *)chatRoomInfo
{
    self = [super init];
    if (self) {
        self.chatRoomInfo = chatRoomInfo;
        self.title = [NSString stringWithFormat:@"%@%@",_chatRoomInfo.title,_chatRoomInfo.joinUserCount.integerValue > 0 ? [NSString stringWithFormat:@"(%@)",_chatRoomInfo.joinUserCount] : @""];
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
    [KNSNotification addObserver:self selector:@selector(refreshDataAndUI) name:@"NeedRloadChatRoomList" object:nil];
    
    UIBarButtonItem *userItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_member"]
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self action:@selector(chatRoomUserItemClicked)];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_more"]
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self action:@selector(shareItemClicked)];
    //添加创建活动按钮
    if (_chatRoomInfo.role.boolValue || _chatRoomInfo.shareUrl.length > 0) {
        self.navigationItem.rightBarButtonItems = @[moreItem,userItem];
    }else{
        self.navigationItem.rightBarButtonItems = @[userItem];
    }
}

#pragma mark - Private
- (void)refreshDataAndUI
{
    self.chatRoomInfo = [ChatRoomInfo getChatRoomInfoWithId:_chatRoomInfo.chatroomid];
    self.title = [NSString stringWithFormat:@"%@%@",_chatRoomInfo.title,_chatRoomInfo.joinUserCount.integerValue > 0 ? [NSString stringWithFormat:@"(%@)",_chatRoomInfo.joinUserCount] : @""];
}

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
    //自己创建的聊天室可以设置，别的可以删除可以退出
    NSArray *buttons = _chatRoomInfo.role.boolValue ? @[@(ShareTypeSetting),@(ShareTypeDelete)] : nil;
    WEAKSELF
    NSArray *shareArray = _chatRoomInfo.shareUrl.length > 0 ? @[@(ShareTypeWeixinFriend),@(ShareTypeWeixinCircle)] : nil;
    WLActivityView *wlActivity = [[WLActivityView alloc] initWithOneSectionArray:buttons andTwoArray:shareArray];
    wlActivity.wlShareBlock = ^(ShareType type){
        NSString *desc = [NSString stringWithFormat:@"我在[%@]聊天室，口令：%@，欢迎加入…",_chatRoomInfo.title,_chatRoomInfo.code];
        UIImage *shareImage = [UIImage imageNamed:@"share_chatroom_logo"];
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
                [weakSelf deleteChatRoomAlert];
            }
                break;
            case ShareTypeSetting:
            {
                //设置
                [weakSelf toChatRoomSetting];
            }
                break;
            default:
                break;
        }
    };
    [wlActivity show];
}

//设置
- (void)toChatRoomSetting
{
    ChatRoomSettingViewController *roomSettingVC = [[ChatRoomSettingViewController alloc] initWithRoomType:ChatRoomSetTypeChange ChatRoomInfo:_chatRoomInfo];
    [self.navigationController pushViewController:roomSettingVC animated:YES];
}

//删除聊天室
- (void)deleteChatRoomAlert
{
    [UIAlertView bk_showAlertViewWithTitle:@""
                                   message:_chatRoomInfo.role.boolValue ? @"确认删除并解散当前聊天室？" : @"确认删除并退出当前聊天室？"
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@[@"删除"]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if (buttonIndex == 0) {
                                           return ;
                                       }else{
                                           //删除项目
                                           [self deleteChatRoom];
                                       }
                                   }];
}

//删除聊天室
- (void)deleteChatRoom
{
    //删除项目
    [WLHUDView showHUDWithStr:@"删除中..." dim:NO];
    [WeLianClient chatroomQuitWithId:_chatRoomInfo.chatroomid
                             Success:^(id resultInfo) {
                                 [WLHUDView hiddenHud];
                                 
                                 //本地删除
                                 [_chatRoomInfo deleteChatRoomInfo];
                                 
                                 ///通知刷新列表
                                 [KNSNotification postNotificationName:@"NeedRloadChatRoomList" object:nil];
                                 [UIAlertView bk_showAlertViewWithTitle:@""
                                                                message:_chatRoomInfo.role.boolValue ? @"删除并解散聊天室成功！" : @"删除并退出聊天室成功！"
                                                      cancelButtonTitle:@"知道了"
                                                      otherButtonTitles:nil
                                                                handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                    [self.navigationController popViewControllerAnimated:YES];
                                                                }];
                             } Failed:^(NSError *error) {
                                 if (error) {
                                     [WLHUDView showErrorHUD:error.localizedDescription];
                                 }else{
                                     [WLHUDView showErrorHUD:@"删除或解散聊天室失败，请重试！"];
                                 }
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
        userMode.friendship = @(-1);
    }else{
        //好友头像
        MyFriendUser *friendUser = [loginUser getMyfriendUserWithUid:@(userId.integerValue)];
        if (friendUser) {
            userMode = [friendUser toIBaseUserModelInfo];
        }else{
            userMode.uid = @(userId.integerValue);
        }
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
