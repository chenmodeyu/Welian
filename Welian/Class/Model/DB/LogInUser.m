//
//  LogInUser.m
//  Welian
//
//  Created by dong on 14/12/24.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "LogInUser.h"
#import "CompanyModel.h"
#import "FriendsFriendUser.h"
#import "MyFriendUser.h"
#import "NewFriendUser.h"
#import "SchoolModel.h"
#import "HomeMessage.h"
#import "NeedAddUser.h"
#import "InvestIndustry.h"
#import "InvestStages.h"
#import "InvestItems.h"
//#import "AppDelegate.h"

@implementation LogInUser

@dynamic isNow;
@dynamic checkcode;
@dynamic sessionid;
@dynamic url;
@dynamic auth;
@dynamic openid;
@dynamic unionid;

@dynamic firststustid;
@dynamic newstustcount;
@dynamic homemessagebadge;
@dynamic investorcount;
@dynamic projectcount;
@dynamic isprojectbadge;
@dynamic isactivebadge;
@dynamic isinvestorbadge;
@dynamic newfriendbadge;
@dynamic activecount;
@dynamic toutiaocount;
@dynamic istoutiaobadge;
@dynamic lastGetTime;
@dynamic isfindinvestorbadge;
@dynamic toutiaonewcount;

@dynamic rsCompanys;
@dynamic rsSchools;
@dynamic rsMyFriends;
@dynamic rsFriendsFriends;
@dynamic rsNewFriends;
@dynamic rsHomeMessages;
@dynamic rsInvestIndustrys;
@dynamic rsInvestItems;
@dynamic rsInvestStages;
@dynamic rsNeedAddUsers;
@dynamic rsProjectInfos;
@dynamic rsActivityInfos;
@dynamic rsTouTiaoInfos;
@dynamic rsProjectClassInfos;
@dynamic rsChatRoomInfos;


//** 获取当前登陆的账户 **//
+ (LogInUser *)getCurrentLoginUser
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"isNow",@(YES)];
    LogInUser *loginUser = [LogInUser MR_findFirstWithPredicate:pre];
    return loginUser;
}

//创建新收据
+ (LogInUser *)createLogInUserModel:(ILoginUserModel *)userInfoM
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"uid",userInfoM.uid];
    LogInUser *loginuser = [LogInUser MR_findFirstWithPredicate:pre];
    if (!loginuser) {
        loginuser = [LogInUser MR_createEntity];
    }
    loginuser.uid = userInfoM.uid;
    loginuser.mobile = userInfoM.mobile;
    loginuser.position = userInfoM.position;
    loginuser.provinceid = userInfoM.provinceid;
    loginuser.provincename = userInfoM.provincename;
    loginuser.cityid = userInfoM.cityid;
    loginuser.cityname = userInfoM.cityname;
    loginuser.friendship = userInfoM.friendship;
    loginuser.shareurl = userInfoM.shareurl;
    loginuser.avatar = userInfoM.avatar;
    loginuser.name = userInfoM.name;
    loginuser.address = userInfoM.address;
    loginuser.email = userInfoM.email;
    loginuser.investorauth = userInfoM.investorauth;
    loginuser.company = userInfoM.company;
    loginuser.inviteurl = userInfoM.inviteurl;
    loginuser.isNow = @(YES);
    loginuser.friendcount = userInfoM.friendcount;
    loginuser.feedcount = userInfoM.feedcount;
    loginuser.friend2count = userInfoM.friend2count;
    loginuser.checked = userInfoM.checked;
    loginuser.samefriendscount = userInfoM.samefriendscount;
    loginuser.rongCloudToken = userInfoM.token;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return loginuser;
}

+ (LogInUser *)updateLoginUserWithModel:(ILoginUserModel *)userInfoM
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"uid",userInfoM.uid];
    LogInUser *loginuser = [LogInUser MR_findFirstWithPredicate:pre];
    loginuser.uid = userInfoM.uid;
    loginuser.mobile = userInfoM.mobile;
    loginuser.position = userInfoM.position;
    loginuser.provinceid = userInfoM.provinceid;
    loginuser.provincename = userInfoM.provincename;
    loginuser.cityid = userInfoM.cityid;
    loginuser.cityname = userInfoM.cityname;
    loginuser.friendship = userInfoM.friendship;
    loginuser.shareurl = userInfoM.shareurl;
    loginuser.avatar = userInfoM.avatar;
    loginuser.name = userInfoM.name;
    loginuser.address = userInfoM.address;
    loginuser.email = userInfoM.email;
    loginuser.investorauth = userInfoM.investorauth;
