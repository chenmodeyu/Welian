//
//  WLChatViewController.m
//  Welian
//
//  Created by weLian on 15/6/10.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "WLChatViewController.h"
#import "WLChatCustomCardCell.h"
#import "UserInfoViewController.h"
#import "BasicViewController.h"
#import "CustomCardMessage.h"
#import "ActivityDetailInfoViewController.h"
#import "ProjectDetailsViewController.h"
#import "TOWebViewController.h"
#import "InvestorUserInfoController.h"
#import "ProjectPostDetailInfoViewController.h"
#import "JKImagePickerController.h"

@interface WLChatViewController ()<UIGestureRecognizerDelegate,JKImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    BOOL _isBlakUser;
}
@end

static NSString *tipMessageCellid=@"rcTipMessageCellIndentifier";
static NSString *customCardCellid = @"customCardCellid";

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
    [NSUserDefaults setString:self.targetId forKey:@"Chat_Share_Friend_Uid"];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (id)initWithConversationType:(RCConversationType)conversationType targetId:(NSString *)targetId
{
    self = [super initWithConversationType:conversationType targetId:targetId];
    if (self) {
        [self registerClass:[WLChatCustomCardCell class] forCellWithReuseIdentifier:customCardCellid];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    //是否允许保存新拍照片到本地系统
    self.enableSaveNewPhotoToLocalSystem = YES;
    [self notifyUpdateUnreadMessageCount];
    [self.pluginBoardView removeItemWithTag:1004];
    
    //* 注册消息类型，如果使用IMKit，使用此方法，不再使用RongIMLib的同名方法。如果对消息类型进行扩展，可以忽略此方法。
    [self registerClass:[WLChatCustomCardCell class] forCellWithReuseIdentifier:customCardCellid];
}


/**
 *  更新左上角未读消息数
 */
- (void)notifyUpdateUnreadMessageCount {
    __weak typeof(&*self) __weakself = self;
    int count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[        @(ConversationType_PRIVATE),@(ConversationType_SYSTEM)]];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *backString = nil;
        if (count > 0 && count <= 99) {
            backString = [NSString stringWithFormat:@"消息(%d)", count];
        } else if (count > 99) {
            backString = @"消息(99+)";
        } else {
            backString = @"消息";
        }
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 4, 90, 25);
        UIImageView *backImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navbar_left"]];
        backImg.frame = CGRectMake(-5, 3, 12, 20);
        [backBtn addSubview:backImg];
        UILabel *backText = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 90, 25)];
        backText.text = backString;//NSLocalizedStringFromTable(@"Back", @"RongCloudKit", nil);
        backText.font = [UIFont systemFontOfSize:16];
        [backText setBackgroundColor:[UIColor clearColor]];
        [backText setTextColor:[UIColor whiteColor]];
        [backBtn addSubview:backText];
        [backBtn addTarget:__weakself action:@selector(leftBarButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        [__weakself.navigationItem setLeftBarButtonItem:leftButton];
    });
}

