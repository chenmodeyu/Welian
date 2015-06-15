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

- (void)viewDidLoad {
    [super viewDidLoad];
    //是否允许保存新拍照片到本地系统
    self.enableSaveNewPhotoToLocalSystem = YES;
    [self notifyUpdateUnreadMessageCount];
    
//    /**
//     *  注册消息类型，如果使用IMKit，使用此方法，不再使用RongIMLib的同名方法。如果对消息类型进行扩展，可以忽略此方法。
//     *  @param messageClass   消息类型名称，对应的继承自 RCMessageContent 的消息类型。
//     */
    [self registerClass:[ChatCell class] forCellWithReuseIdentifier:@"chatcell"];
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
 *
 *  @return RCMessageTemplateCell
 */
- (RCMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ChatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"chatcell" forIndexPath:indexPath];
    CustomMessageType *model = self.conversationDataRepository[indexPath.row];

    DLog(@"info:%@",[(CustomMessageType *)model.content content]);
    [cell setModel:model];
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
}


@end