//    loginuser.startupauth = userInfoM.startupauth;
    loginuser.company = userInfoM.company;
//    loginuser.checkcode = userInfoM.checkcode;
//    loginuser.sessionid = userInfoM.sessionid;
    loginuser.inviteurl = userInfoM.inviteurl;
//    loginuser.isNow = @(1);
    loginuser.friendcount = userInfoM.friendcount;
    loginuser.feedcount = userInfoM.feedcount;
    loginuser.friend2count = userInfoM.friend2count;
    loginuser.checked = userInfoM.checked;
    loginuser.samefriendscount = userInfoM.samefriendscount;
    [[loginuser managedObjectContext] MR_saveToPersistentStoreAndWait];
    return loginuser;
}

////创建新收据
//+ (LogInUser *)createLogInUserModel:(UserInfoModel *)userInfoM
//{
//    LogInUser *loginuser = [LogInUser getLogInUserWithUid:userInfoM.uid];
//    if (!loginuser) {
//        loginuser = [LogInUser create];
//    }
//    loginuser.uid = userInfoM.uid;
//    loginuser.mobile = userInfoM.mobile;
//    loginuser.position = userInfoM.position;
//    loginuser.provinceid = userInfoM.provinceid;
//    loginuser.provincename = userInfoM.provincename;
//    loginuser.cityid = userInfoM.cityid;
//    loginuser.cityname = userInfoM.cityname;
//    loginuser.friendship = userInfoM.friendship;
//    loginuser.shareurl = userInfoM.shareurl;
//    loginuser.avatar = userInfoM.avatar;
//    loginuser.name = userInfoM.name;
//    loginuser.address = userInfoM.address;
//    loginuser.email = userInfoM.email;
//    loginuser.investorauth = userInfoM.investorauth;
//    loginuser.startupauth = userInfoM.startupauth;
//    loginuser.company = userInfoM.company;
//    loginuser.checkcode = userInfoM.checkcode;
//    loginuser.sessionid = userInfoM.sessionid;
//    loginuser.inviteurl = userInfoM.inviteurl;
//    loginuser.isNow = @(1);
//    [MOC save];
//    return loginuser;
//}


+ (void)setUserFirststustid:(NSNumber *)firststustid
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.firststustid = firststustid;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}
+ (void)setUserNewstustcount:(NSNumber *)newstustcount
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.newstustcount = newstustcount;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}
+ (void)setUserHomemessagebadge:(NSNumber *)homemessagebadge
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.homemessagebadge = homemessagebadge;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}
+ (void)setUserInvestorcount:(NSNumber *)investorcount
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.investorcount = investorcount;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}
+ (void)setUserProjectcount:(NSNumber *)projectcount
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.projectcount = projectcount;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}
+ (void)setUserActivecount:(NSNumber *)activecount
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.activecount = activecount;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}
+ (void)updateToutiaoCount:(NSNumber *)count
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.toutiaocount = count;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)updateToutiaoNewCount:(NSNumber *)count
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.toutiaonewcount = count;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}
+ (void)updateToutiaoBadge:(BOOL)badge
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.istoutiaobadge = @(badge);
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}
+ (void)updateFindInvestorBadge:(BOOL)badge
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.isfindinvestorbadge = @(badge);
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}
+ (void)setUserIsactivebadge:(BOOL)isactivebadge
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.isactivebadge = @(isactivebadge);
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}
+ (void)setUserIsinvestorbadge:(BOOL)isinvestorbadge
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.isinvestorbadge = @(isinvestorbadge);
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}
+ (void)setUserIsProjectBadge:(BOOL)isprojectbadge
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.isprojectbadge = @(isprojectbadge);
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}
+ (void)setUserNewfriendbadge:(NSNumber *)newfriendbadge
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.newfriendbadge = newfriendbadge;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setuserRongCloudToken:(NSString *)rongCloudToken
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.rongCloudToken = rongCloudToken;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

