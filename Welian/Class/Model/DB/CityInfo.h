//
//  CityInfo.h
//  Welian
//
//  Created by weLian on 15/5/26.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ICityModel;

@interface CityInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * cityid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * type;//1：活动城市   2：项目城市 
@property (nonatomic, retain) NSNumber * isShow;//是否显示

+ (CityInfo *)createCityInfoWith:(ICityModel *)iCityModel Type:(NSNumber *)type;
+ (CityInfo *)getCityInfoWithId:(NSNumber *)cityId Type:(NSNumber *)type;
+ (NSArray *)getAllCityInfosType:(NSNumber *)type;
//删除数据库数据多余数据
+ (void)deleteAllCityInfosRealWithType:(NSNumber *)type;
//删除数据库数据。 隐性删除
+ (void)deleteAllCityInfosWithType:(NSNumber *)type;

@end
