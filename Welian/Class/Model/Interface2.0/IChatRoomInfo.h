//
//  IChatRoomInfo.h
//  Welian
//
//  Created by weLian on 15/6/15.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IFBase.h"

@interface IChatRoomInfo : IFBase

@property (strong,nonatomic) NSNumber *chatroomid;
@property (strong,nonatomic) NSString *title;
@property (strong,nonatomic) NSString *starttime;
@property (strong,nonatomic) NSString *endtime;
@property (strong,nonatomic) NSString *code;
@property (strong,nonatomic) NSString *avatar;
@property (strong,nonatomic) NSNumber *total;
@property (strong,nonatomic) NSString *created;
@property (strong,nonatomic) NSNumber *role;//是否自己创建
@property (strong,nonatomic) NSString *shareurl;

@end
