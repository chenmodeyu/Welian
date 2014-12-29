//
//  LogInUser.h
//  Welian
//
//  Created by dong on 14/12/24.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BaseUser.h"
#import "UserInfoModel.h"

@class CompanyModel, FriendsFriendUser, MyFriendUser, NewFriendUser, SchoolModel, HomeMessage, InvestStages, InvestIndustry, InvestItems;

@interface LogInUser : BaseUser

@property (nonatomic, retain) NSNumber * isNow;
@property (nonatomic, retain) NSString * checkcode;
@property (nonatomic, retain) NSString * sessionid;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * auth;

@property (nonatomic, retain) NSSet *rsCompanys;
@property (nonatomic, retain) NSSet *rsSchools;
@property (nonatomic, retain) NSSet *rsMyFriends;
@property (nonatomic, retain) NSSet *rsFriendsFriends;
@property (nonatomic, retain) NSSet *rsNewFriends;
@property (nonatomic, retain) NSSet *rsHomeMessages;

@property (nonatomic, retain) NSSet *rsInvestStages;
@property (nonatomic, retain) NSSet *rsInvestItems;
@property (nonatomic, retain) NSSet *rsInvestIndustrys;

//创建新收据
+ (LogInUser *)createLogInUserModel:(UserInfoModel *)userInfoM;

//通过ucid查询
+ (LogInUser *)getLogInUserWithUid:(NSNumber*)uid;

// 当前登录账户信息
+ (LogInUser *)getNowLogInUser;

//获取正在聊天的消息列表
//+ (NSArray *)chatUsers;



+ (void)setUserUid:(NSNumber *)uid;
+ (void)setUserPosition:(NSString*)position;
+ (void)setUserProvinceid:(NSNumber *)provinceid;

+ (void)setUserProvincename:(NSString *)provincename;

+ (void)setUserCityid:(NSNumber *)cityid;

+ (void)setUserCityname:(NSString *)cityname;

+ (void)setUserFriendship:(NSNumber *)friendship;
+ (void)setUserShareurl:(NSString *)shareurl;

+ (void)setUserAvatar:(NSString *)avatar;

+ (void)setUserName:(NSString *)name;

+ (void)setUserAddress:(NSString *)address;

+ (void)setUserEmail:(NSString *)email;

+ (void)setUserinvestorauth:(NSNumber *)investorauth;

+ (void)setUserstartupauth:(NSNumber *)startupauth;

+ (void)setUsercompany:(NSString *)company;

+ (void)setUsercheckcode:(NSString *)checkcode;

+ (void)setUserSessionid:(NSString *)sessionid;

+ (void)setUserisNow:(BOOL)isnow;

+ (void)setUserUrl:(NSString *)url;
+ (void)setuserAuth:(NSNumber *)auth;

@end

@interface LogInUser (CoreDataGeneratedAccessors)

- (void)addRsCompanysObject:(CompanyModel *)value;
- (void)removeRsCompanysObject:(CompanyModel *)value;
- (void)addRsCompanys:(NSSet *)values;
- (void)removeRsCompanys:(NSSet *)values;

- (void)addRsSchoolsObject:(SchoolModel *)value;
- (void)removeRsSchoolsObject:(SchoolModel *)value;
- (void)addRsSchools:(NSSet *)values;
- (void)removeRsSchools:(NSSet *)values;

- (void)addRsMyFriendsObject:(MyFriendUser *)value;
- (void)removeRsMyFriendsObject:(MyFriendUser *)value;
- (void)addRsMyFriends:(NSSet *)values;
- (void)removeRsMyFriends:(NSSet *)values;

- (void)addRsFriendsFriendsObject:(FriendsFriendUser *)value;
- (void)removeRsFriendsFriendsObject:(FriendsFriendUser *)value;
- (void)addRsFriendsFriends:(NSSet *)values;
- (void)removeRsFriendsFriends:(NSSet *)values;

- (void)addRsNewFriendsObject:(NewFriendUser *)value;
- (void)removeRsNewFriendsObject:(NewFriendUser *)value;
- (void)addRsNewFriends:(NSSet *)values;
- (void)removeRsNewFriends:(NSSet *)values;

- (void)addRsHomeMessagesObject:(HomeMessage *)value;
- (void)removeRsHomeMessagesObject:(HomeMessage *)value;
- (void)addRsHomeMessages:(NSSet *)values;
- (void)removeRsHomeMessages:(NSSet *)values;

- (void)addRsInvestItemsObject:(InvestItems *)value;
- (void)removeRsInvestItemsObject:(InvestItems *)value;
- (void)addRsInvestItems:(NSSet *)values;
- (void)removeRsInvestItems:(NSSet *)values;

- (void)addRsInvestStagesObject:(InvestStages *)value;
- (void)removeRsInvestStagesObject:(InvestStages *)value;
- (void)addRsInvestStages:(NSSet *)values;
- (void)removeRsInvestStages:(NSSet *)values;

- (void)addRsInvestIndustryObject:(InvestIndustry *)value;
- (void)removeRsInvestIndustryObject:(InvestIndustry *)value;
- (void)addRsInvestIndustry:(NSSet *)values;
- (void)removeRsInvestIndustry:(NSSet *)values;

@end
