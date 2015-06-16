//
//  ChatRoomInfo.m
//  Welian
//
//  Created by weLian on 15/6/15.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ChatRoomInfo.h"
#import "LogInUser.h"


@implementation ChatRoomInfo

@dynamic chatroomid;
@dynamic title;
@dynamic starttime;
@dynamic endtime;
@dynamic code;
@dynamic avatorUrl;
@dynamic lastJoinTime;
@dynamic joinUserCount;
@dynamic isShow;
@dynamic role;
@dynamic shareUrl;
@dynamic rsLoginUser;

+ (ChatRoomInfo *)createChatRoomInfoWith:(IChatRoomInfo *)iChatRoomInfo
{
    ChatRoomInfo *chatRoomInfo = [self getChatRoomInfoWithId:iChatRoomInfo.chatroomid];
    if (!chatRoomInfo) {
        chatRoomInfo = [ChatRoomInfo MR_createEntity];
    }
    chatRoomInfo.chatroomid = iChatRoomInfo.chatroomid;
    chatRoomInfo.title = iChatRoomInfo.title;
    chatRoomInfo.code = iChatRoomInfo.code;
    chatRoomInfo.starttime = iChatRoomInfo.starttime;
    chatRoomInfo.endtime = iChatRoomInfo.endtime;
    chatRoomInfo.avatorUrl = iChatRoomInfo.avatar;
    chatRoomInfo.joinUserCount = iChatRoomInfo.total;
    chatRoomInfo.isShow = @(YES);
    chatRoomInfo.role = iChatRoomInfo.role;
    chatRoomInfo.shareUrl = iChatRoomInfo.shareurl;
    chatRoomInfo.lastJoinTime = [NSDate date];//[iChatRoomInfo.created dateFromNormalStringNoss];
    
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (loginUser) {
        [loginUser addRsChatRoomInfosObject:chatRoomInfo];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    ///通知刷新列表
    [KNSNotification postNotificationName:@"NeedRloadChatRoomList" object:nil];
    
    return chatRoomInfo;
}

+ (ChatRoomInfo *)getChatRoomInfoWithId:(NSNumber *)roomId
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"chatroomid",roomId];
    ChatRoomInfo *chatRoomInfo = [ChatRoomInfo MR_findFirstWithPredicate:pre];
    return chatRoomInfo;
}

+ (NSArray *)getAllChatRoomInfos
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"isShow",@(YES)];
    NSArray *all = [ChatRoomInfo MR_findAllSortedBy:@"lastJoinTime" ascending:NO withPredicate:pre];
    return all;
}

//删除数据库数据。 隐性删除
+ (void)deleteAllChatRoomInfos
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"isShow",@(YES)];
    NSArray *all = [ChatRoomInfo MR_findAllWithPredicate:pre];
    for (ChatRoomInfo *chatRoomInfo in all) {
        chatRoomInfo.isShow = @(NO);
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

//删除数据库数据。 隐性删除
- (void)deleteChatRoomInfo
{
    self.isShow = @(NO);
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

//真实删除
+ (void)deleteAllChatRoomInfosReal
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"isShow",@(NO)];
    [ChatRoomInfo MR_deleteAllMatchingPredicate:pre];
}

- (ChatRoomInfo *)updateJoinUserCount:(NSNumber *)count
{
    self.joinUserCount = count;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return self;
}

@end
