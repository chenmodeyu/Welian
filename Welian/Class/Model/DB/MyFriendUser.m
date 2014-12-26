//
//  MyFriendUser.m
//  Welian
//
//  Created by dong on 14/12/24.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "MyFriendUser.h"
#import "ChatMessage.h"
#import "LogInUser.h"
#import "FriendsUserModel.h"

@implementation MyFriendUser

@dynamic status;
@dynamic rsChatMessages;
@dynamic rsLogInUser;

//创建新收据
+ (MyFriendUser *)createMyFriendUserModel:(FriendsUserModel *)userInfoM
{
    MyFriendUser *myFriend = [MyFriendUser getMyfriendUserWithUid:userInfoM.uid];
    if (!myFriend) {
        myFriend = [MyFriendUser create];
    }
    myFriend.uid = userInfoM.uid;
    myFriend.mobile = userInfoM.mobile;
    myFriend.position = userInfoM.position;
    myFriend.provinceid = userInfoM.provinceid;
    myFriend.provincename = userInfoM.provincename;
    myFriend.cityid = userInfoM.cityid;
    myFriend.cityname = userInfoM.cityname;
    myFriend.friendship = userInfoM.friendship;
    myFriend.shareurl = userInfoM.shareurl;
    myFriend.avatar = userInfoM.avatar;
    myFriend.name = userInfoM.name;
    myFriend.address = userInfoM.address;
    myFriend.email = userInfoM.email;
    myFriend.investorauth = userInfoM.investorauth;
    myFriend.startupauth = userInfoM.startupauth;
    myFriend.company = userInfoM.company;
    myFriend.status = userInfoM.status;
    myFriend.rsLogInUser = [LogInUser getNowLogInUser];
    [MOC save];
    return myFriend;
}


// //通过uid查询
+ (MyFriendUser *)getMyfriendUserWithUid:(NSNumber *)uid
{
//    [LogInUser getNowLogInUser].rsMyFriends.allObjects
//    NSPredicate * filter = [NSPredicate predicateWithFormat:@"uid = %@",uid];
    
    MyFriendUser *myFriend = [[[[[MyFriendUser queryInManagedObjectContext:MOC] where:@"rsLogInUser" equals:[LogInUser getNowLogInUser]] where:@"uid" equals:uid] results] firstObject];
    return myFriend;
}
@end
