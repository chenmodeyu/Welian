//
//  ChatRoomInfo.h
//  Welian
//
//  Created by weLian on 15/6/15.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogInUser;

@interface ChatRoomInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * chatroomid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * starttime;
@property (nonatomic, retain) NSString * endtime;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * avatorUrl;
@property (nonatomic, retain) NSDate * lastJoinTime;
@property (nonatomic, retain) NSNumber * joinUserCount;
@property (nonatomic, retain) NSNumber * isShow;//是否显示
@property (nonatomic, retain) LogInUser *rsLoginUser;


@end
