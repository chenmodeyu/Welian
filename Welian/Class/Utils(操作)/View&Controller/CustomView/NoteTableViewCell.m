//
//  NoteTableViewCell.m
//  Welian
//
//  Created by weLian on 15/5/20.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "NoteTableViewCell.h"

#define kMarginLeft 15.f

@interface NoteTableViewCell ()

@property (assign,nonatomic) UILabel *noteLabel;

@end

@implementation NoteTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
    _noteLabel.centerX = self.width / 2.f;
    _noteLabel.centerY = self.height / 2.f;
}

#pragma mark - Private
- (void)setup
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //note
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    noteLabel.backgroundColor = [UIColor clearColor];
    noteLabel.textAlignment = NSTextAlignmentCenter;
    noteLabel.font = kNormal14Font;
    noteLabel.textColor = kNormalGrayTextColor;
    noteLabel.text = @"暂无数据";
    noteLabel.numberOfLines = 0;
    [self addSubview:noteLabel];
    self.noteLabel = noteLabel;
}

@end
