 //
//  AppDelegate.m
//  Welian
//
//  Created by dong on 14-9-10.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import <AlipaySDK/AlipaySDK.h>

#import "ProjectDetailsViewController.h"
#import "ActivityDetailInfoViewController.h"
#import "TOWebViewController.h"
#import "NavViewController.h"
#import "LCNewFeatureVC.h"

#import "BMapKit.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "ShareEngine.h"
#import "WLTool.h"
#import "NewFriendModel.h"
#import "MJExtension.h"
#import "MobClick.h"
#import "MessageHomeModel.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "NewFriendUser.h"
#import "HomeMessage.h"
#import "ChatMessage.h"
#import "WLMessage.h"
#import "MyFriendUser.h"
#import "NeedAddUser.h"
#import "MsgPlaySound.h"
#import "CustomCardMessage.h"
#import "CommentInfoController.h"

#define kDeviceToken @"RongCloud_SDK_DeviceToken"

@interface AppDelegate() <BMKGeneralDelegate,UITabBarControllerDelegate,WXApiDelegate,RCIMConnectionStatusDelegate,RCIMUserInfoDataSource,RCIMGroupInfoDataSource>
{
    NSInteger _update; //0不提示更新 1不强制更新，2强制更新
     NSString *_upURL; // 更新地址
    NSString *_msg;  // 更新提示语
    UIAlertView *_updataalert;
}
    /** 新特性界面(如果是通过Block方式进入主界面则不需要声明该属性) */
@property (nonatomic, strong)  LCNewFeatureVC *newFeatureVC;

@end

@implementation AppDelegate
BMKMapManager* _mapManager;

- (LCNewFeatureVC *)newFeatureVC
{
    if (_newFeatureVC == nil) {
        WEAKSELF
        _newFeatureVC = [[LCNewFeatureVC alloc] initWithImageName:@"new_feature" imageCount:2 finishBlock:^{
            [weakSelf enterMainVC];
        }];
        _newFeatureVC.pointOtherColor = KBgGrayColor;
        _newFeatureVC.pointCurrentColor = KBlueTextColor;
    }
    return _newFeatureVC;
}

- (void)registerRemoteNotification
{
#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

//设置数据库转移
- (void)copyDefaultStoreIfNecessary
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:kStoreName];
    
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:[storeURL path]])
    {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:[kStoreName stringByDeletingPathExtension] ofType:[kStoreName pathExtension]];
        if (defaultStorePath)
        {
            NSError *error;
            BOOL success = [fileManager copyItemAtPath:defaultStorePath toPath:[storeURL path] error:&error];
            if (!success)
            {
                DLog(@"Failed to install default recipe store");
            }
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //数据库操作
    [self copyDefaultStoreIfNecessary];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelWarn];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:kStoreName];
    
    // 版本更新
    [self detectionUpdataVersionDic];
    
    // 友盟统计
    [self umengTrack];
    //初始化融云配置
    [self initRongInfo];
    
    // 要使用百度地图，请先启动BaiduMapManager
	_mapManager = [[BMKMapManager alloc]init];
	BOOL ret = [_mapManager start:KBMK_Key generalDelegate:self];
	if (!ret) {
        
	}
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // 添加微信分享
    [[ShareEngine sharedShareEngine] registerApp];
    [ShareSDK registerApp:KShareSDKAppKey];
    [ShareSDK connectWeChatWithAppId:kWeChatAppId
                           appSecret:KWeChatAppSecret
                           wechatCls:[WXApi class]];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
#pragma mark 1. 是否应该显示新特性界面
    BOOL showNewFeature = [LCNewFeatureVC shouldShowNewFeature];
    if (0) {
#pragma mark  设置新特性界面为当前窗口的根视图控制器
        self.window.rootViewController = self.newFeatureVC;
    }else{
        [self enterMainVC];
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    // 设置状态栏颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // [1]:使用APPID/APPKEY/APPSECRENT创建个推实例
    [self startSdkWith:KGTAppId appKey:KGTAppKey appSecret:kGTAppSecret];
    
    // [2]:注册APNS
    [self registerRemoteNotification];
    
    DLog(@"====沙盒路径=======%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES));
    
    return YES;
}

#pragma mark - 进入主界面
- (void)enterMainVC {
    
    if ([UserDefaults objectForKey:kSessionId]) {
        /** 已登陆 */
        self.mainVC = [[MainViewController alloc] init];
        [self.mainVC setDelegate:self];
        [self.window setRootViewController:self.mainVC];
    }else{
        /** 未登陆 */
        self.loginGuideVC = [[LoginGuideController alloc] init];
        [self.window setRootViewController:self.loginGuideVC];
    }
}


#pragma mark - 检测版本更新
- (void)detectionUpdataVersionDic
{
    [WeLianClient checkUpdateWithPlatform:KPlatformType
                                  Version:XcodeAppVersion
                                  Success:^(id resultInfo) {
                                      if ([[resultInfo objectForKey:@"flag"] integerValue]==1) {
                                          NSString *msg = [resultInfo objectForKey:@"msg"];
                                          _upURL = [resultInfo objectForKey:@"url"];
                                          _update = [[resultInfo objectForKey:@"update"] integerValue];
                                          _msg = msg;
                                          
                                          //// 0 检测更新，1强制弹出更新，2强制更新，不更新不可以使用
                                          if (_update==0) { //自己检测
                                              
                                          }else if(_update == 1){  // 弹出提示
                                              _updataalert = [[UIAlertView alloc] initWithTitle:@"更新提示" message:msg  delegate:self cancelButtonTitle:@"暂不更新" otherButtonTitles:@"立即更新", nil];
                                              [_updataalert show];
                                          }else if (_update == 2){  // 强制更新
                                              _updataalert = [[UIAlertView alloc] initWithTitle:@"更新提示" message:msg  delegate:self cancelButtonTitle:nil otherButtonTitles:@"立即更新", nil];
                                              [_updataalert show];
                                          }
                                      }
                                  } Failed:^(NSError *error) {
                                      
                                  }];
}

#pragma mark - 版本更新跳转- 退出登录
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _updataalert) {
        if (_update==1) {
            if (buttonIndex==1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_upURL]];
            }
        }else if (_update==2){
            if (buttonIndex==0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_upURL]];
            }
        }
    }
}


