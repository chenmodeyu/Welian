//
//  WLChatCustomCardCell.h
//  Welian
//
//  Created by dong on 15/6/17.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "WLMessageCardView.h"

typedef void(^ChatCardIconClickBlock)(void);

typedef void(^ChatCardClickBlock)(void);

typedef void(^ChatCellDeleteBlock)(void);

@interface WLChatCustomCardCell : RCMessageBaseCell 

@property (nonatomic, strong) ChatCardIconClickBlock chatIconBlock;

@property (nonatomic, strong) ChatCardClickBlock chatCardBlock;

@property (nonatomic, strong) ChatCellDeleteBlock chatDeleteBlock;

@property (nonatomic, strong) WLMessageCardView *msgCardView;

@property (nonatomic, strong) UIButton *avatorBut;

+ (CGSize)getCellSizeWithCardMessage:(CustomCardMessage *)cardMsg;

@end
