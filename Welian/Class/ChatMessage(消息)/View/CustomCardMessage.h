//
//  CustomCardMessage.h
//  Welian
//
//  Created by dong on 15/6/16.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#define WLCustomCardMessageTypeIdentifier @"WL:CardMsg"

@interface CustomCardMessage : RCMessageContent <RCMessageContentView>

//@property (nonatomic, strong) NSDictionary *content;

@property (nonatomic, strong) NSDictionary *fromuser;

@property (nonatomic, strong) NSDictionary *card;

@property (nonatomic, strong) NSString *touser;

@property (nonatomic, strong) NSString *msg;



@end
