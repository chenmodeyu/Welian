//
//  InvestIndustry.m
//  Welian
//
//  Created by dong on 14/12/29.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "InvestIndustry.h"
#import "LogInUser.h"
#import "IInvestIndustryModel.h"

@implementation InvestIndustry

@dynamic industryname;
@dynamic industryid;
@dynamic rsLogInUser;
@dynamic rsProjectDetailInfo;

//创建新收据
+ (InvestIndustry *)createInvestIndustry:(IInvestIndustryModel *)investIndustry
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"isNow",@(YES)];
    LogInUser *loginUser = [LogInUser MR_findFirstWithPredicate:pre];
    if (!loginUser) {
        return nil;
    }else{
        InvestIndustry *investitem = [loginUser getInvestIndustryWithName:investIndustry.industryname];
        if (!investitem) {
            investitem = [InvestIndustry MR_createEntityInContext:loginUser.managedObjectContext];
        }
        investitem.industryid = investIndustry.industryid;
        investitem.industryname = [investIndustry.industryname deleteTopAndBottomKonggeAndHuiche];
        
        [loginUser addRsInvestIndustrysObject:investitem];
        [loginUser.managedObjectContext MR_saveToPersistentStoreAndWait];
        return investitem;
    }
}

//创建普通领域
+ (InvestIndustry *)createInvestIndustryWith:(IInvestIndustryModel *)investIndustry
{
    InvestIndustry *investitem = [InvestIndustry MR_createEntity];
    investitem.industryid = investIndustry.industryid;
    investitem.industryname = [investIndustry.industryname deleteTopAndBottomKonggeAndHuiche];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return investitem;
}

//获取未对应对象的领域列表
+ (NSArray *)getAllInvestIndustrys
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == nil && %K == nil",@"rsLogInUser",@"rsProjectDetailInfo"];
    NSArray *all = [InvestIndustry MR_findAllWithPredicate:pre];
    return all;
}

+ (InvestIndustry *)getInvestIndustryWith:(NSNumber *)industryid
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == nil && %K == nil && %K == %@ ",@"rsLogInUser",@"rsProjectDetailInfo",@"industryid",industryid];
    InvestIndustry *investIndustry = [InvestIndustry MR_findFirstWithPredicate:pre];
    return investIndustry;
}

//删除未对应对象的领域列表
+ (void)deleteAllInvestIndustrys
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == nil && %K == nil",@"rsLogInUser",@"rsProjectDetailInfo"];
    [InvestIndustry MR_deleteAllMatchingPredicate:pre];
}

// //通过item查询
//+ (InvestIndustry *)getInvestIndustryWithName:(NSString *)name
//{
//    InvestIndustry *investIndustry = [[[[[InvestIndustry queryInManagedObjectContext:MOC] where:@"rsLogInUser" equals:[LogInUser getCurrentLoginUser]] where:@"industryname" equals:name] results] firstObject];
//    return investIndustry;
//}


@end
