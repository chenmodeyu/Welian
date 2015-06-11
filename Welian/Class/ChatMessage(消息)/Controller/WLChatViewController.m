//
//  WLChatViewController.m
//  Welian
//
//  Created by weLian on 15/6/10.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "WLChatViewController.h"
#import "ChatCell.h"
#import "CustomMessageType.h"
#import "UserInfoViewController.h"
#import "BasicViewController.h"

@interface WLChatViewController ()

@end

@implementation WLChatViewController

- (id)initWithConversationType:(RCConversationType)conversationType targetId:(NSString *)targetId
{
    self = [super initWithConversationType:conversationType targetId:targetId];
    if (self) {
        [self registerClass:[ChatCell class] forCellWithReuseIdentifier:@"chatcell"];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //是否允许保存新拍照片到本地系统
    self.enableSaveNewPhotoToLocalSystem = YES;
    [self notifyUpdateUnreadMessageCount];
    
//    /**
//     *  注册消息类型，如果使用IMKit，使用此方法，不再使用RongIMLib的同名方法。如果对消息类型进行扩展，可以忽略此方法。
//     *  @param messageClass   消息类型名称，对应的继承自 RCMessageContent 的消息类型。
//     */
    [self registerClass:[ChatCell class] forCellWithReuseIdentifier:@"chatcell"];
}


/**
 *  将要显示会话消息，可以修改RCMessageBaseCell的头像形状，添加自定定义的UI修饰
 *
 *  @param cell      cell
 *  @param indexPath indexPath
 */
//- (void)willDisplayConversationTableCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath
//{
//    //是否显示昵称
////    [cell setDataModel:[self.conversationDataRepository objectAtIndex:indexPath.row]];
//}

//当编辑完扩展功能后，下一步就是要实现对扩展功能事件的处理，放开被注掉的函数
- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag{
    [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
    switch (tag) {
        case 101: {
            //这里加你自己的事件处理
        } break;
        default:
            break;
    }
}

/**
 *  重写方法，消息发送完成触发
 *
 *  @param stauts        0,成功，非0失败
 *  @param messageCotent 消息内容
 */
//- (void)didSendMessage:(NSInteger)stauts content:(RCMessageContent *)messageCotent
//{
//    
//}

#pragma mark override
/**
 *  重写方法，过滤消息或者修改消息
 *
 *  @param messageCotent 消息内容
 *
 *  @return 返回消息内容
 */
//- (RCMessageContent *)willSendMessage:(RCMessageContent *)messageCotent
//{
//    
//    CustomMessageType *content = [CustomMessageType messageWithContent:[(RCTextMessage *)messageCotent content]];
//    
//    return content;
//}

/**
 *  发送消息
 *
 *  @param messageContent 消息
 *
 *  @param pushContent push显示内容
 */
//- (void)sendMessage:(RCMessageContent *)messageContent pushContent:(NSString *)pushContent
//{
//    
//    CustomMessageType *content = [CustomMessageType messageWithContent:[(RCTextMessage *)messageContent content]];
////    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_CUSTOMERSERVICE
////                                      targetId:self.targetId
////                                       content:content//(CustomMessageType *)messageContent//消息内容
////                                   pushContent:@""//推送消息内容
////                                       success:^(long messageId) {
////                                           RCMessage *msg = [[RCMessage alloc] initWithType:ConversationType_CUSTOMERSERVICE
////                                                                                   targetId:self.targetId
////                                                                                  direction:MessageDirection_SEND
////                                                                                  messageId:messageId
////                                                                                    content:content];
////                                           RCMessageModel *msgModel = [[RCMessageModel alloc] initWithMessage:msg];
////                                           [self.conversationDataRepository addObject:msgModel];
////                                           [self.conversationMessageCollectionView reloadData];
////                                       } error:^(RCErrorCode nErrorCode, long messageId) {
////                                           
////                                       }];
//}

/**
 *  发送消息。可以发送任何类型的消息。
 *  注：如果通过该接口发送图片消息，需要自己实现上传图片，把imageUrl传入content（注意它将是一个RCImageMessage）。
 *  @param conversationType 会话类型。
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id 或聊天室 Id。
 *  @param content          消息内容。
 *  @param pushContent      推送消息内容
 *  @param successBlock     调用完成的处理。
 *  @param errorBlock       调用返回的错误信息。
 *
 *  @return 发送的消息实体。
 */
//- (RCMessage *)sendMessage:(RCConversationType)conversationType
//                  targetId:(NSString *)targetId
//                   content:(RCMessageContent *)content
//               pushContent:(NSString *)pushContent
//                   success:(void (^)(long messageId))successBlock
//                     error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;
//
///**
// *  发送图片消息，上传图片并且发送，使用该方法，默认原图会上传到融云的服务，并且发送消息,如果使用普通的sendMessage方法，
// *  需要自己实现上传图片，并且添加ImageMessage的URL之后发送
// *
// *  @param conversationType 会话类型。
// *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id 或聊天室 Id。
// *  @param content          消息内容
// *  @param pushContent      推送消息内容
// *  @param progressBlock    进度块
// *  @param successBlock     成功处理块
// *  @param errorBlock       失败处理块
// *
// *  @return 发送的消息实体。
// */
//- (RCMessage *)sendImageMessage:(RCConversationType)conversationType
//                       targetId:(NSString *)targetId
//                        content:(RCMessageContent *)content
//                    pushContent:(NSString *)pushContent
//                       progress:(void (^)(int progress, long messageId))progressBlock
//                        success:(void (^)(long messageId))successBlock
//                          error:(void (^)(RCErrorCode errorCode, long messageId))errorBlock;

/**
 *  发送图片消息，此方法会先上传图片到融云指定的图片服务器，在发送消息。
 *
 *  @param imageMessage 消息
 *
 *  @param pushContent push显示内容
 */
//- (void)sendImageMessage:(RCImageMessage *)imageMessage pushContent:(NSString *)pushContent
//{
//    
//}

#pragma mark override
/**
 *  点击消息内容
 *
 *  @param model 数据
 */
//- (void)didTapMessageCell:(RCMessageModel *)model
//{
//    NSLog(@"didTapMessageCell");
//}

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

#pragma mark override
///**
// *  长按消息内容
// *
// *  @param model 数据
// */
//- (void)didLongTouchMessageCell:(RCMessageModel *)model
//{
//    DLog(@"didLongTouchMessageCell:%@",model.content);
//}

#pragma mark override
/**
 *  打开大图。开发者可以重写，自己下载并且展示图片。默认使用内置controller
 *
 *  @param model 图片消息model
 */
- (void)presentImagePreviewController:(RCMessageModel *)model
{
    RCImagePreviewController *_imagePreviewVC =
    [[RCImagePreviewController alloc] init];
    _imagePreviewVC.messageModel = model;
    _imagePreviewVC.title = @"图片预览";
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:_imagePreviewVC];
    
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark override
/**
 *  打开地理位置。开发者可以重写，自己根据经纬度打开地图显示位置。默认使用内置地图
 *
 *  @param locationMessageContent 位置消息
 */
//- (void)presentLocationViewController:(RCLocationMessage *)locationMessageContent
//{
//    
//}

/**
 *  重写方法实现自定义消息的显示
 *
 *  @param collectionView collectionView
 *  @param indexPath      indexPath
 *
 *  @return RCMessageTemplateCell
 */
- (RCMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView
                             cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChatCell *cell = [self.conversationMessageCollectionView dequeueReusableCellWithReuseIdentifier:@"chatcell" forIndexPath:indexPath];
    [cell setDebug:YES];
    RCMessageModel *model = self.conversationDataRepository[indexPath.row];
    //    RCMessage *msg = [[RCMessage alloc] initWithType:ConversationType_CUSTOMERSERVICE
    //                                            targetId:self.targetId
    //                                           direction:MessageDirection_SEND
    //                                           messageId:messageId
    //                                             content:content];
    //    RCMessageModel *msgModel = [[RCMessageModel alloc] initWithMessage:msg];
    //    [self.conversationDataRepository addObject:msgModel];
    //    cell.model = self.conversationDataRepository[indexPath.row];
    DLog(@"info:%@",[(CustomMessageType *)model.content content]);
    [cell setModel:model];
    //    [cell updateStatusContentView:model];
    return cell;
}

/**
 *  重写方法实现自定义消息的显示的高度
 *
 *  @param collectionView       collectionView
 *  @param collectionViewLayout collectionViewLayout
 *  @param indexPath            indexPath
 *
 *  @return 显示的高度
 */
- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RCMessageModel *model = self.conversationDataRepository[indexPath.row];
    NSString *tst = [(CustomMessageType *)model.content content];
    
    return CGSizeMake(self.view.width, 100);
    //    RCMessage *msg = [[RCMessage alloc] initWithType:ConversationType_CUSTOMERSERVICE
    //                                            targetId:self.targetId
    //                                           direction:MessageDirection_SEND
    //                                           messageId:messageId
    //                                             content:content];
    //    RCMessageModel *msgModel = [[RCMessageModel alloc] initWithMessage:msg];
    //    [self.conversationDataRepository addObject:msgModel];
    //    cell.model = self.conversationDataRepository[indexPath.row];
    //    NSLog(@"info:%@",[(CustomMessageType *)model.content content]);
    //    ChatCell *cell = (ChatCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //    CGFloat heiht = cell.baseContentView.height + (cell.isDisplayMessageTime ? 40 : 0);
    //    return CGSizeMake(self.view.width, 200);
}


@end