- (void)startSdkWith:(NSString *)appID appKey:(NSString *)appKey appSecret:(NSString *)appSecret
{
    if (!_gexinPusher) {
        _sdkStatus = SdkStatusStoped;
        
        self.appID = appID;
        self.appKey = appKey;
        self.appSecret = appSecret;
        _clientId = nil;
        
        NSError *err = nil;
        _gexinPusher = [GexinSdk createSdkWithAppId:_appID
                                             appKey:_appKey
                                          appSecret:_appSecret
                                         appVersion:XcodeAppVersion
                                           delegate:self
                                              error:&err];
        if (!_gexinPusher) {
            
        } else {
            _sdkStatus = SdkStatusStarting;
        }
    }
}

- (void)stopSdk
{
    if (_gexinPusher) {
        [_gexinPusher destroy];
        _gexinPusher = nil;
        
        _sdkStatus = SdkStatusStoped;
        
        _clientId = nil;
    }
}


- (BOOL)checkSdkInstance
{
    if (!_gexinPusher) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"SDK未启动" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
        return NO;
    }
    return YES;
}

- (void)setDeviceToken:(NSString *)aToken
{
    if (![self checkSdkInstance]) {
        return;
    }
    
    [_gexinPusher registerDeviceToken:aToken];
}

- (BOOL)setTags:(NSArray *)aTags error:(NSError **)error
{
    if (![self checkSdkInstance]) {
        return NO;
    }
    
    return [_gexinPusher setTags:aTags];
}

- (NSString *)sendMessage:(NSData *)body error:(NSError **)error {
    if (![self checkSdkInstance]) {
        return nil;
    }
    
    return [_gexinPusher sendMessage:body error:error];
}

- (void)initRongInfo
{
    NSString *_deviceTokenCache = [UserDefaults objectForKey:kRongCloudDeviceToken];
    //初始化融云SDK
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY deviceToken:_deviceTokenCache];
    //设置会话列表头像和会话界面头像
    //状态监听
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    //接收消息的监听器。如果使用IMKit，使用此方法，不再使用RongIMLib的同名方法。
//    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
    // 注册自定义消息
//    [[RCIM sharedRCIM] registerMessageType:CustomMessageType.class];
    [[RCIM sharedRCIM] registerMessageType:CustomCardMessage.class];
//    [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(45, 45);
    //聊天消息头像
//    if (Iphone6plus) {
//        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(45, 45);
//    }else{
//        NSLog(@"iPhone6 %d", Iphone6);
//        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(45, 45);
//    }
    //外面全局消息头像
//    [RCIM sharedRCIM].globalMessagePortraitSize = CGSizeMake(20, 20);
    
    //设置头像形状
    [RCIM sharedRCIM].globalMessageAvatarStyle = RC_USER_AVATAR_CYCLE;
    [RCIM sharedRCIM].globalConversationAvatarStyle = RC_USER_AVATAR_CYCLE;
//    [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
    //用于返回用户的信息
    // 设置用户信息提供者。
    [[RCIM sharedRCIM] setUserInfoDataSource:self];
    // 设置群组信息提供者。
    [[RCIM sharedRCIM] setGroupInfoDataSource:self];
    
    //保存token
    //设置当前的用户信息
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    NSString *token = loginUser.rongCloudToken;
    if (token.length > 0 && loginUser) {
        //登陆融云服务器  // 快速集成第二步，连接融云服务器
//        [WLHUDView showHUDWithStr:@"连接融云服务器中..." dim:YES];
        [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
            //保存默认用户
            RCUserInfo *_currentUserInfo = [[RCUserInfo alloc]initWithUserId:userId name:loginUser.name portrait:nil];
            [RCIMClient sharedRCIMClient].currentUserInfo = _currentUserInfo;
            
        } error:^(RCConnectErrorCode status) {
            NSLog(@"RCConnectErrorCode is %ld",(long)status);
        } tokenIncorrect:^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Token已过期，请重新登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];;
            [alertView show];
        }];
    }
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didReceiveMessageNotification:)
//                                                 name:RCKitDispatchMessageNotification
//                                               object:nil];
    //消息免通知，默认是NO