//设置新的动态、项目、活动、头条等数量
+ (void)setNewFeedCountInfo:(IGetNewFeedResultModel *)newFeedModel
{
    //设置发现中的对应数量信息
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.lastGetTime = newFeedModel.time;
    loginUser.newstustcount = newFeedModel.feedcount;
    loginUser.activecount = newFeedModel.activecount;
    loginUser.investorcount = newFeedModel.investorcount;
    loginUser.projectcount = newFeedModel.projectcount;
    loginUser.toutiaocount = newFeedModel.toutiaocount;
    loginUser.toutiaonewcount = @(loginUser.toutiaonewcount.integerValue + newFeedModel.toutiaonewcount.integerValue);
    //是否有新的信息
    loginUser.isactivebadge = loginUser.isactivebadge.boolValue ? @(YES): (newFeedModel.activenewcount.integerValue > 0 ? @(YES) : @(NO));
    loginUser.isprojectbadge = loginUser.isprojectbadge.boolValue ? @(YES): (newFeedModel.projectnewcount.integerValue > 0 ? @(YES) : @(NO));
    loginUser.istoutiaobadge = loginUser.istoutiaobadge.boolValue ? @(YES): (newFeedModel.toutiaonewcount.integerValue > 0 ? @(YES) : @(NO));
    //投资人
    loginUser.isfindinvestorbadge = loginUser.isfindinvestorbadge.boolValue ? @(YES): (newFeedModel.investornewcount.integerValue > 0 ? @(YES) : @(NO));
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
    
    //通知刷新头条提醒
    [KNSNotification postNotificationName:KNewTouTiaoNotif object:nil];
    //通知刷新活动
    [KNSNotification postNotificationName:KNewactivitNotif object:self];
    //通知新的项目
    [KNSNotification postNotificationName:KProjectstateNotif object:self];
}


+ (void)setUserUid:(NSNumber *)uid
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.uid = uid;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserMobile:(NSString *)mobile
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.mobile = mobile;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserChecked:(NSNumber *)checked
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.checked = checked;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserPosition:(NSString*)position
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.position = position;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserProvinceid:(NSNumber *)provinceid
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.provinceid = provinceid;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserProvincename:(NSString *)provincename
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.provincename = provincename;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserCityid:(NSNumber *)cityid
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.cityid = cityid;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserCityname:(NSString *)cityname
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.cityname = cityname;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserFriendship:(NSNumber *)friendship
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.friendship = friendship;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserShareurl:(NSString *)shareurl
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.shareurl = shareurl;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserAvatar:(NSString *)avatar
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.avatar = avatar;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserName:(NSString *)name
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.name = name;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserAddress:(NSString *)address
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.address = address;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserEmail:(NSString *)email
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.email = email;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserinvestorauth:(NSNumber *)investorauth
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.investorauth = investorauth;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserstartupauth:(NSNumber *)startupauth
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.startupauth = startupauth;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUsercompany:(NSString *)company
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.company = company;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserisNow:(BOOL)isnow
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.isNow = @(isnow);
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUserUrl:(NSString *)url
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.url = url;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

+ (void)setUseropenid:(NSString *)openid
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.openid = openid;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}
+ (void)setUserunionid:(NSString *)unionid
{
    LogInUser *loginUser = [self getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.unionid = unionid;
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
}

//通过uid查询
+ (LogInUser *)getLogInUserWithUid:(NSNumber*)uid
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"uid",uid];
    LogInUser *loginuser = [LogInUser MR_findFirstWithPredicate:pre];
    return loginuser;
}

//获取最新的履历信息
- (NSString *)displayMyNewLvliInfo
{
    // 工作经历列表
    NSMutableArray *lvliArray = [NSMutableArray array];
    NSArray *usercompanys = self.rsCompanys.allObjects;
    [lvliArray addObjectsFromArray:usercompanys];
    
    // 教育经历列表
    NSArray *userschools = self.rsSchools.allObjects;
    [lvliArray addObjectsFromArray:userschools];
    
    NSString *detailInfo = @"";
    if(lvliArray.count > 0)
    {
        NSSortDescriptor *sortByMonth= [NSSortDescriptor sortDescriptorWithKey:@"startmonth" ascending:NO];
        [lvliArray sortUsingDescriptors:[NSArray arrayWithObject:sortByMonth]];
        NSSortDescriptor *sortByYear= [NSSortDescriptor sortDescriptorWithKey:@"startyear" ascending:NO];
        [lvliArray sortUsingDescriptors:[NSArray arrayWithObject:sortByYear]];
        NSObject *info = [lvliArray firstObject];
        
        if ([info isKindOfClass:[CompanyModel class]]) {
            CompanyModel *result = (CompanyModel *)info;
            detailInfo = [NSString stringWithFormat:@"%@ %@",result.jobname.length ? result.jobname : @"",result.companyname];
        }else{
            SchoolModel *result = (SchoolModel *)info;
            detailInfo = [NSString stringWithFormat:@"%@ %@",result.specialtyname.length ? result.specialtyname : @"",result.schoolname];
        }
    }
    return detailInfo;
}

