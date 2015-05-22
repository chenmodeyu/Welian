//
//  ProjectClassViewCell.m
//  Welian
//
//  Created by weLian on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectClassViewCell.h"
#import "CSLoadingImageView.h"

#define kMarginLeft 10.f

@interface ProjectClassViewCell ()

@property (assign,nonatomic) CSLoadingImageView *bgImageView;
//@property (assign,nonatomic) UIView *beforeView;
@property (assign,nonatomic) UILabel *titleLabel;
@property (assign,nonatomic) UILabel *detailTitleLabel;

@end

@implementation ProjectClassViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setProjectClassInfo:(ProjectClassInfo *)projectClassInfo
{
    [super willChangeValueForKey:@"projectClassInfo"];
    _projectClassInfo = projectClassInfo;
    [super didChangeValueForKey:@"projectClassInfo"];
//    [_bgImageView sd_setImageWithURL:[NSURL URLWithString:_projectClassInfo.photo]
//                    placeholderImage:nil
//                             options:SDWebImageRetryFailed|SDWebImageLowPriority];
    
    [_bgImageView sd_setImageWithURL:[NSURL URLWithString:_projectClassInfo.photo]
                  placeholderImage:nil
                           options:SDWebImageRetryFailed|SDWebImageLowPriority
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             //图片进行染色（Tinting）、增加亮度（lightening）以及降低亮度（darkening）
                             [_bgImageView setImage:[image rt_darkenWithLevel:0.3f]];
                         }];
    
    _titleLabel.text = _projectClassInfo.title;
    _detailTitleLabel.text = [NSString stringWithFormat:@"%d个项目",_projectClassInfo.projectCount.integerValue];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _bgImageView.size = CGSizeMake(self.width - kMarginLeft * 2.f, self.height - kMarginLeft);
    _bgImageView.top = kMarginLeft;
    _bgImageView.centerX = self.width / 2.f;
    
//    _beforeView.frame = _bgImageView.frame;
    
    [_titleLabel sizeToFit];
    _titleLabel.centerX = self.width / 2.f;
    _titleLabel.centerY = self.height / 2.f - kMarginLeft;
    
    [_detailTitleLabel sizeToFit];
    _detailTitleLabel.centerX = _titleLabel.centerX;
    _detailTitleLabel.top = _titleLabel.bottom + kMarginLeft;
}

#pragma mark - Private
- (void)setup
{
    self.backgroundColor = KBgLightGrayColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CSLoadingImageView *bgImageView = [[CSLoadingImageView alloc] init];
    bgImageView.layer.cornerRadius = 5.f;
    bgImageView.layer.masksToBounds = YES;
    bgImageView.backgroundColor = [UIColor whiteColor];
    [self addSubview:bgImageView];
    self.bgImageView = bgImageView;
    
    //覆盖层
//    UIView *beforeView = [[UIView alloc] init];
//    beforeView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
//    beforeView.layer.cornerRadius = 5.f;
//    beforeView.layer.masksToBounds = YES;
//    [self addSubview:beforeView];
//    self.beforeView = beforeView;
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = kNormalBlod19Font;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    //副标题
    UILabel *detailTitleLabel = [[UILabel alloc] init];
    detailTitleLabel.textColor = [UIColor whiteColor];
    detailTitleLabel.font = kNormal12Font;
    [self addSubview:detailTitleLabel];
    self.detailTitleLabel = detailTitleLabel;
    
}

@end