//        [RCIM sharedRCIM].disableMessageNotificaiton = YES;
//    关闭新消息提示音，默认值是NO，新消息有提示音.
//        [RCIM sharedRCIM].disableMessageAlertSound = YES;
}

//- (void)didReceiveMessageNotification:(NSNotification *)notification {
//    [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber+1;
//}

/**
 *  获取用户信息。
 *
 *  @param userId     用户 Id。
 *  @param completion 用户信息
 */
- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion
{
    // 此处最终代码逻辑实现需要您从本地缓存或服务器端获取用户信息。
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (!loginUser) {
        return;
    }

    //自己的用户信息
    if (userId.integerValue == loginUser.uid.integerValue) {
        RCUserInfo *user = [[RCUserInfo alloc]init];
        user.userId = loginUser.uid.stringValue;
        user.name = loginUser.name;
        user.portraitUri = loginUser.avatar;
        
        return completion(user);
    }
    
    //好友的用户信息
    MyFriendUser *friendUser = [loginUser getMyfriendUserWithUid:@(userId.integerValue)];
    NewFriendUser *newfriend = [loginUser getNewFriendUserWithUid:@(userId.integerValue)];
    if (friendUser) {
        RCUserInfo *user = [[RCUserInfo alloc]init];
        user.userId = friendUser.uid.stringValue;
        user.name = friendUser.name;
        user.portraitUri = friendUser.avatar;
        
        return completion(user);
    }else if(newfriend){
        RCUserInfo *user = [[RCUserInfo alloc]init];
        user.userId = newfriend.uid.stringValue;
        user.name = newfriend.name;
        user.portraitUri = newfriend.avatar;
        
        return completion(user);
    }
    
    //获取个人信息
    [WeLianClient getMemberWithUid:@(userId.integerValue)
                           Success:^(id resultInfo) {
                               IBaseUserM *baseUser = resultInfo;
                               RCUserInfo *user = [[RCUserInfo alloc]init];
                               user.userId = baseUser.uid.stringValue;
                               user.name = baseUser.name;
                               user.portraitUri = baseUser.avatar;
                               return completion(user);
                           } Failed:^(NSError *error) {
                               DLog(@"getMember error:%@",error.localizedDescription);
                           }];
    
    return completion(nil);
}

// 获取群组信息的方法。
-(void)getGroupInfoWithGroupId:(NSString*)groupId completion:(void (^)(RCGroup *group))completion
{
    // 此处最终代码逻辑实现需要您从本地缓存或服务器端获取群组信息。
    
    if ([@"1" isEqual:groupId]) {
        RCGroup *group = [[RCGroup alloc]init];
        group.groupId = @"1";
        group.groupName = @"同城交友";
        //group.portraitUri = @"http://rongcloud-web.qiniudn.com/docs_demo_rongcloud_logo.png";
        
        return completion(group);
    }
    
    if ([@"2" isEqual:groupId]) {
        RCGroup *group = [[RCGroup alloc]init];
        group.groupId = @"2";
        group.groupName = @"跳蚤市场";
        //group.portraitUri = @"http://rongcloud-web.qiniudn.com/docs_demo_rongcloud_logo.png";
        
        return completion(group);
    }
    
    return completion(nil);
}


#pragma mark - 友盟统计
- (void)umengTrack {
    
    [MobClick setCrashReportEnabled:YES]; // 如果不需要捕捉异常，注释掉此行
//    [MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy) REALTIME channelId:UMENG_ChannelId];
}

