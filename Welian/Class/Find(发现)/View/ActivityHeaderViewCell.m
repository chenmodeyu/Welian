//
//  ActivityHeaderViewCell.m
//  Welian
//
//  Created by weLian on 15/5/12.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ActivityHeaderViewCell.h"

@interface ActivityHeaderViewCell ()

@property (assign,nonatomic) UIView *topBgView;

@end

@implementation ActivityHeaderViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _topBgView.frame = CGRectMake(.0f, .0f, self.width, 15.f);
    
    [_titleLabel sizeToFit];
    _titleLabel.left = 15.f;
    _titleLabel.centerY = (self.height - _topBgView.height) / 2.f + _topBgView.height;
}

#pragma mark - Private
- (void)setup
{
    UIView *topBgView = [[UIView alloc] init];
    topBgView.backgroundColor = RGB(236.f, 238.f, 241.f);
    [self addSubview:topBgView];
    self.topBgView = topBgView;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = kNormal14Font;
    titleLabel.textColor = RGB(125.f, 125.f, 125.f);
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

@end
