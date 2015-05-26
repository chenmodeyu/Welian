//
//  CityInfo.m
//  Welian
//
//  Created by weLian on 15/5/26.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "CityInfo.h"


@implementation CityInfo

@dynamic cityid;
@dynamic name;
@dynamic type;
@dynamic isShow;

+ (CityInfo *)createCityInfoWith:(ICityModel *)iCityModel Type:(NSNumber *)type
{
    CityInfo *cityInfo = [self getCityInfoWithId:iCityModel.cityid Type:type];
    if (!cityInfo) {
        cityInfo = [CityInfo MR_createEntity];
    }
    cityInfo.cityid = iCityModel.cityid;
    cityInfo.name = iCityModel.name;
    cityInfo.type = type;//1：活动城市   2：项目城市
    cityInfo.isShow = @(YES);
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return cityInfo;
}

+ (CityInfo *)getCityInfoWithId:(NSNumber *)cityId Type:(NSNumber *)type
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"cityid",cityId,@"type",type];
    CityInfo *cityInfo = [CityInfo MR_findFirstWithPredicate:pre];
    return cityInfo;
}

+ (NSArray *)getAllCityInfosType:(NSNumber *)type
{
    //1：活动城市   2：项目城市
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"isShow",@(YES),@"type",type];
    NSArray *all = [CityInfo MR_findAllWithPredicate:pre];
    return all;
}

//删除数据库数据多余数据
+ (void)deleteAllCityInfosRealWithType:(NSNumber *)type
{
    //1：活动城市   2：项目城市
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"type",type];
    [CityInfo MR_deleteAllMatchingPredicate:pre];
}

//删除数据库数据。 隐性删除
+ (void)deleteAllCityInfosWithType:(NSNumber *)type
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"isShow",@(YES), @"type",type];
    NSArray *all = [CityInfo MR_findAllWithPredicate:pre];
    for (CityInfo *cityInfo in all) {
        cityInfo.isShow = @(NO);
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

@end
