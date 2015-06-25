//
//  ChatListViewController.m
//  Welian
//
//  Created by weLian on 15/6/10.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ChatListViewController.h"
#import "WLChatViewController.h"
#import "RCDChatListCell.h"
#import "RCDUserInfo.h"
#import "ChatRoomListController.h"
#import "ChatRoomHeaderView.h"
#import "AppDelegate.h"
#import "WLFriendsRequestListController.h"
#import "WLFriendRequestCell.h"
#import "CustomCardMessage.h"
#import "MainViewController.h"
#import "ChatMessageController.h"

@interface ChatListViewController ()

@end

static NSString *chatroomcellid = @"chatroomcellid";
static NSString *chatNewFirendcellid = @"chatNewFirendcellid";

@implementation ChatListViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[MainViewController sharedMainViewController] updateChatMessageBadge];
    //显示导航条
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [NSUserDefaults removeObjectForKey:@"Chat_Share_Friend_Uid"];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}


- (NSString *)title
{
    return @"消息";
}

/**
 *  此处使用storyboard初始化，代码初始化当前类时*****必须要设置会话类型和聚合类型*****
 */
-(id)init
{
    self = [super init];
    if (self) {
        //如果是从好友列表进入聊天，首页变换
        [KNSNotification addObserver:self selector:@selector(chatFromUserInfo:) name:kChatFromUserInfo object:nil];
        //设置要显示的会话类型
        [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE)]];
        
        //聚合会话类型
        [self setCollectionConversationType:@[@(ConversationType_DISCUSSION)]];
    }
    return self;
}

//从用户信息中发送消息
- (void)chatFromUserInfo:(NSNotification *)notification
{
    //切换首页Tap
    [KNSNotification postNotificationName:kChangeTapToChatList object:nil];
    
    //切换到聊天列表也没
    NSNumber *uid = @([[[notification userInfo] objectForKey:@"uid"] integerValue]);
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    MyFriendUser *user = [loginUser getMyfriendUserWithUid:uid];
    WLChatViewController *chatVC = [[WLChatViewController alloc] init];
    chatVC.targetId                      = user.uid.stringValue;
    chatVC.userName                    = user.name;
    chatVC.conversationType              = ConversationType_PRIVATE;
    chatVC.title                         = user.name;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"历史消息" style:UIBarButtonItemStyleBordered target:self action:@selector(historyMessage)];
    self.conversationListTableView.tableFooterView = [UIView new];
    [self.conversationListTableView registerClass:[ChatRoomHeaderView class] forCellReuseIdentifier:chatroomcellid];
    [self.conversationListTableView registerClass:[WLFriendRequestCell class] forCellReuseIdentifier:chatNewFirendcellid];
}

#pragma mark - 历史消息
- (void)historyMessage
{
    ChatMessageController *historyMVC = [[ChatMessageController alloc] initWithStyle:UITableViewStylePlain];
    historyMVC.title = @"历史消息";
    [self.navigationController pushViewController:historyMVC animated:YES];
}

/**
 *  点击进入会话界面
 *
 *  @param conversationModelType 会话类型
 *  @param model                 会话数据
 *  @param indexPath             indexPath description
 */
-(void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath
{
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        WLChatViewController *_conversationVC = [[WLChatViewController alloc]init];
        _conversationVC.conversationType = model.conversationType;
        _conversationVC.targetId = model.targetId;
        _conversationVC.userName = model.conversationTitle;
        _conversationVC.title = model.conversationTitle;
        _conversationVC.conversation = model;
        [self.navigationController pushViewController:_conversationVC animated:YES];
    }
    
    //聚合会话类型，此处自定设置。
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {
        WLFriendsRequestListController *friendRequestVC = [[WLFriendsRequestListController alloc] init];
        [self.navigationController pushViewController:friendRequestVC animated:YES];
    }
    
    //自定义会话类型
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
        RCConversationModel *model = self.conversationListDataSource[indexPath.row];
        if ([model.objectName isEqualToString:@"ChatRoomHeader"]) {
            ChatRoomListController *chatRoomListVC = [[ChatRoomListController alloc] init];
            [self.navigationController pushViewController:chatRoomListVC animated:YES];

        }else if([model.objectName isEqualToString:@"friendCell"]){
            WLFriendsRequestListController *friendRequestVC = [[WLFriendsRequestListController alloc] init];
            [self.navigationController pushViewController:friendRequestVC animated:YES];
        }
    }
}

//*********************插入自定义Cell*********************//
//插入自定义会话model
-(NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource
{
    RCConversationModel *model = [[RCConversationModel alloc] init:RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION  exntend:nil];
    model.isTop = YES;
    model.objectName = @"ChatRoomHeader";
    [dataSource insertObject:model atIndex:0];
    
    RCConversationModel *friendmodel = [[RCConversationModel alloc] init:RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION  exntend:nil];
    friendmodel.isTop = YES;
    friendmodel.objectName = @"friendCell";
    [dataSource insertObject:friendmodel atIndex:0];
    
    for (RCConversationModel *rcmodel in dataSource) {
        DLog(@"%@",[self formatterTimeText:rcmodel.receivedTime/1000]);
    }
    return dataSource;
}


- (NSString *)formatterTimeText:(NSTimeInterval)secs
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *send = [NSDate dateWithTimeIntervalSince1970:secs];
    return [fmt stringFromDate:send];
}


- (void)notifyUpdateUnreadMessageCount {
    [[MainViewController sharedMainViewController] updateChatMessageBadge];
}

