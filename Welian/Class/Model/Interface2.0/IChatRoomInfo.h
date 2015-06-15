//
//  IChatRoomInfo.h
//  Welian
//
//  Created by weLian on 15/6/15.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IFBase.h"

@interface IChatRoomInfo : IFBase

@property (strong,nonatomic) NSNumber *roomId;
@property (strong,nonatomic) NSString *title;
@property (strong,nonatomic) NSString *starttime;
@property (strong,nonatomic) NSString *endtime;
@property (strong,nonatomic) NSString *code;

@end
