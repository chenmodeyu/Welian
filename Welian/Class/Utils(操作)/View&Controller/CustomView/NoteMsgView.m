//
//  NoteMsgView.m
//  Welian
//
//  Created by weLian on 15/5/20.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "NoteMsgView.h"

#define kMarginLeft 15.f

@interface NoteMsgView ()

@property (assign,nonatomic) UILabel *noteLabel;

@end

@implementation NoteMsgView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setNoteInfo:(NSString *)noteInfo
{
    [super willChangeValueForKey:@"noteInfo"];
    _noteInfo = noteInfo;
    [super didChangeValueForKey:@"noteInfo"];
    _noteLabel.text = _noteInfo;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _noteLabel.width = self.width - kMarginLeft * 2.f;
    [_noteLabel sizeToFit];
    _noteLabel.left = kMarginLeft;
    _noteLabel.centerY = self.height / 2.f;
}

#pragma mark - Private
- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    
    //note
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    noteLabel.backgroundColor = [UIColor clearColor];
    noteLabel.font = kNormal12Font;
    noteLabel.textColor = kNormalGrayTextColor;
    noteLabel.text = @"";
    noteLabel.numberOfLines = 0;
    [self addSubview:noteLabel];
    self.noteLabel = noteLabel;
}

@end
