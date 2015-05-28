//
//  ProjectUser.m
//  Welian
//
//  Created by weLian on 15/2/11.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectUser.h"
#import "ProjectDetailInfo.h"


@implementation ProjectUser

@dynamic rsProjectDetailInfo;
@dynamic rsProjectInfo;

//创建对象
+ (ProjectUser *)createWithIBaseUserM:(IBaseUserM *)iBaseUserM
{
//    ProjectUser *baseUser = [self getBaseUserWith:iBaseUserM.uid];
//    if (!baseUser) {
//        baseUser = [ProjectUser MR_createEntity];
//    }
    ProjectUser *projectUser = [ProjectUser MR_createEntity];
    projectUser.avatar = iBaseUserM.avatar;
    projectUser.name = iBaseUserM.name;
    projectUser.uid = iBaseUserM.uid;
    projectUser.address = iBaseUserM.address;
    projectUser.email = iBaseUserM.email;
    projectUser.friendship = iBaseUserM.friendship;
    projectUser.investorauth = iBaseUserM.investorauth;
    projectUser.inviteurl = iBaseUserM.inviteurl;
    projectUser.mobile = iBaseUserM.mobile;
//    baseUser.startupauth = iBaseUserM.startupauth;
    projectUser.company = iBaseUserM.company;
    projectUser.position = iBaseUserM.position;
    projectUser.provinceid = iBaseUserM.provinceid;
    projectUser.provincename = iBaseUserM.provincename;
    projectUser.cityid = iBaseUserM.cityid;
    projectUser.cityname = iBaseUserM.cityname;
    projectUser.shareurl = iBaseUserM.shareurl;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return projectUser;
}

////获取指定uid的对象
//+ (ProjectUser *)getBaseUserWith:(NSNumber *)uid
//{
//    return [ProjectUser MR_findFirstByAttribute:@"uid" withValue:uid];
//}

@end