#if __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    _deviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [NSUserDefaults setString:_deviceToken forKey:kRongCloudDeviceToken];
    [[RCIMClient sharedRCIMClient] setDeviceToken:_deviceToken];
    // [3]:向个推服务器注册deviceToken
    if (_gexinPusher) {
        [_gexinPusher registerDeviceToken:_deviceToken];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    // [3-EXT]:如果APNS注册失败，通知个推服务器
    if (_gexinPusher) {
        [_gexinPusher registerDeviceToken:@""];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    NSString *payloadMsg = [userInfo objectForKey:@"payload"];
}


#pragma mark - 接收推送收取一条
- (void)inceptMessage:(NSDictionary*)userInfo
{
    NSString *type = [userInfo objectForKey:@"type"];
    if (!type) return;
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:[userInfo objectForKey:@"data"]];
    [dataDic setObject:type forKey:@"type"];
    
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if ([type isEqualToString:@"feedZan"]||[type isEqualToString:@"feedComment"]||[type isEqualToString:@"feedForward"]) {     // 动态消息推送
        if(loginUser){
            //添加消息数据
            [HomeMessage createHomeMessageModel:[MessageHomeModel objectWithDict:dataDic]];
            NSInteger badge = [loginUser.homemessagebadge integerValue];
            badge++;
            [LogInUser setUserHomemessagebadge:@(badge)];
            [KNSNotification postNotificationName:KMessageHomeNotif object:self];
        }
    }else if([type isEqualToString:@"friendRequest"]||[type isEqualToString:@"friendAdd"]||[type isEqualToString:@"friendCommand"]){
        /*
         data =     {
         avatar = "http://img.welian.com/1418619525311-200-200_x.jpg";
         company = "\U676d\U5dde\U4f20\U9001\U95e8\U7f51\U7edc\U6280\U672f\U6709\U9650\U516c\U53f8";
         created = "2015-03-31 15:25:03";
         msg = "\U6211\U662f\U676d\U5dde\U4f20\U9001\U95e8\U7f51\U7edc\U6280\U672f\U6709\U9650\U516c\U53f8\U7684iOS\U9ad8\U7ea7\U5f00\U53d1\U5de5\U7a0b\U5e08";
         name = "\U6d4b\U8bd511078";
         position = "iOS\U9ad8\U7ea7\U5f00\U53d1\U5de5\U7a0b\U5e08";
         uid = 11078;
         };
         type = friendRequest;
         */
        if(loginUser){
            // 好友消息推送
            [self getNewFriendMessage:dataDic LoginUserId:nil];
        }
        // 振动和声音提示
//        [[MsgPlaySound sharedMsgPlaySound] playSystemShakeAndSoundWithName:@"1"];
    }else if([type isEqualToString:@"IM"]){
        if (loginUser) {
            //接收的聊天消息
            [self getIMGTMessage:userInfo[@"data"]];
        }
        // 振动和声音提示
//        [[MsgPlaySound sharedMsgPlaySound] playSystemShakeAndSoundWithName:@"1"];
    } else if ([type isEqualToString:@"logout"]){
        // 退出登录
        [self logout];
    }else if ([type isEqualToString:@"activeCommand"]){  // 活动推荐
        if (loginUser) {
            [LogInUser setUserIsactivebadge:YES];
            [KNSNotification postNotificationName:KNewactivitNotif object:self];
        }
    }else if ([type isEqualToString:@"investorResult"]){  // 后台认证投资人
        if (loginUser) {
            [LogInUser setUserinvestorauth:[dataDic objectForKey:@"state"]];
            [LogInUser setUserIsinvestorbadge:YES];
            [KNSNotification postNotificationName:KInvestorstateNotif object:self];
        }
    }else if ([type isEqualToString:@"projectComment"]){  // 项目评论
        NSDictionary *infoDic = [userInfo objectForKey:@"data"];
        if (loginUser) {
            [HomeMessage createHomeMessageProjectModel:infoDic];
            //发现
            LogInUser *loginUser = [LogInUser getCurrentLoginUser];
            if (loginUser) {
                NSInteger badge = [loginUser.homemessagebadge integerValue];
                badge++;
                //设置首页
                [LogInUser setUserHomemessagebadge:@(badge)];
            }
            [KNSNotification postNotificationName:KMessageHomeNotif object:self];
        }
    }else if ([type isEqualToString:@"projectCommand"]){  // 新项目推荐
        if (loginUser) {
            //设置有新的项目未查看
            [LogInUser setUserIsProjectBadge:YES];
            [KNSNotification postNotificationName:KProjectstateNotif object:self];
        }
    }
}

