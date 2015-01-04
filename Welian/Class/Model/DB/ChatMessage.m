//
//  ChatMessage.m
//  Welian
//
//  Created by weLian on 14/12/27.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "ChatMessage.h"
#import "WLMessage.h"
#import "MyFriendUser.h"


@implementation ChatMessage

@dynamic msgId;
@dynamic message;
@dynamic messageType;
@dynamic timestamp;
@dynamic avatorUrl;
@dynamic isRead;
@dynamic sendStatus;
@dynamic bubbleMessageType;
@dynamic thumbnailUrl;
@dynamic originPhotoUrl;
@dynamic videoPath;
@dynamic videoUrl;
@dynamic videoConverPhoto;
@dynamic voicePath;
@dynamic voiceUrl;
@dynamic localPositionPhoto;
@dynamic geolocations;
@dynamic latitude;
@dynamic longitude;
@dynamic sender;
@dynamic rsMyFriendUser;

//创建新的聊天记录
+ (ChatMessage *)createChatMessageWithWLMessage:(WLMessage *)wlMessage FriendUser:(MyFriendUser *)friedUser
{
    ChatMessage *chatMsg = [ChatMessage create];
    chatMsg.msgId = @([friedUser getMaxChatMessageId].integerValue + 1);
    chatMsg.message = wlMessage.text;
    chatMsg.messageType = @(wlMessage.messageMediaType);
    chatMsg.timestamp = wlMessage.timestamp;
    chatMsg.avatorUrl = wlMessage.avatorUrl;
    chatMsg.isRead = @(wlMessage.isRead);
    chatMsg.sendStatus = @(wlMessage.sended.intValue);
    chatMsg.bubbleMessageType = @(wlMessage.bubbleMessageType);
    chatMsg.thumbnailUrl = wlMessage.thumbnailUrl;
    chatMsg.originPhotoUrl = wlMessage.originPhotoUrl;
    chatMsg.videoPath = wlMessage.videoPath;
    chatMsg.videoUrl = wlMessage.videoUrl;
//    chatMsg.videoConverPhoto = wlMessage.videoConverPhoto;
    chatMsg.voicePath = wlMessage.voicePath;
    chatMsg.voiceUrl = wlMessage.voiceUrl;
    chatMsg.geolocations = wlMessage.geolocations;
    chatMsg.latitude = @(wlMessage.location.coordinate.latitude);
    chatMsg.longitude = @(wlMessage.location.coordinate.longitude);
    chatMsg.sender = wlMessage.sender;
    chatMsg.rsMyFriendUser = friedUser;
    [MOC save];
    
    //更新好友的聊天时间
    [friedUser updateLastChatTime:chatMsg.timestamp];
    
    return chatMsg;
}