- (void)leftBarButtonItemPressed:(id)sender {
    //需要调用super的实现
    [super leftBarButtonItemPressed:sender];
    [self.navigationController popViewControllerAnimated:YES];
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
 *  @param imageMessageContent 图片消息内容
 */
//- (void)presentImagePreviewController:(RCMessageModel *)model;
//{
//    RCImagePreviewController *_imagePreviewVC =
//    [[RCImagePreviewController alloc] init];
//    _imagePreviewVC.messageModel = model;
//    _imagePreviewVC.title = @"图片预览";
//    
//    UINavigationController *nav = [[UINavigationController alloc]
//                                   initWithRootViewController:_imagePreviewVC];
//    [self presentViewController:nav animated:YES completion:nil];
//}


#pragma mark override
/**
 *  重写方法，消息发送完成触发
 *
 *  @param stauts        0,成功，非0失败
 *  @param messageCotent 消息内容
 */
- (void)didSendMessage:(NSInteger)stauts content:(RCMessageContent *)messageCotent
{
    [super didSendMessage:stauts content:messageCotent];
    if (stauts == 405) {  // 已加入黑名单
        if (!_isBlakUser) {
            RCInformationNotificationMessage *infoNot = [RCInformationNotificationMessage notificationWithMessage:@"你们已解除好友关系，无法继续聊天" extra:@""];
            [self sendMessage:infoNot pushContent:@"你们已解除好友关系，无法继续聊天"];
            _isBlakUser = YES;
        }
    }
}

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
//    __block BOOL isBlakUser = NO;
//    [[RCIMClient sharedRCIMClient] getBlacklistStatus:self.targetId success:^(int bizStatus) {
//        if (bizStatus == 0) {
//            isBlakUser = YES;
//        }
//        RCInformationNotificationMessage *infoNot = [RCInformationNotificationMessage notificationWithMessage:@"你们已解除好友关系，无法继续聊天" extra:@""];
//        return infoNot;
//    } error:^(RCErrorCode status) {
//        
//    }];
////    if (isBlakUser) {
////        RCInformationNotificationMessage *infoNot = [RCInformationNotificationMessage notificationWithMessage:@"你们已解除好友关系，无法继续聊天" extra:@""];
////        return infoNot;
////    }else{
////       return messageCotent;
////    }
////    return nil;
//}

/**
 *  重写方法实现自定义消息的显示
 *  @param collectionView collectionView
 *  @param indexPath      indexPath
 *  @return RCMessageTemplateCell
 */
- (RCMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RCMessageModel *model = self.conversationDataRepository[indexPath.row];
    if ([model isMemberOfClass:[RCInformationNotificationMessage class]]) {
        RCTipMessageCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:tipMessageCellid forIndexPath:indexPath];
        [cell setDataModel:model];
        return cell;
    }else{
        WLChatCustomCardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:customCardCellid forIndexPath:indexPath];
        [cell setDataModel:model];
        CustomCardMessage *customCardM = (CustomCardMessage *)model.content;
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
        cell.chatCardBlock = ^(){
            DLog(@"%@",customCardM.card);
            [weakSelf selectedCardMessageWithCardM:customCardM];
        };
        return cell;
    }
}

- (void)selectedCardMessageWithCardM:(CustomCardMessage *)cardMessage
{
    CardStatuModel *cardModel = [CardStatuModel objectWithDict:cardMessage.card];
    
    //3 活动，10项目，11 网页  13 投递项目卡片 14 用户名片卡片 15 投资人索要项目卡片
    switch (cardModel.type.integerValue) {
        case WLBubbleMessageCardTypeActivity:
        {
            //查询本地有没有该活动
            ActivityInfo *activityInfo = [ActivityInfo getActivityInfoWithActiveId:cardModel.cid Type:@(0)];
            ActivityDetailInfoViewController *activityInfoVC = nil;
            if(activityInfo){
                activityInfoVC = [[ActivityDetailInfoViewController alloc] initWithActivityInfo:activityInfo];
            }else{
                activityInfoVC = [[ActivityDetailInfoViewController alloc] initWIthActivityId:cardModel.cid];
            }
            if (activityInfoVC) {
                [self.navigationController pushViewController:activityInfoVC animated:YES];
            }
        }
            break;
        case WLBubbleMessageCardTypeProject:
        {
            //查询数据库是否存在
            ProjectInfo *projectInfo = [ProjectInfo getProjectInfoWithPid:cardModel.cid Type:@(0)];
            ProjectDetailsViewController *projectDetailVC = nil;
            if (projectInfo) {
                projectDetailVC = [[ProjectDetailsViewController alloc] initWithProjectInfo:projectInfo];
            }else{
                IProjectInfo *iProjectInfo = [[IProjectInfo alloc] init];
                iProjectInfo.name = cardModel.title;
                iProjectInfo.pid = cardModel.cid;
                iProjectInfo.intro = cardModel.intro;
                projectDetailVC = [[ProjectDetailsViewController alloc] initWithIProjectInfo:iProjectInfo];
            }
            if (projectDetailVC) {
                [self.navigationController pushViewController:projectDetailVC animated:YES];
            }
        }
            break;
        case WLBubbleMessageCardTypeWeb:
        {
            //普通链接
            TOWebViewController *webVC = [[TOWebViewController alloc] initWithURLString:cardModel.url];
            webVC.navigationButtonsHidden = YES;//隐藏底部操作栏目
            webVC.showRightShareBtn = YES;//现实右上角分享按钮
            [self.navigationController pushViewController:webVC animated:YES];
        }
            break;
        case WLBubbleMessageCardTypeInvestorGet:
        {
            //索要项目
            InvestorUserInfoController *investorUserInfoVC = [[InvestorUserInfoController alloc] initWithUserType:InvestorUserTypeUID andUserData:@[cardModel.cid,cardModel.relationid]];
            [self.navigationController pushViewController:investorUserInfoVC animated:YES];
        }
            break;
        case WLBubbleMessageCardTypeInvestorPost:
        {
            //投递项目
            ProjectPostDetailInfoViewController *projectPostDetailVC = [[ProjectPostDetailInfoViewController alloc] initWithPid:cardModel.cid];
            [self.navigationController pushViewController:projectPostDetailVC animated:YES];
        }
            break;
        case WLBubbleMessageCardTypeInvestorUser:
        {
            //用户名片卡片
            
        }
            break;
        default:
            break;
    }
}