// 接受新的好友请求消息
- (NewFriendUser *)getNewFriendMessage:(NSDictionary *)dataDic LoginUserId:(NSNumber *)userId
{
    NSString *type = [dataDic objectForKey:@"type"];
    NewFriendModel *newfrendM = [NewFriendModel objectWithDict:dataDic];
    LogInUser *loginUser = nil;
    if (userId) {
        //接口获取
        loginUser = [LogInUser getLogInUserWithUid:userId];
    }else{
        loginUser = [LogInUser getCurrentLoginUser];;
    }
    //如果为空返回
    if (loginUser == nil) {
        return nil;
    }
    if ([type isEqualToString:@"friendAdd"]) {
        // 别人同意添加我为好友，直接加入好友列表，并改变新的好友里状态为已添加
        [newfrendM setIsAgree:@(1)];
        //操作类型0：添加 1：接受  2:已添加 3：待验证
        [newfrendM setOperateType:@(2)];
        
        //创建本地数据库好友
        MyFriendUser *friendUser = [MyFriendUser createMyFriendNewFriendModel:newfrendM LogInUser:loginUser];
        if (!friendUser) {
            return nil;
        }
        //修改需要添加的用户的状态
        NeedAddUser *needAddUser = [loginUser getNeedAddUserWithUid:friendUser.uid];
        if (needAddUser) {
            [needAddUser updateFriendShip:1];
        }
        
//        //接受后，本地创建一条消息
//        WLMessage *textMessage = [[WLMessage alloc] initWithText:[NSString stringWithFormat:@"我已经通过你的好友请求，现在我们可以开始聊聊创业那些事了"] sender:newfrendM.name timestamp:[NSDate date]];
//        textMessage.avatorUrl = newfrendM.avatar;
//        //是否读取
//        textMessage.isRead = NO;
//        textMessage.sended = @"1";
//        textMessage.bubbleMessageType = WLBubbleMessageTypeReceiving;
//        
//        //更新聊天好友
//        [friendUser updateIsChatStatus:YES];
//        
//        //本地聊天数据库添加
//        ChatMessage *chatMessage = [ChatMessage createChatMessageWithWLMessage:textMessage FriendUser:friendUser];
//        if (chatMessage) {
//            textMessage.msgId = chatMessage.msgId.stringValue;
//        }
//        
//        //更新聊天消息数量
//        [friendUser updateUnReadMessageNumber:@(friendUser.unReadChatMsg.integerValue + 1)];
        
        //更新好友列表
        [KNSNotification postNotificationName:KupdataMyAllFriends object:self];
    }else{
        [newfrendM setIsAgree:@(0)];
        //别人请求加我为好友
        //操作类型0：添加 1：接受  2:已添加 3：待验证
//        MyFriendUser *myFriendUser = [loginUser getMyfriendUserWithUid:newfrendM.uid];
//        if (myFriendUser) {
//            if(myFriendUser.isMyFriend.boolValue){
//                [newfrendM setOperateType:@(1)];
//            }else{
//                //设置不是我的好友
//                [myFriendUser updateIsNotMyFriend];
//                
//                if ([type isEqualToString:@"friendRequest"]) {
//                    //如果是好友，设置为已添加
//                    [newfrendM setOperateType:@(1)];
//                }
//                //推荐的
//                if([type isEqualToString:@"friendCommand"]){
//                    [newfrendM setOperateType:@(0)];
//                }
//            }
//        }else{
            //不是我的好友
            if ([type isEqualToString:@"friendRequest"]) {
                //如果是好友，设置为已添加
                [newfrendM setOperateType:@(1)];
            }
            //推荐的
            if([type isEqualToString:@"friendCommand"]){
                [newfrendM setOperateType:@(0)];
            }
//        }
        
        //判断当前是否已经是好友
        NewFriendUser *newFriendUser = [loginUser getNewFriendUserWithUid:newfrendM.uid];
        if (!([newFriendUser.operateType integerValue]==2)) {
           [LogInUser setUserNewfriendbadge:@(1)];
//            loginUser.newfriendbadge = @(1);
//            [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
            //不是好友，添加角标
//            NSInteger badge = [loginUser.newfriendbadge integerValue];
//            if (!badge) {
//                //设置是否在新的好友通知页面
//                if (![UserDefaults boolForKey:kIsLookAtNewFriendVC]) {
//                    [LogInUser setUserNewfriendbadge:@(1)];
//                }
//            }
        }
    }
    
    //创建的时间
    newfrendM.created = newfrendM.created.length > 0 ? newfrendM.created : [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
   NewFriendUser *newFriendUser = [NewFriendUser createNewFriendUserModel:newfrendM];
    
    //通知刷新页面
    [KNSNotification postNotificationName:KNewFriendNotif object:self];
    return newFriendUser;
}

// 接收聊天消息
- (void)getIMGTMessage:(NSDictionary *)dataDic
{
    //添加数据
    [ChatMessage createReciveMessageWithDict:dataDic];
}

#pragma mark - 退出登录
- (void)logout
{
    if ([self.window.rootViewController isKindOfClass:[LoginGuideController class]])
        return;
    if ([self.window.rootViewController isKindOfClass:[LCNewFeatureVC class]])
        return;
    [self.window setRootViewController:[[LoginGuideController alloc] init]];
    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的账号长时间未登录或在其他设备上登录"  delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
    if ([LogInUser getCurrentLoginUser]) {
        [WeLianClient logoutWithSuccess:^(id resultInfo) {
            
        } Failed:^(NSError *error) {
        }];
    }
    [[RCIM sharedRCIM] logout];
    [[RCIM sharedRCIM] disconnect];
    [LogInUser setUserisNow:NO];
    [UserDefaults removeObjectForKey:kSessionId];
    [UserDefaults setBool:NO forKey:kneedChannelId];
    [UserDefaults removeObjectForKey:kBPushRequestChannelIdKey];
    [UserDefaults synchronize];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    DLog(@"应用程序将要进入非活动状态，即将进入后台");
    LogInUser *logUser = [LogInUser getCurrentLoginUser];
    if (logUser) {
        int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE),@(ConversationType_SYSTEM)]];
        application.applicationIconBadgeNumber = unreadMsgCount+logUser.homemessagebadge.integerValue+logUser.newfriendbadge.integerValue;
    }else{
        application.applicationIconBadgeNumber = 0;
    }
    
    //隐藏活动中的键盘,防止重新进入程序 uitextfiled 偏移问题