//获取正在聊天的好友列表
- (NSArray *)chatUsers
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLogInUser",self,@"isChatNow",@(YES)];
    NSArray *users = [MyFriendUser MR_findAllSortedBy:@"lastChatTime" ascending:NO withPredicate:pre];
    return users;
}

//获取新的好友列表
- (NSArray *)allMyNewFriends
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"rsLogInUser",self];
    NSArray *allFriends = [NewFriendUser MR_findAllSortedBy:@"created" ascending:NO withPredicate:pre];
    return allFriends;
}

//所有未读取的聊天消息数量
- (NSInteger)allUnReadChatMessageNum
{
    NSInteger allCount = 0;
    for (MyFriendUser *friendUser in self.rsMyFriends.allObjects) {
        allCount += friendUser.unReadChatMsg.integerValue;//[friendUser unReadChatMessageNum];
    }
    return allCount;
}

//更新所有新的好友中，待验证的状态为添加状态
- (void)updateAllNewFriendsOperateStatus
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLogInUser",self,@"operateType",@(3)];
    NSArray *waitNewFriends = [NewFriendUser MR_findAllWithPredicate:pre inContext:[self managedObjectContext]];
    for (NewFriendUser *newFriendUser in waitNewFriends) {
        [newFriendUser updateOperateType:0];
    }
}

//更新所有添加好友中，待验证的状态为添加状态
- (void)updateAllNeedAddFriendOperateStatus
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLoginUser",self,@"friendship",@"4"];
    NSArray *waitAddFriends = [NeedAddUser MR_findAllWithPredicate:pre inContext:[self managedObjectContext]];
    for (NeedAddUser *needAdd in waitAddFriends) {
        [needAdd updateFriendShip:2];
    }
}

//---------------------  我的好友  MyFriendUser操作 ---------------------/
// //通过uid查询
- (MyFriendUser *)getMyfriendUserWithUid:(NSNumber *)uid
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLogInUser",self,@"uid",uid];
    MyFriendUser *myFriend = [MyFriendUser MR_findFirstWithPredicate:pre inContext:[self managedObjectContext]];
    return myFriend;
}

// 所有好友，除当前聊天好友
- (NSArray *)getAllMyFriendUsersNoChatUser
{
    NSString *chatUid = [UserDefaults stringForKey:@"Chat_Share_Friend_Uid"];
    NSPredicate *pre;
    if (chatUid.length > 0) {
        //从聊天进入
        pre = [NSPredicate predicateWithFormat:@"rsLogInUser == %@ && uid > %@ && uid != %@ && %K == %@",self,@(100),@(chatUid.integerValue),@"isMyFriend",@(YES)];
    }else{
        //其他地方进入
        pre = [NSPredicate predicateWithFormat:@"rsLogInUser == %@ && uid > %@ && %K == %@",self,@(100),@"isMyFriend",@(YES)];
    }
    
    NSArray *allFriends = [MyFriendUser MR_findAllWithPredicate:pre inContext:[NSManagedObjectContext MR_defaultContext]];
    return allFriends;
}


// 所有好友
- (NSArray *)getAllMyFriendUsers
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"rsLogInUser == %@ && uid > %@ && %K == %@",self,@(100),@"isMyFriend",@(YES)];
    NSArray *allFriends = [MyFriendUser MR_findAllWithPredicate:pre inContext:[NSManagedObjectContext MR_defaultContext]];
    return allFriends;
}

//---------------------- SchoolModel ------------
//通过ucid查询
- (SchoolModel *)getSchoolModelWithUcid:(NSNumber*)usid
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLogInUser",self,@"usid",usid];
    SchoolModel *schoolM = [SchoolModel MR_findFirstWithPredicate:pre inContext:[self managedObjectContext]];
    return schoolM;
}

//---------------------- CompanyModel ------------
//通过ucid查询
- (CompanyModel *)getCompanyModelWithUcid:(NSNumber*)ucid
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLogInUser",self,@"ucid",ucid];
    CompanyModel *company = [CompanyModel MR_findFirstWithPredicate:pre inContext:[self managedObjectContext]];
    return company;
}

// 查询所有数据并返回
- (NSArray *)allCompanyModels
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"rsLogInUser",self];
    NSArray *allCompanys = [CompanyModel MR_findAllWithPredicate:pre inContext:[self managedObjectContext]];
    return allCompanys;
}

//---------------------- NewFriendUser -------
- (NewFriendUser *)getNewFriendUserWithUid:(NSNumber *)uid
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLogInUser",self,@"uid",uid];
    NewFriendUser *newFriend = [NewFriendUser MR_findFirstWithPredicate:pre inContext:[self managedObjectContext]];
    return newFriend;
}