/**
 *  重写方法实现自定义消息的显示的高度
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
    if ([model.content isMemberOfClass:[RCInformationNotificationMessage class]]) {
        return CGSizeMake(SuperSize.width, 30);
    }else{
        CustomCardMessage *customCardM = (CustomCardMessage *)model.content;
        return CGSizeMake(SuperSize.width, [WLChatCustomCardCell getCellSizeWithCardMessage:customCardM].height+10);
    }
}


- (void)didTapPhoneNumberInMessageCell:(NSString *)phoneNumber model:(RCMessageModel *)model
{
}

#pragma mark override
/**
 *  点击pluginBoardView上item响应事件
 *
 *  @param pluginBoardView 功能模板
 *  @param tag             标记
 */
-(void)pluginBoardView:(RCPluginBoardView*)pluginBoardView clickedItemWithTag:(NSInteger)tag
{
    if (tag == 1001) {
        [self showPicVC];
    }else if(tag == 1002){
        [self clickSheetCamera];
    }else{
        [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
    }
}

- (void)showPicVC
{
    JKImagePickerController *imagePickerController = [[JKImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.filterType = JKImagePickerControllerFilterTypePhotos;
    imagePickerController.showsCancelButton = YES;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.minimumNumberOfSelection = 1;
    imagePickerController.maximumNumberOfSelection = 9;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - JKImagePickerControllerDelegate
- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAssets:(NSArray *)assets isSource:(BOOL)source
{
    WEAKSELF
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        for (JKAssets *jkasse in assets) {
            [weakSelf sendImageMessage:[RCImageMessage messageWithImage:jkasse.fullImage] pushContent:@"图片"];
        }
    }];
}

- (void)imagePickerControllerJKDidCancel:(JKImagePickerController *)imagePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage
{
    //保存图片
    UIImage *image = newImage;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
}


// 拍照
- (void)clickSheetCamera
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
//    [imagePicker setAllowsEditing:YES];
    // 判断相机可以使用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"摄像头不可用！！！" delegate:self cancelButtonTitle:@"知道了！" otherButtonTitles:nil, nil] show];
        return;
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //image就是你选取的照片
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self sendImageMessage:[RCImageMessage messageWithImage:image] pushContent:@"图片"];
    [picker dismissViewControllerAnimated:YES completion:nil];
}



@end