//    [[[application keyWindow].rootViewController.view findFirstResponder] resignFirstResponder];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DLog(@"如果应用程序支持后台运行，则应用程序已经进入后台运行");
    // [EXT] 切后台关闭SDK，让SDK第一时间断线，让个推先用APN推送
    [self stopSdk];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DLog(@"应用程序将要进入活动状态，即将进入前台运行");

}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DLog(@"应用程序已进入前台，处于活动状态");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // [EXT] 重新上线
    [self startSdkWith:_appID appKey:_appKey appSecret:_appSecret];
    if (_update == 2){  // 强制更新
        _updataalert =  [[UIAlertView alloc] initWithTitle:@"更新提示" message:_msg  delegate:self cancelButtonTitle:nil otherButtonTitles:@"立即更新", nil];
        [_updataalert show];
    }
    //获取聊天消息记录 和好友请求消息
    [self getServiceChatMsgInfo];
    [KNSNotification postNotificationName:kChangeBannerKey object:self];
    [KNSNotification postNotificationName:KNEWStustUpdate object:self];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    LogInUser *logUser = [LogInUser getCurrentLoginUser];
    if (logUser) {
        int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE),@(ConversationType_SYSTEM)]];
        application.applicationIconBadgeNumber = unreadMsgCount+logUser.homemessagebadge.integerValue+logUser.newfriendbadge.integerValue;
    }else{
        application.applicationIconBadgeNumber = 0;
    }
    
    //数据库操作
    [MagicalRecord cleanUp];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    // 清除内存中的图片缓存
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    [mgr cancelAll];
    [mgr.imageCache clearMemory];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([url.description rangeOfString:@"wechat"].length>0) {
        return  [WXApi handleOpenURL:url delegate:self];
    }
    //自定义唤醒
    if ([[url scheme] isEqualToString:@"welian"])
    {
        DLog(@"handleOpenURL --- :%@",url);
        return YES;
    }
    
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给SDK
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService]
         processOrderWithPaymentResult:url
         standbyCallback:^(NSDictionary *resultDic) {
             NSInteger resultStatus = [resultDic[@"resultStatus"] integerValue];
             if (resultStatus == 9000) {
                 //支付成功
                 [KNSNotification postNotificationName:kAlipayPaySuccess object:nil];
             }else{
                 if ([resultDic[@"memo"] length] > 0) {
                     [UIAlertView showWithTitle:@"系统提示" message:resultDic[@"memo"]];
                 }
             }
             DLog(@"支付结果 result = %@", resultDic);
         }];
        return YES;
    }
    
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回 authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSInteger resultStatus = [resultDic[@"resultStatus"] integerValue];
            if (resultStatus == 9000) {
                //支付成功
                [KNSNotification postNotificationName:kAlipayPaySuccess object:nil];
            }else{
                if ([resultDic[@"memo"] length] > 0) {
                    [UIAlertView showWithTitle:@"系统提示" message:resultDic[@"memo"]];
                }
            }
            DLog(@"支付结果 result = %@", resultDic);
        }];
        return YES;
    }
    // url登陆: wx5e4e9a58776baed3://oauth?code=0212878332e4f9e909d6ec2ec0ea802w&state=123
//    wx5e4e9a58776baed3://platformId=wechat
    if ([url.description rangeOfString:@"wechat"].length>0) {
        return  [WXApi handleOpenURL:url delegate:self];
    }
    
    //自定义链接
    if ([url.scheme isEqualToString:@"welian"]){
        DLog(@"来源位置 sourceApplication --- :%@", sourceApplication);    //来源于哪个app（Bundle identifier）
        DLog(@"description --- :%@", [url description]);  //url scheme
        DLog(@"scheme --- :%@", [url scheme]);  //url scheme
        DLog(@"host ---: %@", [url host]);   //url host  ?之前的
        DLog(@"query ---: %@", [url query]);   //查询串  用“?...”格式访问
        //提醒内容
        [self showInfoWithType:url.host param:[url.query componentsSeparatedByString:@"="]];
//        NSString *text = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        WEAKSELF
//        [UIAlertView bk_showAlertViewWithTitle:@""
//                                       message:text
//                             cancelButtonTitle:@"取消"
//                             otherButtonTitles:@[@"查看"]
//                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                                           if (buttonIndex == 0) {
//                                               return ;
//                                           }else{
//                                               [weakSelf showInfoWithType:url.host param:[url.query componentsSeparatedByString:@"="]];
//                                               
////                                               NSArray *paramArray = [[url query] componentsSeparatedByString:@"&"];
////                                               DLog(@"paramArray: %@", paramArray);
////                                               NSMutableDictionary *paramsDic = [[NSMutableDictionary alloc] initWithCapacity:0];
////                                               for (int i = 0; i < paramArray.count; i++) {
////                                                   NSString *str = paramArray[i];
////                                                   NSArray *keyArray = [str componentsSeparatedByString:@"="];
////                                                   NSString *key = keyArray[0];
////                                                   NSString *value = keyArray[1];
////                                                   [paramsDic setObject:value forKey:key];
////                                                   DLog(@"key:%@ ==== value:%@", key, value);
////                                               }
////                                               UIViewController *currentActivityVC = [NSObject currentRootViewController];
////                                               [currentActivityVC.navigationController pushViewController:<#(UIViewController *)#> animated:<#(BOOL)#>]
//                                           }
//                                       }];
        return YES;
    }
    
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

- (void) onResp:(BaseResp *)resp
{
//    WXSuccess           = 0,    /**< 成功    */
//    WXErrCodeCommon     = -1,   /**< 普通错误类型    */
//    WXErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
//    WXErrCodeSentFail   = -3,   /**< 发送失败    */
//    WXErrCodeAuthDeny   = -4,   /**< 授权失败    */
//    WXErrCodeUnsupport  = -5,   /**< 微信不支持    */
    int64_t delayInSeconds = 1.0;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        if([resp isKindOfClass:[SendMessageToWXResp class]]){
            switch (resp.errCode) {
                case WXSuccess:
                    [WLHUDView showSuccessHUD:@"分享成功！"];
                    break;
                case WXErrCodeCommon:
                    [WLHUDView showErrorHUD:@"分享失败！"];
                    break;
                case WXErrCodeUserCancel:
                    [WLHUDView showErrorHUD:@"取消分享！"];
                    break;
                default:
                    break;
            }
        }
    });
}

