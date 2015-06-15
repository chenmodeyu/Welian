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
#import "CustomMessageType.h"
#import "AppDelegate.h"

@interface ChatListViewController ()

@end

static NSString *chatroomcellid = @"chatroomcellid";
static NSString *chatNewFirendcellid = @"chatNewFirendcellid";

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

//- (void)fdalsdfasjfldsajkfdsaf
//{
//    RCContactNotificationMessage *notFiend = [RCContactNotificationMessage notificationWithOperation:ContactNotificationMessage_ContactOperationRequest sourceUserId:@"10030" targetUserId:@"10019" message:@"zhengjiahaoy" extra:@"fdasd"];
//    
////    RCUserInfo *user = [[RCUserInfo alloc] initWithUserId:@"10030" name:@"DDDD" portrait:@""];
////    CustomMessageType *customContent = [[CustomMessageType alloc] init];
////    [customContent setSenderUserInfo:user];
////    customContent.content = @"自定义消息0000000";
//    
//    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:@"10019" content:notFiend pushContent:@"zidsafdsafas" success:^(long messageId) {
//        DLog(@"%ld",messageId);
//    } error:^(RCErrorCode nErrorCode, long messageId) {
//        DLog(@"%ld",(long)nErrorCode);
//    }];
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.conversationListTableView.tableFooterView = [UIView new];
    [self.conversationListTableView registerClass:[ChatRoomHeaderView class] forCellReuseIdentifier:chatroomcellid];
    [self.conversationListTableView registerClass:[RCDChatListCell class] forCellReuseIdentifier:chatNewFirendcellid];
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
        if ([model.objectName isEqualToString:@"ChatRoomHeader"]) {
            ChatRoomListController *chatRoomListVC = [[ChatRoomListController alloc] init];
            [self.navigationController pushViewController:chatRoomListVC animated:YES];
        }else{
            
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleNone;//默认没有编辑风格
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        result = UITableViewCellEditingStyleDelete;//设置编辑风格为删除风格
    }
    return result;
}


//*********************插入自定义Cell*********************//
//插入自定义会话model
-(NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource
{
//    RCConversationModel *fdsads = dataSource[0];
    
    RCConversationModel *model = [[RCConversationModel alloc] init:RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION  exntend:nil];
    model.isTop = YES;
    model.objectName = @"ChatRoomHeader";
    [dataSource insertObject:model atIndex:0];
    
    return dataSource;
}

//左滑删除
-(void)rcConversationListTableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.conversationListDataSource removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//高度
-(CGFloat)rcConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

//自定义cell
-(RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
        if ([model.objectName isEqualToString:@"ChatRoomHeader"]) {
            ChatRoomHeaderView *cell = [tableView dequeueReusableCellWithIdentifier:chatroomcellid];
            return cell;
        }else{
            __block NSString *userName    = nil;
            __block NSString *portraitUri = nil;
            
            //此处需要添加根据userid来获取用户信息的逻辑，extend字段不存在于DB中，当数据来自db时没有extend字段内容，只有userid
            if (nil == model.extend) {
                // Not finished yet, To Be Continue...
                CustomMessageType *customMessage = (CustomMessageType *)model.lastestMessage;
                NSMutableDictionary *newFriendMessage = [NSMutableDictionary dictionaryWithDictionary:[[customMessage.content jsonObject] objectForKey:@"data"]];
                [newFriendMessage setObject:[[customMessage.content jsonObject] objectForKey:@"type"] forKey:@"type"];
                AppDelegate *delet = (AppDelegate *)[UIApplication sharedApplication].delegate;
                NewFriendUser *newFM = [delet getNewFriendMessage:newFriendMessage LoginUserId:nil];
                if (!newFM) {

                }
                NSDictionary *_cache_userinfo = [[NSUserDefaults standardUserDefaults]objectForKey:newFM.uid.stringValue];
                if (_cache_userinfo) {
                    userName = _cache_userinfo[@"username"];
                    portraitUri = _cache_userinfo[@"portraitUri"];
                }
                
            }else{
                RCDUserInfo *user = (RCDUserInfo *)model.extend;
                userName    = user.userName;
                portraitUri = user.portraitUri;
            }

            RCDChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:chatNewFirendcellid];
            cell.lblDetail.text =[NSString stringWithFormat:@"来自%@的好友请求",userName];
            [cell.ivAva sd_setImageWithURL:[NSURL URLWithString:portraitUri] placeholderImage:[UIImage imageNamed:@"system_notice"]];
            return cell;
        }
    }else{
        return nil;
    }
    
}

//*********************插入自定义Cell*********************//
#pragma mark - 收到消息监听
-(void)didReceiveMessageNotification:(NSNotification *)notification
{
    __weak typeof(&*self) blockSelf_ = self;
    //处理好友请求
    RCMessage *message = notification.object;
    
    if ([message.objectName isEqualToString:RCCustomMessageTypeIdentifier]) {
        CustomMessageType *customMessage = (CustomMessageType *)message.content;
        
        NSMutableDictionary *newFriendMessage = [NSMutableDictionary dictionaryWithDictionary:[[customMessage.content jsonObject] objectForKey:@"data"]];
        [newFriendMessage setObject:[[customMessage.content jsonObject] objectForKey:@"type"] forKey:@"type"];
        AppDelegate *delet = (AppDelegate *)[UIApplication sharedApplication].delegate;
       NewFriendUser *newFM = [delet getNewFriendMessage:newFriendMessage LoginUserId:nil];
        if (!newFM) {
            return;
        }
        RCDUserInfo *rcduserinfo_ = [RCDUserInfo new];
        rcduserinfo_.userName = newFM.name;
        rcduserinfo_.userId = newFM.uid.stringValue;
        rcduserinfo_.portraitUri = newFM.avatar;//头像
        
        RCConversationModel *customModel = [RCConversationModel new];
        customModel.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
        customModel.extend = rcduserinfo_;
        customModel.conversationType = ConversationType_SYSTEM;
        customModel.senderUserId = rcduserinfo_.userId;
        customModel.lastestMessage = customMessage;
        
        //local cache for userInfo
        NSDictionary *userinfoDic = @{@"username": rcduserinfo_.userName,
                                      @"portraitUri":rcduserinfo_.portraitUri
                                      };
        [[NSUserDefaults standardUserDefaults]setObject:userinfoDic forKey:customModel.senderUserId];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //调用父类刷新未读消息数
            [blockSelf_ refreshConversationTableViewWithConversationModel:customModel];
            [blockSelf_ resetConversationListBackgroundViewIfNeeded];
            [blockSelf_ updateBadgeValueForTabBarItem];
        });

        
        DLog(@"%@",[customMessage.content jsonObject]);
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            //调用父类刷新未读消息数
            [super didReceiveMessageNotification:notification];
            [blockSelf_ resetConversationListBackgroundViewIfNeeded];
            [blockSelf_ updateBadgeValueForTabBarItem];
        });
    }
    
    /*
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
                                  
                                  //local cache for userInfo
                                  NSDictionary *userinfoDic = @{@"username": rcduserinfo_.userName,
                                                                @"portraitUri":rcduserinfo_.portraitUri
                                                                };
                                  [[NSUserDefaults standardUserDefaults]setObject:userinfoDic forKey:_contactNotificationMsg.sourceUserId];
                                  [[NSUserDefaults standardUserDefaults]synchronize];
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      //调用父类刷新未读消息数
                                      [blockSelf_ refreshConversationTableViewWithConversationModel:customModel];
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
     */
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
