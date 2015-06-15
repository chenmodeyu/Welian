//
//  CustomMessageType.h
//  RongCloudDemo
//
//  Created by weLian on 15/6/3.
//  Copyright (c) 2015年 liuwu. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#define RCCustomMessageTypeIdentifier @"WL:NoticeMsg"

@interface CustomMessageType : RCMessageContent

@property(nonatomic, strong) NSString *type;


/**
 *  请求者或者响应者的 UserId。
 */
@property(nonatomic, strong) NSString *uid;
/**
 *  被请求者或者被响应者的 UserId。
 */
@property(nonatomic, strong) NSString *targetUserId;
/**
 *  请求或者响应消息，如添加理由或拒绝理由。
 */
@property(nonatomic, strong) NSString *msg;
/**
 *  附加信息。
 */
@property(nonatomic, strong) NSString *extra;


/** 文本消息内容 */
@property(nonatomic, strong) NSString *content;


/**
 *  根据参数创建文本消息对象
 *
 *  @param content  文本消息内容
 */
+ (instancetype)messageWithContent:(NSString *)content;

@end