- (void)onReq:(BaseReq *)req
{
    DLog(@"%@",req);
}

#pragma mark - GexinSdkDelegate
- (void)GexinSdkDidRegisterClient:(NSString *)clientId
{
    // [4-EXT-1]: 个推SDK已注册
    _sdkStatus = SdkStatusStarted;
    _clientId = clientId;
    [UserDefaults setObject:clientId forKey:kBPushRequestChannelIdKey];
    [UserDefaults synchronize];
    
    [WeLianClient updateclientID];
}

- (void)GexinSdkDidReceivePayload:(NSString *)payloadId fromApplication:(NSString *)appId
{
    // [4]: 收到个推消息
    _payloadId = payloadId;
    
    NSData *payload = [_gexinPusher retrivePayloadById:payloadId];
    NSDictionary *payloadDic = [NSJSONSerialization JSONObjectWithData:payload options:0 error:nil];
    [self inceptMessage:payloadDic];
    DLog(@"-----------个推消息--------%@    \n%d",payloadDic,++_lastPayloadIndex);
}

- (void)GexinSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // [4-EXT]:发送上行消息结果反馈
//    NSString *record = [NSString stringWithFormat:@"Received sendmessage:%@ result:%d", messageId, result];
}

- (void)GexinSdkDidOccurError:(NSError *)error
{
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    DLog(@"%@",[NSString stringWithFormat:@">>>[GexinSdk error]:%@", [error localizedDescription]]);

}

#pragma mark - RCIMConnectionStatusDelegate

/**
 *  网络状态变化。
 *
 *  @param status 网络状态。
 */
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status
{
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的帐号在别的设备上登录，您被迫下线！" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
//        LoginViewController *loginVC = [[LoginViewController alloc] init];
//        // [loginVC defaultLogin];
//        // RCDLoginViewController* loginVC = [storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
//        UINavigationController *_navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
//        self.window.rootViewController = _navi;
    }
}

/**
 接收消息到消息后执行。
 
 @param message 接收到的消息。
 @param left    剩余消息数.
 */
//- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left
//{
//    NSLog(@"接收消息到消息后执行:%@",message);
//    
//    if ([message.objectName isEqualToString:RCCustomMessageTypeIdentifier]) {
//        CustomMessageType *customMessage = (CustomMessageType *)message.content;
//        NSDictionary *newFriendMessage = [customMessage.content jsonObject];
//        [self getNewFriendMessage:newFriendMessage LoginUserId:@(message.targetId.integerValue)];
//        DLog(@"%@",[customMessage.content jsonObject]);
//    }
//    
//}

