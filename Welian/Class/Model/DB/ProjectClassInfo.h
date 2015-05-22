//
//  ProjectClassInfo.h
//  Welian
//
//  Created by weLian on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogInUser,IProjectClassModel;

@interface ProjectClassInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * cid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSNumber * projectCount;
@property (nonatomic, retain) NSNumber * isShow;//是否显示
@property (nonatomic, retain) LogInUser *rsLoginUser;

+ (ProjectClassInfo *)createProjectClassInfoWith:(IProjectClassModel *)iProjectClassModel;
+ (ProjectClassInfo *)getProjectClassInfoWithId:(NSNumber *)cid;
+ (NSArray *)getAllProjectClassInfos;
//删除数据库数据。 隐性删除
+ (void)deleteAllProjectClassInfos;
//真实删除
+ (void)deleteAllProjectClassInfosReal;

@end
