//
//  TouTiaoInfo.h
//  Welian
//
//  Created by weLian on 15/5/21.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogInUser, ITouTiaoModel;

@interface TouTiaoInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * touTiaoId;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * intro;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * isShow;//是否显示
@property (nonatomic, retain) LogInUser *rsLoginUser;

+ (TouTiaoInfo *)createTouTiaoInfoWith:(ITouTiaoModel *)iTouTiaoModel;
+ (TouTiaoInfo *)getTouTiaoInfoWithId:(NSNumber *)touTiaoId;
+ (NSArray *)getAllTouTiaos;
//删除数据库数据。 隐性删除
+ (void)deleteAllTouTiaoInfos;

//获取创建时间
- (NSString *)displayCreateTime;

@end
