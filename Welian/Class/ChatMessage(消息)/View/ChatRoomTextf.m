//
//  ChatRoomTextf.m
//  Welian
//
//  Created by dong on 15/6/12.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ChatRoomTextf.h"

@implementation ChatRoomTextf

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
        _textF = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, SuperSize.width-30-40, frame.size.height-10)];
        [_textF setBackgroundColor:[UIColor whiteColor]];
        _textF.borderStyle = UITextBorderStyleRoundedRect;
        [self addSubview:_textF];
    }
    return self;
}

@end
