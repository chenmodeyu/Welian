//
//  ChatRoomInfo.h
//  Welian
//
//  Created by weLian on 15/6/15.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogInUser,IChatRoomInfo;

@interface ChatRoomInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * chatroomid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * starttime;
@property (nonatomic, retain) NSString * endtime;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * avatorUrl;
@property (nonatomic, retain) NSString * shareUrl;
@property (nonatomic, retain) NSDate * lastJoinTime;
@property (nonatomic, retain) NSNumber * joinUserCount;
@property (nonatomic, retain) NSNumber * role;//是否自己创建
@property (nonatomic, retain) NSNumber * isShow;//是否显示
@property (nonatomic, retain) LogInUser *rsLoginUser;

+ (ChatRoomInfo *)createChatRoomInfoWith:(IChatRoomInfo *)iChatRoomInfo;
+ (ChatRoomInfo *)getChatRoomInfoWithId:(NSNumber *)roomId;
+ (NSArray *)getAllChatRoomInfos;
//删除数据库数据。 隐性删除
+ (void)deleteAllChatRoomInfos;
//真实删除
+ (void)deleteAllChatRoomInfosReal;

@end
