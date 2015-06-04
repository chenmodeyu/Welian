//
//  ProjectClassInfo.m
//  Welian
//
//  Created by weLian on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectClassInfo.h"
#import "LogInUser.h"


@implementation ProjectClassInfo

@dynamic cid;
@dynamic title;
@dynamic photo;
@dynamic projectCount;
@dynamic isShow;
@dynamic orders;
@dynamic rsLoginUser;

+ (ProjectClassInfo *)createProjectClassInfoWith:(IProjectClassModel *)iProjectClassModel
{
    ProjectClassInfo *projectClassInfo = [self getProjectClassInfoWithId:iProjectClassModel.cid];
    if (!projectClassInfo) {
        projectClassInfo = [ProjectClassInfo MR_createEntity];
    }
    projectClassInfo.cid = iProjectClassModel.cid;
    projectClassInfo.title = iProjectClassModel.title;
    projectClassInfo.photo = iProjectClassModel.photo;
    projectClassInfo.projectCount = iProjectClassModel.projectCount;
    projectClassInfo.orders = iProjectClassModel.orders;
    projectClassInfo.isShow = @(YES);
    
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (loginUser) {
        [loginUser addRsProjectClassInfosObject:projectClassInfo];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return projectClassInfo;
}

+ (ProjectClassInfo *)getProjectClassInfoWithId:(NSNumber *)cid
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"cid",cid];
    ProjectClassInfo *projectClassInfo = [ProjectClassInfo MR_findFirstWithPredicate:pre];
    return projectClassInfo;
}

+ (NSArray *)getAllProjectClassInfos
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"isShow",@(YES)];
    NSArray *all = [ProjectClassInfo MR_findAllSortedBy:@"orders" ascending:NO withPredicate:pre];
//    NSArray *all = [ProjectClassInfo MR_findAllWithPredicate:pre];
    return all;
}

//删除数据库数据。 隐性删除
+ (void)deleteAllProjectClassInfos
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"isShow",@(YES)];
    NSArray *all = [ProjectClassInfo MR_findAllWithPredicate:pre];
    for (ProjectClassInfo *projectClassInfo in all) {
        projectClassInfo.isShow = @(NO);
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

//真实删除
+ (void)deleteAllProjectClassInfosReal
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"isShow",@(NO)];
    [ProjectClassInfo MR_deleteAllMatchingPredicate:pre];
}

@end