//显示被其他程序唤醒的页面
- (void)showInfoWithType:(NSString *)type param:(NSArray *)infos
{
    //    1、动态分享的页面:	welian://1?wlid=24204  (动态的id)
    //    2、项目分享的页面: 	welian://2?wlid=11091 (项目的id)
    //    3、活动分享的页面:	welian://3?wlid=1734 （活动的id）
    //    4、创业头条页面:		welian://4?url=http://h5.welian.com/toutiao/i/58 （头条的url）
    //    5、用户邀请页面:		welian://5?wlid=10239   (用户uid)
    //    NSDictionary *infoDic = @{infos[0]:infos[1]};
    //    UIViewController *currentActivityVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    
    UIViewController *currentActivityVC = [NSObject currentRootViewController];
    if ([currentActivityVC isKindOfClass:[MainViewController class]]) {
        currentActivityVC = [(NavViewController *)[(MainViewController *)currentActivityVC selectedViewController] topViewController];
    }
    NSString *info = [infos[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (!info.length) return;
    switch (type.integerValue) {
        case 1:
        {
            //动态
            WLStatusM *statusM = [[WLStatusM alloc] init];
            statusM.fid = @(info.integerValue);
            statusM.topid = @(info.integerValue);
            
            CommentInfoController *commentInfoVC = [[CommentInfoController alloc] init];
            commentInfoVC.statusM = statusM;
            [currentActivityVC.navigationController pushViewController:commentInfoVC animated:YES];
        }
            break;
        case 2:
        {
            //项目
            //查询数据库是否存在
            ProjectInfo *projectInfo = [ProjectInfo getProjectInfoWithPid:@(info.integerValue) Type:@(0)];
            ProjectDetailsViewController *projectDetailVC = nil;
            if (projectInfo) {
                projectDetailVC = [[ProjectDetailsViewController alloc] initWithProjectInfo:projectInfo];
            }else{
                projectDetailVC = [[ProjectDetailsViewController alloc] initWithProjectPid:@(info.integerValue)];
            }
            if (projectDetailVC) {
                [currentActivityVC.navigationController pushViewController:projectDetailVC animated:YES];
            }
        }
            break;
        case 3:
        {
            //活动
            //查询本地有没有该活动
            ActivityInfo *activityInfo = [ActivityInfo getActivityInfoWithActiveId:@(info.integerValue) Type:@(0)];
            ActivityDetailInfoViewController *activityInfoVC = nil;
            if(activityInfo){
                activityInfoVC = [[ActivityDetailInfoViewController alloc] initWithActivityInfo:activityInfo];
            }else{
                activityInfoVC = [[ActivityDetailInfoViewController alloc] initWIthActivityId:@(info.integerValue)];
            }
            if (activityInfoVC) {
                [currentActivityVC.navigationController pushViewController:activityInfoVC animated:YES];
            }
        }
            break;
        case 4:
        {
            //头条
            if(info.length > 0){
                TOWebViewController *webVC = [[TOWebViewController alloc] initWithURLString:info];
                webVC.navigationButtonsHidden = NO;//隐藏底部操作栏目
                webVC.showRightShareBtn = YES;//现实右上角分享按钮
                webVC.isTouTiao = YES;
                
                [currentActivityVC.navigationController pushViewController:webVC animated:YES];
            }
        }
            break;
        case 5:
        {
            //用户邀请
            
        }
            break;
        default:
            break;
    }
}

//获取聊天消息记录 和好友请求消息
- (void)getServiceChatMsgInfo
{
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (loginUser) {
        NSString *localMaxChatNum = [ChatMessage getMaxChatMessageId];//[UserDefaults objectForKey:kMaxChatMessageId];
        NSString *maxChatNum = localMaxChatNum.length > 0 ? localMaxChatNum : @"0";
        [WLHttpTool getServiceMessagesParameterDic:@{@"type":@(0),@"topid":maxChatNum}//0 聊天消息，1 好友请求
                                           success:^(id JSON) {
                                               if ([JSON count] > 0) {
                                                   for(NSDictionary *chatDic in JSON){
//                                                       NSNumber *toUser = chatDic[@"uid"];
//                                                       LogInUser *loginUser = [LogInUser getLogInUserWithUid:toUser];
                                                       //如果本地数据库没有当前登陆用户，不处理
                                                       LogInUser *loginUser = [LogInUser getCurrentLoginUser];
                                                       if (loginUser) {
                                                           [self getIMGTMessage:chatDic];
                                                       }
                                                   }
                                               }
                                               //                                               NSString *maxChatNum = [ChatMessage getMaxChatMessageId];
//                                               [UserDefaults setObject:maxChatNum forKey:kMaxChatMessageId];
                                           } fail:^(NSError *error) {
                                               DLog(@"service chatMsg error:%@",error.description);
                                           }];
        
        //好友请求消息
        /*
         created = "2015-03-19 00:09:41";
         fromuser =     {
             avatar = "http://img.welian.com/1426666616205-200-200_x.jpg";
             name = "\U6d4b\U8bd517912";
             uid = 17912;
         };
         messageid = 95395;
         msg = "\U6211\U662f\U667a\U534e\U56fd\U9645\U63a7\U80a1\U96c6\U56e2\U6709\U9650\U516c\U53f8\U7684\U521b\U59cb\U5408\U4f19\U4eba\Uff0c\U60a8\U597d";
         type = friendRequest;
         uid = 10019;
         */
        LogInUser *loginUser = [LogInUser getCurrentLoginUser];
        if (!loginUser) {
            return;
        }
        NSString *localMaxNewFriendId = [loginUser getMaxNewFriendUserMessageId];//[UserDefaults objectForKey:kMaxNewFriendId];
        NSString *maxNewFriendId = localMaxNewFriendId.length > 0 ? localMaxNewFriendId : @"0";
        [WLHttpTool getServiceMessagesParameterDic:@{@"type":@(1),@"topid":maxNewFriendId}//0 聊天消息，1 好友请求
                                           success:^(id JSON) {
                                               if ([JSON count] > 0) {
                                                   for(NSDictionary *newFriendDic in JSON){
                                                       NSMutableDictionary *dictData = [NSMutableDictionary dictionaryWithDictionary:newFriendDic];
                                                       NSNumber *toUser = dictData[@"uid"];
//                                                       LogInUser *loginUser = [LogInUser getLogInUserWithUid:toUser];
                                                       //如果本地数据库没有当前登陆用户，不处理
                                                       LogInUser *loginUser = [LogInUser getCurrentLoginUser];
                                                       if (loginUser) {
                                                           //设置请求方式
                                                           [dictData setObject:@"friendRequest" forKey:@"type"];
                                                           //设置用户信息
                                                           NSDictionary *userDict = dictData[@"fromuser"];
                                                           [dictData setObject:userDict[@"uid"] forKey:@"uid"];
                                                           [dictData setObject:userDict[@"name"] forKey:@"name"];
                                                           [dictData setObject:userDict[@"avatar"] forKey:@"avatar"];
                                                           
                                                           //别人请求的
                                                           [self getNewFriendMessage:dictData LoginUserId:toUser];
                                                       }
                                                   }
                                               }
//                                               //保存最新的最大id
//                                               NSString *maxNewFriendId = [loginUser getMaxNewFriendUserMessageId];
//                                               [UserDefaults setObject:maxNewFriendId forKey:kMaxNewFriendId];
                                           } fail:^(NSError *error) {
                                               DLog(@"service friendMsg error:%@",error.description);
                                           }];
    }
}

@end