//获取当前最大的新的好友的messageID
- (NSString *)getMaxNewFriendUserMessageId
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"rsLogInUser",self];
    NSArray *NewFriendUsers = [NewFriendUser MR_findAllWithPredicate:pre inContext:self.managedObjectContext];
    NewFriendUser *newFriend = nil;
    if (NewFriendUsers.count > 0 && NewFriendUsers != nil) {
        NSArray *sortMessages = [NewFriendUsers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj1 messageid] integerValue] > [[obj2 messageid] integerValue];
        }];
        newFriend = [sortMessages lastObject];
    }
    
    if (newFriend) {
        if (newFriend.messageid.length > 0) {
            return newFriend.messageid;
        }else{
            return @"0";
        }
    }else{
        return @"0";
    }
}

//---------------------HomeMessage----------
// //通过commentid查询
- (HomeMessage *)getHomeMessageWithUid:(NSNumber *)commentid
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLogInUser",self,@"commentid",commentid];
    HomeMessage *homeMessage = [HomeMessage MR_findFirstWithPredicate:pre inContext:[self managedObjectContext]];
    return homeMessage;
}

// 获取未读消息
- (NSArray *)getIsLookNotMessages
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLogInUser",self,@"isLook",@(NO)];
    NSArray *homearray = [HomeMessage MR_findAllWithPredicate:pre inContext:[self managedObjectContext]];
    for (HomeMessage *meee  in homearray) {
        meee.isLook = @(YES);
    }
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    return homearray;
    
}

//改变所有未读消息状态为已读
- (void)updateALLNotLookMessages
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLogInUser",self,@"isLook",@(NO)];
    NSArray *homearray = [HomeMessage MR_findAllWithPredicate:pre inContext:[self managedObjectContext]];
    for (HomeMessage *meee in homearray) {
        meee.isLook = @(YES);
    }
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
}

// 获取全部消息
- (NSArray *)getAllMessages
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"rsLogInUser",self];
    NSArray *allHomeMessages = [HomeMessage MR_findAllSortedBy:@"created" ascending:NO withPredicate:pre];
    return allHomeMessages;
}

//--------------------InvestIndustry-----------
// //通过item查询
- (InvestIndustry *)getInvestIndustryWithName:(NSString *)name
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLogInUser",self,@"industryname",name];
    InvestIndustry *investIndustry = [InvestIndustry MR_findFirstWithPredicate:pre inContext:[self managedObjectContext]];
    return investIndustry;
}

//--------------------InvestStages-------------
// //通过item查询
- (InvestStages *)getInvestStagesWithStage:(NSString *)item
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLogInUser",self,@"stagename",item];
    InvestStages *investStage = [InvestStages MR_findFirstWithPredicate:pre inContext:[self managedObjectContext]];
    return investStage;
}

//--------------------InvestItems--------------
// 获取全部消息
- (NSArray *)getAllInvestItems
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"rsLogInUser",self];
    NSArray *allInvestItems = [InvestItems MR_findAllSortedBy:@"time" ascending:NO withPredicate:pre];
    return allInvestItems;
}

// //通过item查询
- (InvestItems *)getInvestItemsWithItem:(NSString *)item
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLogInUser",self,@"item",item];
    InvestItems *investItem = [InvestItems MR_findFirstWithPredicate:pre inContext:[self managedObjectContext]];
    return investItem;
}

//--------------------NeedAddUser---------------
//获取已经存在的好友对象
- (NeedAddUser *)getNeedAddUserWithUid:(NSNumber *)uid
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLoginUser",self,@"uid",uid];
    NeedAddUser *needAddUser = [NeedAddUser MR_findFirstWithPredicate:pre inContext:[self managedObjectContext]];
    return needAddUser;
}

//获取已经存在的好友对象
- (NeedAddUser *)getNeedAddUserWithMobile:(NSString *)mobile
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLogInUser",self,@"mobile",mobile];
    NeedAddUser *needAddUser = [NeedAddUser MR_findFirstWithPredicate:pre inContext:[self managedObjectContext]];
    return needAddUser;
}

//删除指定类型的好友
- (void)delelteAllNeedAddUserWithType:(NSNumber *)type
{
    //删除本地所有数据
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLoginUser",self,@"userType",type];
    [NeedAddUser MR_deleteAllMatchingPredicate:pre inContext:[self managedObjectContext]];
    [[self managedObjectContext] MR_saveToPersistentStoreAndWait];
}

@end
