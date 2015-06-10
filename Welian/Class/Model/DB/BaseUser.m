//
//  BaseUser.m
//  Welian
//
//  Created by dong on 14/12/24.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "BaseUser.h"


@implementation BaseUser

@dynamic avatar;
@dynamic name;
@dynamic uid;
@dynamic address;
@dynamic email;
@dynamic friendship;
@dynamic investorauth;
@dynamic inviteurl;
@dynamic mobile;
@dynamic startupauth;
@dynamic company;
@dynamic position;
@dynamic provinceid;
@dynamic provincename;
@dynamic cityid;
@dynamic cityname;
@dynamic shareurl;
@dynamic friendcount;
@dynamic feedcount;
@dynamic friend2count;
@dynamic checked;
@dynamic samefriendscount;
@dynamic rongCloudToken;

//将数据库对象转换成接口对象模型
- (IBaseUserM *)toIBaseUserModelInfo
{
    IBaseUserM *iBaseUserM = [[IBaseUserM alloc] init];
    iBaseUserM.uid = self.uid;
    iBaseUserM.name = self.name;
    iBaseUserM.avatar = self.avatar;
    iBaseUserM.address = self.address;
    iBaseUserM.email = self.email;
    iBaseUserM.friendship = self.friendship;
    iBaseUserM.investorauth = self.investorauth;
    iBaseUserM.inviteurl = self.inviteurl;
    iBaseUserM.mobile = self.mobile;
//    iBaseUserM.startupauth = self.startupauth;
    iBaseUserM.company = self.company;
    iBaseUserM.position = self.position;
    iBaseUserM.provinceid = self.provinceid;
    iBaseUserM.provincename = self.provincename;
    iBaseUserM.cityid = self.cityid;
    iBaseUserM.cityname = self.cityname;
    iBaseUserM.shareurl = self.shareurl;
    iBaseUserM.friendcount = self.friendcount;
    iBaseUserM.feedcount = self.feedcount;
    iBaseUserM.friend2count = self.friend2count;
    iBaseUserM.checked = self.checked;
    iBaseUserM.samefriendscount = self.samefriendscount;
    iBaseUserM.token = self.rongCloudToken;
    return iBaseUserM;
}

@end
