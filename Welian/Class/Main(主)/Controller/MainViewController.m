//
//  MainViewController.m
//  Welian
//
//  Created by dong on 14-9-10.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "MainViewController.h"
#import "HomeController.h"
#import "FindViewController.h"
#import "MeViewController.h"
#import "NavViewController.h"
#import "MyFriendsController.h"
#import "ChatListViewController.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ChatMessageController.h"
#import "MessagesViewController.h"
#import "LogInUser.h"
#import "LocationTool.h"
#import "WLLocationHelper.h"

#import "MyFriendUser.h"
#import "NewFriendUser.h"
#import "MJExtension.h"

//#import "LCNewFeatureVC.h"

@interface MainViewController () <UINavigationControllerDelegate>
{
    UITabBarItem *homeItem;
    UITabBarItem *selectItem;
    UITabBarItem *chatMessageItem;
    UITabBarItem *findItem;
    UITabBarItem *meItem;
    HomeController *homeVC;
}

@property (strong,nonatomic) CLGeocoder* geocoder;

@end

@implementation MainViewController

single_implementation(MainViewController)

- (void)dealloc
{
    [KNSNotification removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        [WeLianClient updateclientID];
    }
    return self;
}

- (void)loadNewStustupdata
{
    if ([UserDefaults objectForKey:kSessionId]) {
        LogInUser *loginUser = [LogInUser getCurrentLoginUser];
        if (loginUser) {
            //获取最新动态数量
            [WeLianClient getNewFeedCountsWithID:loginUser.firststustid ? : @(0)
                                            Time:loginUser.lastGetTime.length > 0 ? loginUser.lastGetTime : @""
                                         Success:^(id resultInfo) {
                                             IGetNewFeedResultModel *newFeedModel = resultInfo;
                                             //保存数据
                                             [LogInUser setNewFeedCountInfo:newFeedModel];
                                             
                                             [self updataItembadge];
                                         } Failed:^(NSError *error) {
                                             
                                         }];
        }
    }
}


