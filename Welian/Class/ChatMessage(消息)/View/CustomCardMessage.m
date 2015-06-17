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
    [dataDict setObject:self.content forKey:@"content"];
    [dataDict setObject:self.portraitUri forKey:@"portraitUri"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict
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
        self.card = json[@"card"];
        self.touser = json[@"touser"];
        self.content = json[@"card"][@"content"];
        self.portraitUri = json[@"portraitUri"];
    }
}

+(NSString *)getObjectName {
    return WLCustomCardMessageTypeIdentifier;
}

@end
