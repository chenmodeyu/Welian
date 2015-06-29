//
//  CustomCardMessage.m
//  Welian
//
//  Created by dong on 15/6/16.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "CustomCardMessage.h"
#import "WLMessageBubbleFactory.h"

@implementation CustomCardMessage

+(RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

#pragma mark - RCMessageCoding delegate methods

-(NSData *)encode {
    
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    [dataDict setObject:self.card forKey:@"card"];
    [dataDict setObject:self.touser forKey:@"touser"];
    [dataDict setObject:self.msg forKey:@"msg"];
    [dataDict setObject:self.fromuser forKeyedSubscript:@"fromuser"];

    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"content":[RCJSONConverter jsonStringWithDictionary:dataDict]}
                                                   options:kNilOptions
                                                     error:nil];
    return data;
}

-(void)decodeWithData:(NSData *)data {
    
    if (!data) {
        return;
    }
    NSError *error = [[NSError alloc] init];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error];
    if (json) {
        NSString *contentStr = [json objectForKey:@"content"];
        NSDictionary *dataDic = [contentStr jsonObject];
        if (dataDic) {
            self.card = dataDic[@"card"];
            self.touser = dataDic[@"uid"];
            self.msg = dataDic[@"msg"];
            self.fromuser = dataDic[@"fromuser"];
        }
    }
}


+(NSString *)getObjectName {
    return WLCustomCardMessageTypeIdentifier;
}

- (NSString *)conversationDigest
{
    NSString *chatMsg = @"";
    NSInteger cardType = [[self.card objectForKey:@"type"] integerValue];
    switch (cardType) {
        case WLBubbleMessageCardTypeActivity://活动
            chatMsg = @"[活动]";
            break;
        case WLBubbleMessageCardTypeProject://项目
            chatMsg = @"[项目]";
            break;
        case WLBubbleMessageCardTypeWeb://网页
            chatMsg = @"[链接]";
            break;
        case WLBubbleMessageCardTypeInvestorGet://索要项目
            chatMsg = @"[项目]";
            break;
        case WLBubbleMessageCardTypeInvestorPost://投递项目
            chatMsg = @"[项目]";
            break;
        case WLBubbleMessageCardTypeInvestorUser://用户名片卡片
            chatMsg = @"[名片]";
            break;
        default:
            chatMsg = @"对方刚给你发了一条消息，您当前版本无法查看，快去升级吧.";
            break;
    }
    return chatMsg;;
}

@end
