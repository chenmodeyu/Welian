//
//  CustomMessageType.m
//  RongCloudDemo
//
//  Created by weLian on 15/6/3.
//  Copyright (c) 2015年 liuwu. All rights reserved.
//

#import "CustomMessageType.h"

@implementation CustomMessageType

+ (instancetype)messageWithContent:(NSString *)content {
    CustomMessageType *text = [[CustomMessageType alloc] init];
    if (text) {
        text.content = content;
        
    }
    return text;
}


/**
 编码将当前对象转成JSON数据
 @return 编码后的JSON数据
 */
- (NSData *)encode
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    [dataDict setObject:self.content forKey:@"content"];
    if (self.extra) {
        [dataDict setObject:self.extra forKey:@"extra"];
    }
    //NSDictionary* dataDict = [NSDictionary dictionaryWithObjectsAndKeys:self.content, @"content", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict
                                                   options:kNilOptions
                                                     error:nil];
    return data;
}

/**
 根据给定的JSON数据设置当前实例
 @param data 传入的JSON数据
 */
- (void)decodeWithData:(NSData *)data
{
    if (!data) {
        return;
    }
    NSError *error = [[NSError alloc] init];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error];
    
    if (json) {
        self.content = json[@"content"];
        self.extra = json[@"extra"];
    }

}

/**
 应返回消息名称，此字段需个平台保持一致，每个消息类型是唯一的
 @return 消息体名称
 */
+ (NSString *)getObjectName
{
    return RCCustomMessageTypeIdentifier;
}

/**
 返回遵循此protocol的类对象持久化的标识
 
 @return 返回持久化设定标识
 @discussion   默认实现返回 @const (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED)
 */
+ (RCMessagePersistent)persistentFlag
{
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

@end
