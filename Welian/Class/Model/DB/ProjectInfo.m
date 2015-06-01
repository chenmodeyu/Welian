//
//  ProjectInfo.m
//  Welian
//
//  Created by weLian on 15/2/10.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectInfo.h"


@implementation ProjectInfo

@dynamic commentcount;
@dynamic date;
@dynamic des;
@dynamic industrys;
@dynamic intro;
@dynamic iszan;
@dynamic membercount;
@dynamic name;
@dynamic pid;
@dynamic status;
@dynamic zancount;
@dynamic type;
@dynamic rsLoginUser;
@dynamic rsProjectUser;

//创建项目
+ (void)createProjectInfoWith:(IProjectInfo *)iProjectInfo withType:(NSNumber *)type
{
    ProjectInfo *projectInfo = [self getProjectInfoWithPid:iProjectInfo.pid Type:type];
    if (!projectInfo) {
        projectInfo = [ProjectInfo MR_createEntity];
    }
    projectInfo.pid = iProjectInfo.pid;
    projectInfo.name = iProjectInfo.name;
    projectInfo.intro = iProjectInfo.intro;
    projectInfo.des = iProjectInfo.des;
    projectInfo.date = iProjectInfo.date;
    projectInfo.membercount = iProjectInfo.membercount;
    projectInfo.commentcount = iProjectInfo.commentcount;
    projectInfo.status = iProjectInfo.status;
    projectInfo.zancount = iProjectInfo.zancount;
    projectInfo.iszan = iProjectInfo.iszan;
    projectInfo.industrys = [iProjectInfo displayIndustrys];
    projectInfo.type = type;
    //设置用户
    if(!projectInfo.rsProjectUser){
        //如果不存在，创建
        ProjectUser *projectUser = [ProjectUser createWithIBaseUserM:iProjectInfo.user];
        projectInfo.rsProjectUser = projectUser;
    }
    
    if (type != 0) {
        LogInUser *loginUser = [LogInUser getCurrentLoginUser];
        [loginUser addRsProjectInfosObject:projectInfo];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

//获取项目
+ (ProjectInfo *)getProjectInfoWithPid:(NSNumber *)pid Type:(NSNumber *)type
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"type",type,@"pid",pid];
    ProjectInfo *projectInfo = [ProjectInfo MR_findFirstWithPredicate:pre];
    return projectInfo;
}

//删除所有指定类型的对象
+ (void)deleteAllProjectInfoWithType:(NSNumber *)type
{
    //0：普通   1：收藏  2：创建  -1：已删除
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"type",type];
    NSArray *all = [ProjectInfo MR_findAllWithPredicate:pre];
    for (ProjectInfo *projectInfo in all) {
        //设置状态为已经删除
        projectInfo.type = @(-1);
    }
//    [ProjectInfo MR_deleteAllMatchingPredicate:pre];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

//删除指定类型的单个对象
+ (void)deleteProjectInfoWithType:(NSNumber *)type Pid:(NSNumber *)pid
{
    ProjectInfo *projectInfo = [self getProjectInfoWithPid:pid Type:type];
    [projectInfo MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

//获取所有的普通的项目排序后数据
+ (NSArray *)allNormalProjectInfos
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"type",@(0)];
    NSArray *all = [ProjectInfo MR_findAllSortedBy:@"date" ascending:NO withPredicate:pre];
    //添加数据
    NSMutableArray *headerKeys = [NSMutableArray array];
    NSMutableArray *arrayForArrays = [NSMutableArray array];
    NSMutableArray *tempFroGroup = nil;
    BOOL checkValueAtIndex = NO;
    for (int i = 0; i < all.count; i++) {
        ProjectInfo *project = all[i];
        //监测数组中是否包含当前日期，没有创建
        if (![headerKeys containsObject:project.date]) {
            [headerKeys addObject:project.date];
            tempFroGroup = [NSMutableArray array];
            checkValueAtIndex = NO;
        }
        
        //有就把数据添加进去
        if ([headerKeys containsObject:project.date]) {
            [tempFroGroup addObject:project];
            if (checkValueAtIndex == NO) {
                [arrayForArrays addObject:tempFroGroup];
                checkValueAtIndex = YES;
            }
        }
    }
    NSArray *arrayWithArray = @[headerKeys,arrayForArrays];
    return arrayWithArray;
}

//赞的数量
- (NSString *)displayZancountInfo
{
    if (self.zancount.integerValue < 100) {
        return self.zancount.stringValue;
    }else{
        if (self.zancount.integerValue >= 1000 && self.zancount.integerValue < 10000) {
            return [NSString stringWithFormat:@"%.1fk",self.zancount.floatValue / 1000];
        }else{
            return [NSString stringWithFormat:@"%.1fw",self.zancount.floatValue / 10000];
        }
    }
}

//更新点赞状态和点赞人数
- (void)updateIsZanAndZanCount:(BOOL)isZan
{
    self.iszan = @(isZan);
    self.zancount = @(self.zancount.integerValue + (isZan ? 1 : -1));
    [[self managedObjectContext] MR_saveToPersistentStoreAndWait];
    
    //更新项目列表
    [KNSNotification postNotificationName:kUpdateProjectListUI object:nil];
//    return self;
}

//获取自己的项目或者自己收藏的
+ (NSArray *)allMyProjectInfoWithType:(NSNumber *)type
{
    //0：普通   1：收藏  2：创建  3：热门  4:上次筛选  -1：已删除  other:对应项目集的id
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"type",type,@"rsLoginUser",loginUser];
//    NSArray *all = type.integerValue == 3 ? [ProjectInfo MR_findAllSortedBy:@"zancount" ascending:NO withPredicate:pre] : [ProjectInfo MR_findAllSortedBy:@"date" ascending:NO withPredicate:pre];
    NSArray *all = (type.integerValue == 1 || type.integerValue == 2) ? [ProjectInfo MR_findAllSortedBy:@"date" ascending:NO withPredicate:pre] : [ProjectInfo MR_findAllSortedBy:@"zancount" ascending:NO withPredicate:pre];
    return all;
}

@end
