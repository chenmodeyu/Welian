//
//  CustomCardMessage.m
//  Welian
//
//  Created by dong on 15/6/16.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "CustomCardMessage.h"

@implementation CustomCardMessage

//+ (instancetype)cardMessageWithContent:(NSString *)content {
//    CustomCardMessage *cardM = [[CustomCardMessage alloc] init];
//    if (cardM) {
//        cardM.content = content;
//        
//    }
//    return cardM;
//}

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
    return self.msg.length?self.msg:[self.card objectForKey:@"title"];
}

@end