// 根据更新信息设置 提示角标
- (void)updataItembadge
{
    LogInUser *logUser = [LogInUser getCurrentLoginUser];
    //更新消息页面角标
    [self updateChatMessageBadge];
    
    // 首页 创业圈角标
    if (logUser.newstustcount.integerValue && !logUser.homemessagebadge.integerValue) {
        [homeItem setImage:[[UIImage imageNamed:@"tabbar_home_prompt"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [homeItem setSelectedImage:[[UIImage imageNamed:@"tabbar_home_selected_prompt"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }else{
        [homeItem setImage:[UIImage imageNamed:@"tabbar_home"]];
        [homeItem setSelectedImage:[UIImage imageNamed:@"tabbar_home_selected"]];
    }
    if (logUser.homemessagebadge.integerValue) {
        homeItem.badgeValue = logUser.homemessagebadge.stringValue;
    }else{
        homeItem.badgeValue = nil;
    }
    
    /// 有新的活动或者新的项目
    if (logUser.isactivebadge.boolValue || logUser.isprojectbadge.boolValue || logUser.istoutiaobadge.boolValue || logUser.isfindinvestorbadge.boolValue) {
        [findItem setImage:[[UIImage imageNamed:@"tabbar_discovery_prompt"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [findItem setSelectedImage:[[UIImage imageNamed:@"tabbar_discovery_selected_prompt"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }else{
        [findItem setImage:[UIImage imageNamed:@"tabbar_discovery"]];
        [findItem setSelectedImage:[UIImage imageNamed:@"tabbar_discovery_selected"]];
    }
    
    // 我的投资人认证状态改变
    if (logUser.isinvestorbadge.boolValue) {
        [meItem setImage:[[UIImage imageNamed:@"tabbar_friend_prompt"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [meItem setSelectedImage:[[UIImage imageNamed:@"tabbar_friend_selected_prompt"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }else{
        [meItem setImage:[UIImage imageNamed:@"tabbar_me"]];
        [meItem setSelectedImage:[UIImage imageNamed:@"tabbar_me_selected"]];
    }
}

//更新消息数量改变
- (void)updateChatMessageBadge
{
    dispatch_async(dispatch_get_main_queue(), ^{
        LogInUser *logUser = [LogInUser getCurrentLoginUser];
        NSInteger messageCount = [[RCIMClient sharedRCIMClient] getTotalUnreadCount]+logUser.newfriendbadge.integerValue;
        if (messageCount > 0) {
            chatMessageItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)messageCount];
        }else{
            chatMessageItem.badgeValue = nil;
        }
        [UIApplication sharedApplication].applicationIconBadgeNumber = messageCount+logUser.homemessagebadge.integerValue;
    });
}

//设置选择的为消息列表页面
- (void)changeTapToChatList:(NSNotification *)notification
{
    self.selectedIndex = 2;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [WeLianClient updateclientID];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(updateChatMessageBadge)
//                                                 name:RCKitDispatchMessageNotification
//                                               object:nil];
    // 有新好友通知
    [KNSNotification addObserver:self selector:@selector(updateChatMessageBadge) name:KNewFriendNotif object:nil];
    
    // 有新动态通知
    [KNSNotification addObserver:self selector:@selector(loadNewStustupdata) name:KNEWStustUpdate object:nil];
    
    // 首页动态消息通知
   [KNSNotification addObserver:self selector:@selector(updataItembadge) name:KMessageHomeNotif object:nil];
    
    //添加聊天用户改变监听
    [KNSNotification addObserver:self selector:@selector(updateChatMessageBadge) name:kChatMsgNumChanged object:nil];
    [KNSNotification addObserver:self selector:@selector(updateChatMessageBadge) name:kUpdateMainMessageBadge object:nil];
    
    //如果是从好友列表进入聊天，首页变换
    [KNSNotification addObserver:self selector:@selector(changeTapToChatList:) name:kChangeTapToChatList object:nil];
    
    // 我的认证投资人状态改变
    [KNSNotification addObserver:self selector:@selector(updataItembadge) name:KInvestorstateNotif object:nil];
    
    // 新的活动提示
    [KNSNotification addObserver:self selector:@selector(updataItembadge) name:KNewactivitNotif object:nil];
    // 新的项目提示
    [KNSNotification addObserver:self selector:@selector(updataItembadge) name:KProjectstateNotif object:nil];
    
    [[UITextField appearance] setTintColor:KBasesColor];
    [[UITextView appearance] setTintColor:KBasesColor];

    LogInUser *mode = [LogInUser getCurrentLoginUser];
    if(mode){
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:mode.avatar] options:SDWebImageRetryFailed|SDWebImageLowPriority progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            NSString *avatarStr = [UIImageJPEGRepresentation(image, 0.5) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            [UserDefaults setObject:avatarStr forKey:@"icon"];
        }];
    }
    
    
    // 首页
    homeItem = [self itemWithTitle:@"创业圈" imageStr:@"tabbar_home" selectedImageStr:@"tabbar_home_selected"];
//    [homeItem setBadgeValue:[UserDefaults objectForKey:KMessagebadge]];
    homeVC = [[HomeController alloc] initWithUid:nil];
    NavViewController *homeNav = [[NavViewController alloc] initWithRootViewController:homeVC];
    [homeVC.navigationItem setTitle:@"创业圈"];
    [homeNav setDelegate:self];
    [homeNav setTabBarItem:homeItem];
//    homeItem.badgeValue = mode.homemessagebadge.stringValue;
    
//    // 聊天消息
//    chatMessageItem = [self itemWithTitle:@"消息" imageStr:@"tabbar_chat" selectedImageStr:@"tabbar_chat_selected"];
//    MessagesViewController *chatMessageVC = [[MessagesViewController alloc] init];
//    NavViewController *chatMeeageNav = [[NavViewController alloc] initWithRootViewController:chatMessageVC];
//    [chatMessageVC.navigationItem setTitle:@"消息"];
//    [chatMeeageNav setDelegate:self];
//    [chatMeeageNav setTabBarItem:chatMessageItem];
    // 融云
    chatMessageItem = [self itemWithTitle:@"聊天" imageStr:@"tabbar_chat" selectedImageStr:@"tabbar_chat_selected"];
    ChatListViewController *chatListVC = [[ChatListViewController alloc] init];
    NavViewController *ryMeeageNav = [[NavViewController alloc] initWithRootViewController:chatListVC];
    [ryMeeageNav setDelegate:self];
    
    [ryMeeageNav setTabBarItem:chatMessageItem];
    
    
    // 发现
    findItem = [self itemWithTitle:@"发现" imageStr:@"tabbar_discovery" selectedImageStr:@"tabbar_discovery_selected"];
    FindViewController *findVC = [[FindViewController alloc] init];
    NavViewController *findNav = [[NavViewController alloc] initWithRootViewController:findVC];
    [findNav setDelegate:self];
    [findVC.navigationItem setTitle:@"发现"];
    [findNav setTabBarItem:findItem];
    
    // 我
    meItem = [self itemWithTitle:@"我" imageStr:@"tabbar_me" selectedImageStr:@"tabbar_me_selected"];
    MeViewController *meVC = [[MeViewController alloc] init];
    NavViewController *meNav = [[NavViewController alloc] initWithRootViewController:meVC];
    [meNav setDelegate:self];
    [meNav setTabBarItem:meItem];
    
    //设置底部导航
    [self setViewControllers:@[homeNav,findNav,ryMeeageNav,meNav]];
    [self.tabBar setSelectedImageTintColor:KBasesColor];

    selectItem = homeItem;
    [self updataItembadge];
    
    // 定位
    [self getCityLocationInfo];
}

- (CLGeocoder*)geocoder
{
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

//定位
- (void)getCityLocationInfo
{
    [[LocationTool sharedLocationTool] statLocationMy];
    WEAKSELF
    [[LocationTool sharedLocationTool] setUserLocationBlock:^(BMKUserLocation *userLocation){
        //城市定位
        [weakSelf getLoactionCityInfoWith:userLocation];
        CLLocationCoordinate2D coord2D = userLocation.location.coordinate;
        NSString *latitude = [NSString stringWithFormat:@"%f",coord2D.latitude];
        NSString *longitude = [NSString stringWithFormat:@"%f",coord2D.longitude];
        
        [WeLianClient changeUserLocationWithLatitude:latitude
                                          Longtitude:longitude
                                             Success:^(id resultInfo) {
                                                 
                                             } Failed:^(NSError *error) {
                                                 
                                             }];
        
    }];
}

- (void)getLoactionCityInfoWith:(BMKUserLocation *)userLocation
{
//  北京 116.300209,39.920026（北京市市辖区）    上海：121.391313,31.240517  台湾：(台湾省)120.434915,22.983245  121.603144,24.952727  香港：114.178428,22.274236（香港特別行政區）  澳门：113.566718,22.154318(澳门特别性质区)  和田区：79.909829,37.124486（和田地区）
    DLog(@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f",userLocation.location.coordinate.longitude,userLocation.location.coordinate.latitude,userLocation.location.altitude,userLocation.location.course,userLocation.location.speed);
    [self.geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray* placemarks, NSError* error) {
        if(!error){
            if (placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks firstObject];
                if (placemark) {
                    NSDictionary *addressDictionary = placemark.addressDictionary;
                    //            NSArray *formattedAddressLines = [addressDictionary valueForKey:@"FormattedAddressLines"];
                    //            NSString *geoLocations = [formattedAddressLines lastObject];
                    if (addressDictionary != nil) {
                        NSString *cityStr = addressDictionary[@"City"];//市
                        NSString *stateStr =  addressDictionary[@"State"];//省
                        
                        DLog(@"当前城市：%@ --省: %@-- placemark.locality:%@",cityStr,stateStr,placemark.locality);
                        
                        NSString * city = cityStr ? cityStr : stateStr;
                        if(city.length > 0){
//                            if ([cityStr containsString:@"市"]) {
//                                //市
//                                NSRange range = [cityStr rangeOfString:@"市"]; //现获取要截取的字符串位置
//                                city = [cityStr substringToIndex:range.location]; //截取字符串
//                            }else if([cityStr containsString:@"省"]){
//                                //省
//                                NSRange range = [cityStr rangeOfString:@"市"]; //现获取要截取的字符串位置
//                                city = [cityStr substringToIndex:range.location]; //截取字符串
//                            }else if ([cityStr containsString:@"特别行政"]){
//                                //特别行政区
//                                NSRange range = [cityStr rangeOfString:@"特别行政"]; //现获取要截取的字符串位置
//                                city = [cityStr substringToIndex:range.location]; //截取字符串
//                            }else if([cityStr containsString:@""]){
//                            
//                            }
                            //定位的城市
                            [UserDefaults setObject:city forKey:kLocationCity];
                        }else{
                            //定位的城市
                            [UserDefaults setObject:@"" forKey:kLocationCity];
                        }
                    }
                }
            }
        }
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (selectItem == homeItem && item == homeItem) {
        [homeVC beginRefreshing];
    }
    selectItem = item;
}

- (UITabBarItem*)itemWithTitle:(NSString *)title imageStr:(NSString *)imageStr selectedImageStr:(NSString *)selectedImageStr
{
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:imageStr] selectedImage:[UIImage imageNamed:selectedImageStr]];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName :KBasesColor,NSFontAttributeName:kNormal12Font} forState:UIControlStateSelected];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor],NSFontAttributeName:kNormal12Font} forState:UIControlStateNormal];
    return item;
}

@end
