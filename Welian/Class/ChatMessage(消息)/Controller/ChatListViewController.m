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

@interface ChatListViewController ()

@end

@implementation ChatListViewController

- (NSString *)title
{
    return @"会话列表";
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
        [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP),@(ConversationType_SYSTEM)]];
        //聚合会话类型
        [self setCollectionConversationType:@[@(ConversationType_GROUP),@(ConversationType_DISCUSSION)]];
        
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
//    chatVC.conversation = model;
    
    [self.navigationController pushViewController:chatVC animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.conversationListTableView.tableFooterView = [UIView new];
    ChatRoomHeaderView *chatRoomHeader = [[ChatRoomHeaderView alloc] init];
    [chatRoomHeader setFrame:CGRectMake(0, 0, SuperSize.width, 80)];
    [chatRoomHeader.clickBut addTarget:self action:@selector(enterChatRoomListVC) forControlEvents:UIControlEventTouchUpInside];
    self.conversationListTableView.tableHeaderView = chatRoomHeader;
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)enterChatRoomListVC
{
    ChatRoomListController *chatRoomListVC = [[ChatRoomListController alloc] init];
    [self.navigationController pushViewController:chatRoomListVC animated:YES];
}

- (void)updateBadgeValueForTabBarItem
{
    __weak typeof(self) __weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        int count = [[RCIMClient sharedRCIMClient]getUnreadCount:self.displayConversationTypeArray];
        if (count>0) {
            __weakSelf.tabBarItem.badgeValue = [[NSString alloc]initWithFormat:@"%d",count];
        }else
        {
            __weakSelf.tabBarItem.badgeValue = nil;
        }
        
    });
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
        
        ChatListViewController *temp = [[ChatListViewController alloc] init];
        NSArray *array = [NSArray arrayWithObject:[NSNumber numberWithInt:model.conversationType]];
        [temp setDisplayConversationTypes:array];
        [temp setCollectionConversationType:nil];
        temp.isEnteredToCollectionViewController = YES;
        [self.navigationController pushViewController:temp animated:YES];
    }
    
    //自定义会话类型
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
        RCConversationModel *model = self.conversationListDataSource[indexPath.row];
        ChatRoomListController *chatRoomListVC = [[ChatRoomListController alloc] init];
        [self.navigationController pushViewController:chatRoomListVC animated:YES];
    }
    
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
//    
//    UITableViewCellEditingStyle result = UITableViewCellEditingStyleNone;//默认没有编辑风格
//    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
//        result = UITableViewCellEditingStyleDelete;//设置编辑风格为删除风格
//    }
//    return result;
//}


//*********************插入自定义Cell*********************//
//插入自定义会话model
-(NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource
{
//    RCConversationModel *model = [[RCConversationModel alloc] init:RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION  exntend:nil];
//    model.isTop = YES;
//    [dataSource insertObject:model atIndex:0];
    return dataSource;
}

//左滑删除
-(void)rcConversationListTableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.conversationListDataSource removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//高度
//-(CGFloat)rcConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 80.0f;
//}

//自定义cell
-(RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
//    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
//        RCDChatListCell *cell = [[RCDChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
//        return cell;
//    }
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
        //该接口需要替换为从消息体获取好友请求的用户信息
        LogInUser *loginUser = [LogInUser getCurrentLoginUser];
        if (!loginUser) {
            return;
        }
        MyFriendUser *user = [loginUser getMyfriendUserWithUid:@(_contactNotificationMsg.sourceUserId.integerValue)];
        
                                  RCDUserInfo *rcduserinfo_ = [RCDUserInfo new];
                                  rcduserinfo_.userName = user.name;
                                  rcduserinfo_.userId = user.uid.stringValue;
                                  rcduserinfo_.portraitUri = user.avatar;//头像
                                  
                                  RCConversationModel *customModel = [RCConversationModel new];
                                  customModel.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
                                  customModel.extend = rcduserinfo_;
                                  customModel.senderUserId = message.senderUserId;
                                  customModel.lastestMessage = _contactNotificationMsg;
                                  //[_myDataSource insertObject:customModel atIndex:0];
                                  
                                  //local cache for userInfo
                                  NSDictionary *userinfoDic = @{@"username": rcduserinfo_.userName,
                                                                @"portraitUri":rcduserinfo_.portraitUri
                                                                };
                                  [[NSUserDefaults standardUserDefaults]setObject:userinfoDic forKey:_contactNotificationMsg.sourceUserId];
                                  [[NSUserDefaults standardUserDefaults]synchronize];
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      //调用父类刷新未读消息数
                                      [blockSelf_ refreshConversationTableViewWithConversationModel:customModel];
                                      //[super didReceiveMessageNotification:notification];
                                      [blockSelf_ resetConversationListBackgroundViewIfNeeded];
                                      [blockSelf_ updateBadgeValueForTabBarItem];
                                  });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            //调用父类刷新未读消息数
            [super didReceiveMessageNotification:notification];
            [blockSelf_ resetConversationListBackgroundViewIfNeeded];
            [blockSelf_ updateBadgeValueForTabBarItem];
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
