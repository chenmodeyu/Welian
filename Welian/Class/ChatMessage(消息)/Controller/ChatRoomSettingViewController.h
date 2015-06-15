//
//  ChatRoomSettingViewController.h
//  Welian
//
//  Created by weLian on 15/6/13.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "BasicViewController.h"

typedef enum : NSUInteger {
    ChatRoomSetTypeCreate = 0,
    ChatRoomSetTypeChange
} ChatRoomSetType;

@interface ChatRoomSettingViewController : BasicViewController

- (instancetype)initWithRoomType:(ChatRoomSetType)roomSetType ChatRoomInfo:(IChatRoomInfo *)chatRoomInfo;

@end
