//
//  WLChatViewController.m
//  Welian
//
//  Created by weLian on 15/6/10.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "WLChatViewController.h"
#import "WLChatCustomCardCell.h"
#import "CustomMessageType.h"
#import "UserInfoViewController.h"
#import "BasicViewController.h"
#import "CustomCardMessage.h"

@interface WLChatViewController ()

@end

@implementation WLChatViewController

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

- (id)initWithConversationType:(RCConversationType)conversationType targetId:(NSString *)targetId
{
    self = [super initWithConversationType:conversationType targetId:targetId];
    if (self) {
        [self registerClass:[WLChatCustomCardCell class] forCellWithReuseIdentifier:@"chatcell"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //是否允许保存新拍照片到本地系统
    self.enableSaveNewPhotoToLocalSystem = YES;
    [self notifyUpdateUnreadMessageCount];
    [self.pluginBoardView removeItemWithTag:1004];
    
//    /**
//     *  注册消息类型，如果使用IMKit，使用此方法，不再使用RongIMLib的同名方法。如果对消息类型进行扩展，可以忽略此方法。
//     *  @param messageClass   消息类型名称，对应的继承自 RCMessageContent 的消息类型。
//     */
    [self registerClass:[WLChatCustomCardCell class] forCellWithReuseIdentifier:@"chatcell"];
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

#pragma mark override
/**
 *  打开大图。开发者可以重写，自己下载并且展示图片。默认使用内置controller
 *
 *  @param model 图片消息model
 */
//- (void)presentImagePreviewController:(RCMessageModel *)model
//{
//    RCImagePreviewController *_imagePreviewVC =
//    [[RCImagePreviewController alloc] init];
//    _imagePreviewVC.messageModel = model;
//    _imagePreviewVC.title = @"图片预览";
//    
//    UINavigationController *nav = [[UINavigationController alloc]
//                                   initWithRootViewController:_imagePreviewVC];
//    
//    [self presentViewController:nav animated:YES completion:nil];
//}

#pragma mark override
/**
 *  重写方法实现自定义消息的显示
 *
 *  @param collectionView collectionView
 *  @param indexPath      indexPath
 *  @return RCMessageTemplateCell
 */
- (WLChatCustomCardCell *)rcConversationCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WLChatCustomCardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"chatcell" forIndexPath:indexPath];
    RCMessageModel *model = self.conversationDataRepository[indexPath.row];
    [cell setDataModel:model];
    // 点击头像
    WEAKSELF
    cell.chatIconBlock = ^(){
        if (model.messageDirection == MessageDirection_SEND) {
            [weakSelf didTapCellPortrait:model.senderUserId];
        }else{
            [weakSelf didTapCellPortrait:model.targetId];
        }
    };
    // 删除
    cell.chatDeleteBlock = ^(){
        [weakSelf deleteMessage:model];
    };
    return cell;
}

/**
 *  点击多媒体消息的时候统一触发这个回调
 *
 *  @param message   被操作的目标消息Model
 *  @param indexPath 该目标消息在哪个IndexPath里面
 *  @param messageTableViewCell 目标消息在该Cell上
 */
//- (void)multiMediaMessageDidSelectedOnMessage:(id <WLMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(WLMessageTableViewCell *)messageTableViewCell
//{
//    switch (message.messageMediaType) {
//            //        case WLBubbleMessageMediaTypeVideo:
//        case WLBubbleMessageMediaTypePhoto:
//        {
//            //键盘控制
//            //            [self finishSendMessageWithBubbleMessageType:WLBubbleMessageMediaTypePhoto];
//            
//            // 1.封装图片数据
//            NSArray *photoData = [self.messages bk_select:^BOOL(id obj) {
//                return [obj messageMediaType] == WLBubbleMessageMediaTypePhoto;
//            }];
//            NSInteger selectIndex = [photoData indexOfObject:message];
//            NSMutableArray *photos = [NSMutableArray arrayWithCapacity:photoData.count];
//            for (int i = 0; i<photoData.count; i++) {
//                WLMessage *wlMessage = photoData[i];
//                NSInteger index = [self.messages indexOfObject:wlMessage];
//                WLPhotoView *photoView = [[WLPhotoView alloc] init];
//                photoView.image = [ResManager imageWithPath:wlMessage.thumbnailUrl];
//                
//                MJPhoto *photo = [[MJPhoto alloc] init];
//                if( message.bubbleMessageType == WLBubbleMessageTypeSending){
//                    photo.image = [ResManager imageWithPath:wlMessage.thumbnailUrl];
//                }else{
//                    //去除，现实高清图地址
//                    NSString *photoUrl = wlMessage.originPhotoUrl;
//                    photoUrl = [photoUrl stringByReplacingOccurrencesOfString:@"_x.jpg" withString:@".jpg"];
//                    photoUrl = [photoUrl stringByReplacingOccurrencesOfString:@"_x.png" withString:@".png"];
//                    photo.url = [NSURL URLWithString:photoUrl]; // 图片路径
//                }
//                photo.srcImageView = photoView; // 来源于哪个UIImageView
//                photo.hasNoImageView = YES;
//                WLMessageTableViewCell *cell = (WLMessageTableViewCell *)[self.messageTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//                //计算图片在屏幕中的位置
//                CGRect imageRect = [cell.messageBubbleView.bubblePhotoImageView convertRect:cell.messageBubbleView.bubblePhotoImageView.bounds toView:self.view];
//                photo.imageCurrentRect = CGRectMake(imageRect.origin.x, imageRect.origin.y + ViewCtrlTopBarHeight, imageRect.size.width, imageRect.size.height);
//                [photos addObject:photo];
//            }
//            
//            // 2.显示相册
//            MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
//            browser.currentPhotoIndex = selectIndex; // 弹出相册时显示的第一张图片是？
//            browser.photos = photos; // 设置所有的图片
//            [browser show];
//            //
//            //
//            //            DLog(@"message ----> photo");
//            //            WLDisplayMediaViewController *messageDisplayTextView = [[WLDisplayMediaViewController alloc] init];
//            //            messageDisplayTextView.message = message;
//            //            [self.navigationController pushViewController:messageDisplayTextView animated:YES];
//        }
//            break;
//        case WLBubbleMessageMediaTypeActivity://活动
//        {
//            //查询本地有没有该活动
//            ActivityInfo *activityInfo = [ActivityInfo getActivityInfoWithActiveId:message.cardId Type:@(0)];
//            ActivityDetailInfoViewController *activityInfoVC = nil;
//            if(activityInfo){
//                activityInfoVC = [[ActivityDetailInfoViewController alloc] initWithActivityInfo:activityInfo];
//            }else{
//                activityInfoVC = [[ActivityDetailInfoViewController alloc] initWIthActivityId:message.cardId];
//            }
//            if (activityInfoVC) {
//                [self.navigationController pushViewController:activityInfoVC animated:YES];
//            }
//        }
//            break;
//        case WLBubbleMessageMediaTypeCard:
//        {
//            DLog(@"message ----> Card");
//            //3 活动，10项目，11 网页  13 投递项目卡片 14 用户名片卡片 15 投资人索要项目卡片
//            switch (message.cardType.integerValue) {
//                case WLBubbleMessageCardTypeActivity:
//                {
//                    //查询本地有没有该活动
//                    ActivityInfo *activityInfo = [ActivityInfo getActivityInfoWithActiveId:message.cardId Type:@(0)];
//                    ActivityDetailInfoViewController *activityInfoVC = nil;
//                    if(activityInfo){
//                        activityInfoVC = [[ActivityDetailInfoViewController alloc] initWithActivityInfo:activityInfo];
//                    }else{
//                        activityInfoVC = [[ActivityDetailInfoViewController alloc] initWIthActivityId:message.cardId];
//                    }
//                    if (activityInfoVC) {
//                        [self.navigationController pushViewController:activityInfoVC animated:YES];
//                    }
//                }
//                    break;
//                case WLBubbleMessageCardTypeProject:
//                {
//                    //查询数据库是否存在
//                    ProjectInfo *projectInfo = [ProjectInfo getProjectInfoWithPid:message.cardId Type:@(0)];
//                    ProjectDetailsViewController *projectDetailVC = nil;
//                    if (projectInfo) {
//                        projectDetailVC = [[ProjectDetailsViewController alloc] initWithProjectInfo:projectInfo];
//                    }else{
//                        IProjectInfo *iProjectInfo = [[IProjectInfo alloc] init];
//                        iProjectInfo.name = message.cardTitle;
//                        iProjectInfo.pid = message.cardId;
//                        iProjectInfo.intro = message.cardIntro;
//                        projectDetailVC = [[ProjectDetailsViewController alloc] initWithIProjectInfo:iProjectInfo];
//                    }
//                    if (projectDetailVC) {
//                        [self.navigationController pushViewController:projectDetailVC animated:YES];
//                    }
//                }
//                    break;
//                case WLBubbleMessageCardTypeWeb:
//                {
//                    //普通链接
//                    TOWebViewController *webVC = [[TOWebViewController alloc] initWithURLString:message.cardUrl];
//                    webVC.navigationButtonsHidden = YES;//隐藏底部操作栏目
//                    webVC.showRightShareBtn = YES;//现实右上角分享按钮
//                    [self.navigationController pushViewController:webVC animated:YES];
//                }
//                    break;
//                case WLBubbleMessageCardTypeInvestorGet:
//                {
//                    //索要项目
//                    InvestorUserInfoController *investorUserInfoVC = [[InvestorUserInfoController alloc] initWithUserType:InvestorUserTypeUID andUserData:@[message.cardId,message.cardRelationId]];
//                    [self.navigationController pushViewController:investorUserInfoVC animated:YES];
//                }
//                    break;
//                case WLBubbleMessageCardTypeInvestorPost:
//                {
//                    //投递项目
//                    ProjectPostDetailInfoViewController *projectPostDetailVC = [[ProjectPostDetailInfoViewController alloc] initWithPid:message.cardId];
//                    [self.navigationController pushViewController:projectPostDetailVC animated:YES];
//                }
//                    break;
//                case WLBubbleMessageCardTypeInvestorUser:
//                {
//                    //用户名片卡片
//                    
//                }
//                    break;
//                default:
//                    break;
//            }
//        }
//            break;
//        default:
//            break;
//    }
//}

/**
 *  重写方法实现自定义消息的显示的高度
 *
 *  @param collectionView       collectionView
 *  @param collectionViewLayout collectionViewLayout
 *  @param indexPath            indexPath
 *  @return 显示的高度
 */
- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RCMessageModel *model = self.conversationDataRepository[indexPath.row];
    CustomCardMessage *customCardM = (CustomCardMessage *)model.content;
    return CGSizeMake(SuperSize.width, [WLChatCustomCardCell getCellSizeWithCardMessage:customCardM].height+10);
}

#pragma mark override
/**
 *  点击pluginBoardView上item响应事件
 *
 *  @param pluginBoardView 功能模板
 *  @param tag             标记
 */
//-(void)pluginBoardView:(RCPluginBoardView*)pluginBoardView clickedItemWithTag:(NSInteger)tag
//{
//    DLog(@"%d",tag);
//}

@end
