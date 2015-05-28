//
//  ShaiXuanCell.m
//  Welian
//
//  Created by dong on 15/5/28.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ShaiXuanCell.h"
#import "UIImage+ImageEffects.h"

@implementation ShaiXuanCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titeButton = [[UIButton alloc] initWithFrame:self.bounds];
        _titeButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_titeButton.titleLabel setFont:WLFONT(15)];
        [_titeButton setUserInteractionEnabled:NO];
        [_titeButton setTitleColor:KBlueTextColor forState:UIControlStateSelected];
        [_titeButton setTitleColor:kTitleTextColor forState:UIControlStateNormal];
        [_titeButton setBackgroundImage:[UIImage resizedImage:@"shaixuan_bg_selected.png"] forState:UIControlStateSelected];
        [_titeButton setBackgroundImage:[UIImage resizedImage:@"shaixuan_bg.png"] forState:UIControlStateNormal];
        [self addSubview:_titeButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [_titeButton setSelected:selected];
}



@end