////左滑删除
//-(void)rcConversationListTableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self.conversationListDataSource removeObjectAtIndex:indexPath.row];
//    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [[MainViewController sharedMainViewController] updateChatMessageBadge];
//}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleDelete;//默认没有编辑风格
    if (indexPath.row==0||indexPath.row == 1) {
        result = UITableViewCellEditingStyleNone;//默认没有编辑风格
    }
    return result;
}


//高度
-(CGFloat)rcConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    if ([model.objectName isEqualToString:@"ChatRoomHeader"]) {
        return 80.0f;
    }else if ([model.objectName isEqualToString:@"friendCell"]){
        return 65.0f;
    }
    return 0.0f;
}

//自定义cell
-(RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
        if ([model.objectName isEqualToString:@"ChatRoomHeader"]) {
            ChatRoomHeaderView *cell = [tableView dequeueReusableCellWithIdentifier:chatroomcellid];
            return cell;
        }else if ([model.objectName isEqualToString:@"friendCell"]){
            WLFriendRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:chatNewFirendcellid];
            [cell upNewFriendsBadge];
            return cell;
        }else if ([model.lastestMessage isMemberOfClass:[RCContactNotificationMessage class]]) {
            
            __block NSString *userName    = nil;
            __block NSString *portraitUri = nil;
            //此处需要添加根据userid来获取用户信息的逻辑，extend字段不存在于DB中，当数据来自db时没有extend字段内容，只有userid
            if (nil == model.extend) {
                RCContactNotificationMessage *_contactNotificationMsg = (RCContactNotificationMessage *)model.lastestMessage;
                NSDictionary *_cache_userinfo = [[NSUserDefaults standardUserDefaults]objectForKey:_contactNotificationMsg.sourceUserId];
                if (_cache_userinfo) {
                    userName = _cache_userinfo[@"username"];
                    portraitUri = _cache_userinfo[@"portraitUri"];
                }
            }else{
                RCDUserInfo *user = (RCDUserInfo *)model.extend;
                userName    = user.userName;
                portraitUri = user.portraitUri;
            }
            RCDChatListCell *cell = [[RCDChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
            cell.lblDetail.text =[NSString stringWithFormat:@"%@请求添加你为好友",userName];
            [cell.ivAva setImage:[UIImage imageNamed:@"system_notice"]];
            return cell;
        }
    }
    return nil;
}

//*********************插入自定义Cell*********************//
#pragma mark - 收到消息监听
-(void)didReceiveMessageNotification:(NSNotification *)notification
{
    __weak typeof(&*self) blockSelf_ = self;
    //处理好友请求
    RCMessage *message = notification.object;
    if ([message.content isMemberOfClass:[RCContactNotificationMessage class]]) {
        RCContactNotificationMessage *_contactNotificationMsg = (RCContactNotificationMessage *)message.content;

        NSMutableDictionary *newFriendMessage = [NSMutableDictionary dictionaryWithDictionary:[[_contactNotificationMsg.extra jsonObject] objectForKey:@"data"]];
        [newFriendMessage setObject:[[_contactNotificationMsg.extra jsonObject] objectForKey:@"type"] forKey:@"type"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            AppDelegate *delet = (AppDelegate *)[UIApplication sharedApplication].delegate;
            NewFriendUser *newFM = [delet getNewFriendMessage:newFriendMessage LoginUserId:nil];
            if (!newFM) {
                return;
            }
            NSIndexPath *indexP = [NSIndexPath indexPathForRow:0 inSection:0];
            WLFriendRequestCell *cell = (WLFriendRequestCell *)[self.conversationListTableView cellForRowAtIndexPath:indexP];
            [cell upNewFriendsBadge];
//                [[MainViewController sharedMainViewController] updateChatMessageBadge];
        });
//        [self.conversationListTableView reloadRowsAtIndexPaths:@[indexP] withRowAnimation:UITableViewRowAnimationFade];
//        RCDUserInfo *rcduserinfo_ = [RCDUserInfo new];
//        rcduserinfo_.userName = newFM.name;
//        rcduserinfo_.userId = newFM.uid.stringValue;
//        rcduserinfo_.portraitUri = newFM.avatar;//头像
//        
//          RCConversationModel *customModel = [RCConversationModel new];
//          customModel.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
//          customModel.extend = rcduserinfo_;
//          customModel.senderUserId = message.senderUserId;
//          customModel.lastestMessage = _contactNotificationMsg;
//          
//          //local cache for userInfo
//          NSDictionary *userinfoDic = @{@"username": rcduserinfo_.userName,
//                                        @"portraitUri":rcduserinfo_.portraitUri
//                                        };
//          [[NSUserDefaults standardUserDefaults]setObject:userinfoDic forKey:_contactNotificationMsg.sourceUserId];
//          [[NSUserDefaults standardUserDefaults]synchronize];
//          
//          dispatch_async(dispatch_get_main_queue(), ^{
//              
//              //调用父类刷新未读消息数
//              [blockSelf_ refreshConversationTableViewWithConversationModel:customModel];
//              [blockSelf_ resetConversationListBackgroundViewIfNeeded];
//              
//              
//              //当消息为RCContactNotificationMessage时，没有调用super，如果是最后一条消息，可能需要刷新一下整个列表。
//              //原因请查看super didReceiveMessageNotification的注释。
//              NSNumber *left = [notification.userInfo objectForKey:@"left"];
//              if (0 == left.integerValue) {
//                  [super refreshConversationTableViewIfNeeded];
//              }
//          });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //调用父类刷新未读消息数
                [super didReceiveMessageNotification:notification];
                [blockSelf_ resetConversationListBackgroundViewIfNeeded];
            });
        }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [KNSNotification removeObserver:self name:kChatFromUserInfo object:nil];
}

@end
