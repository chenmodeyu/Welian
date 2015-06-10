//
//  CustomMessageType.h
//  RongCloudDemo
//
//  Created by weLian on 15/6/3.
//  Copyright (c) 2015年 liuwu. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#define RCCustomMessageTypeIdentifier @"WL:CustomMsg"

@interface CustomMessageType : RCMessageContent

/** 文本消息内容 */
@property(nonatomic, strong) NSString *content;

/**
 *  附加信息
 */
@property(nonatomic, strong) NSString *extra;

/**
 *  根据参数创建文本消息对象
 *
 *  @param content  文本消息内容
 */
+ (instancetype)messageWithContent:(NSString *)content;

@end