//创建接受到的聊天消息
+ (void)createReciveMessageWithDict:(NSDictionary *)dict
{
    /*
     {
     data =     {
     created = "2014-12-29 15:06:08";
     fromuser =         {
     avatar = "http://img.welian.com/1417496795301_x.png";
     name = "\U5f20\U8273\U4e1c";
     uid = 10019;
     };
     msg = lol;
     type = 0;
     uid = 11078;
     };
     type = IM;
     }
     */
    
    MyFriendUser *friendUser = [MyFriendUser createMyFriendFromReceive:dict];
    NSString *created = dict[@"created"];
    NSInteger type = [dict[@"type"] integerValue];
    
    ChatMessage *chatMsg = [ChatMessage create];
    NSNumber *maxMsgId = [friendUser getMaxChatMessageId];
    chatMsg.msgId = @(maxMsgId.integerValue + 1);
    chatMsg.messageType = @(type);
    switch (type) {
        case WLBubbleMessageMediaTypeText:
            //文本
            chatMsg.message = dict[@"msg"];
            break;
        case WLBubbleMessageMediaTypePhoto://照片
            chatMsg.message = @"[图片]";
            chatMsg.messageType = @(type);
            chatMsg.messageType = @(WLBubbleMessageMediaTypeText);
            break;
        case WLBubbleMessageMediaTypeVoice:
            chatMsg.message = @"[语音]";
            chatMsg.messageType = @(WLBubbleMessageMediaTypeText);
            break;
        case WLBubbleMessageMediaTypeVideo:
            chatMsg.message = @"[视频]";
            chatMsg.messageType = @(WLBubbleMessageMediaTypeText);
            break;
        case WLBubbleMessageMediaTypeEmotion:
            chatMsg.message = @"[动态表情]";
            chatMsg.messageType = @(WLBubbleMessageMediaTypeText);
            break;
        case WLBubbleMessageMediaTypeLocalPosition:
            chatMsg.message = @"[视频]";
            chatMsg.messageType = @(WLBubbleMessageMediaTypeText);
            break;
        default:
            break;
    }
    chatMsg.timestamp = [created dateFromShortString];
    chatMsg.avatorUrl = friendUser.avatar;
    chatMsg.isRead = @(NO);
    chatMsg.sendStatus = @(1);
    chatMsg.bubbleMessageType = @(WLBubbleMessageTypeReceiving);//接受的数据
//    chatMsg.thumbnailUrl = wlMessage.thumbnailUrl;
//    chatMsg.originPhotoUrl = wlMessage.originPhotoUrl;
//    chatMsg.videoPath = wlMessage.videoPath;
//    chatMsg.videoUrl = wlMessage.videoUrl;
    //    chatMsg.videoConverPhoto = wlMessage.videoConverPhoto;
//    chatMsg.voicePath = wlMessage.voicePath;
//    chatMsg.voiceUrl = wlMessage.voiceUrl;
//    chatMsg.geolocations = wlMessage.geolocations;
//    chatMsg.latitude = @(wlMessage.location.coordinate.latitude);
//    chatMsg.longitude = @(wlMessage.location.coordinate.longitude);
    chatMsg.sender = friendUser.name;
    chatMsg.rsMyFriendUser = friendUser;
    [MOC save];
    
    //更新好友的聊天时间
    [friendUser updateLastChatTime:chatMsg.timestamp];
    
    //更新总的聊天消息数量
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatMsgNumChanged" object:nil];
    //调用获取收到新消息，刷新正在聊天的列表
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"ReceiveNewChatMessage%@",friendUser.uid.stringValue] object:self userInfo:@{@"msgId":chatMsg.msgId}];
}

//创建特殊自定义聊天类型
+ (ChatMessage *)createSpecialMessageWithMessage:(WLMessage *)wlMessage FriendUser:(MyFriendUser *)friedUser
{
    ChatMessage *chatMsg = [ChatMessage create];
    chatMsg.msgId = @([friedUser getMaxChatMessageId].integerValue + 1);
    chatMsg.message = wlMessage.text;
    chatMsg.messageType = @(WLBubbleMessageSpecialTypeText);
    chatMsg.timestamp = [NSDate date];
    chatMsg.avatorUrl = nil;
    chatMsg.isRead = @(1);
    chatMsg.sendStatus = @(1);
    chatMsg.bubbleMessageType = @(WLBubbleMessageTypeSpecial);
    chatMsg.thumbnailUrl = nil;
    chatMsg.originPhotoUrl = nil;
    chatMsg.videoPath = nil;
    chatMsg.videoUrl = nil;
    //    chatMsg.videoConverPhoto = wlMessage.videoConverPhoto;
    chatMsg.voicePath = nil;
    chatMsg.voiceUrl = nil;
    chatMsg.geolocations = @"";
    chatMsg.latitude = 0;
    chatMsg.longitude = 0;
    chatMsg.sender = nil;
    chatMsg.rsMyFriendUser = friedUser;
    [MOC save];
    
    //更新好友的聊天时间
    [friedUser updateLastChatTime:chatMsg.timestamp];
    
    return chatMsg;
}

//更新发送状态
- (void)updateSendStatus:(NSInteger)status
{
    self.sendStatus = @(status);
    
    [MOC save];
    
    DLog(@"changed: ---- %d",self.sendStatus.intValue);
    
    //聊天状态发送改变
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatUserChanged" object:nil];
}

//更新读取状态
- (void)updateReadStatus:(BOOL)status
{
    self.isRead = @(status);
    [MOC save];
}

//更新重新发送状态
- (void)updateReSendStatus
{
    self.sendStatus = @(0);
    self.timestamp = [NSDate date];
    [MOC save];
}

@end
