//
//  ProjectInfoViewCell.m
//  Welian
//
//  Created by weLian on 15/5/21.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectInfoViewCell.h"
#import "WLMessageAvatorFactory.h"

#define kMarginLeft 10.f
#define kLogoHeight 37.f
#define kFinancingLeft 3.f

@interface ProjectInfoViewCell ()

@property (assign,nonatomic) BOOL isFinancing;
//赞
@property (assign,nonatomic) UIView *praiseView;
@property (assign,nonatomic) UIImageView *praiseImageView;
@property (assign,nonatomic) UILabel *praiseNumLabel;
//内容
@property (assign,nonatomic) UILabel *nameLabel;
@property (assign,nonatomic) UILabel *msgLabel;
@property (assign,nonatomic) UIImageView *financingImageView;
@property (assign,nonatomic) UIButton *logoBtn;

- (void)setup;

@end

@implementation ProjectInfoViewCell

- (void)dealloc
{
    _userInfoBlock = nil;
    _projectInfo = nil;
//    _iProjectInfo = nil;
    _iProjectDetailInfo = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setIProjectDetailInfo:(IProjectDetailInfo *)iProjectDetailInfo
{
    [super willChangeValueForKey:@"iProjectDetailInfo"];
    _iProjectDetailInfo = iProjectDetailInfo;
    [super didChangeValueForKey:@"iProjectDetailInfo"];
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_iProjectDetailInfo.user.avatar]
                                                    options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                        [_logoBtn setImage:[UIImage imageNamed:@"user_small"] forState:UIControlStateNormal];
                                                    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                        UIImage *avatorImage = [UIImage imageNamed:@"user_small"];
                                                        if (image) {
                                                            avatorImage = [WLMessageAvatorFactory avatarImageNamed:image messageAvatorType:WLMessageAvatorTypeCircle];
                                                        }
                                                        [_logoBtn setImage:avatorImage forState:UIControlStateNormal];
                                                    }];
//    [_logoImageView sd_setImageWithURL:[NSURL URLWithString:_iProjectDetailInfo.user.avatar]
//                      placeholderImage:[UIImage imageNamed:@"user_small"]
//                               options:SDWebImageRetryFailed|SDWebImageLowPriority];
    _praiseNumLabel.text = [_iProjectDetailInfo displayZancountInfo];
    _nameLabel.text = _iProjectDetailInfo.name;
    _msgLabel.text = _iProjectDetailInfo.intro;
    //status 1 正在融资，0不融资
    _financingImageView.hidden = _iProjectDetailInfo.status.integerValue == 1 ? NO : YES;
    self.isFinancing = _iProjectDetailInfo.status.boolValue;
}

//- (void)setIProjectInfo:(IProjectInfo *)iProjectInfo
//{
//    [super willChangeValueForKey:@"iProjectInfo"];
//    _iProjectInfo = iProjectInfo;
//    [super didChangeValueForKey:@"iProjectInfo"];
//    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_iProjectInfo.user.avatar]
//                                                    options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                                                        [_logoBtn setImage:[UIImage imageNamed:@"user_small"] forState:UIControlStateNormal];
//                                                    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                                                        UIImage *avatorImage = [UIImage imageNamed:@"user_small"];
//                                                        if (image) {
//                                                            avatorImage = [WLMessageAvatorFactory avatarImageNamed:image messageAvatorType:WLMessageAvatorTypeCircle];
//                                                        }
//                                                        [_logoBtn setImage:avatorImage forState:UIControlStateNormal];
//                                                    }];
////    [_logoImageView sd_setImageWithURL:[NSURL URLWithString:_iProjectInfo.user.avatar]
////                      placeholderImage:[UIImage imageNamed:@"user_small"]
////                               options:SDWebImageRetryFailed|SDWebImageLowPriority];
//    _praiseNumLabel.text = [_iProjectInfo displayZancountInfo];
//    _nameLabel.text = _iProjectInfo.name;
//    _msgLabel.text = _iProjectInfo.intro;
//    //status 1 正在融资，0不融资
//    _financingImageView.hidden = _iProjectInfo.status.integerValue == 1 ? NO : YES;
//    self.isFinancing = _iProjectInfo.status.boolValue;
//}

- (void)setProjectInfo:(ProjectInfo *)projectInfo
{
    [super willChangeValueForKey:@"projectInfo"];
    _projectInfo = projectInfo;
    [super didChangeValueForKey:@"projectInfo"];
    //头像
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_projectInfo.rsProjectUser.avatar]
                                                    options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                        [_logoBtn setImage:[UIImage imageNamed:@"user_small"] forState:UIControlStateNormal];
                                                    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                        UIImage *avatorImage = [UIImage imageNamed:@"user_small"];
                                                        if (image) {
                                                            avatorImage = [WLMessageAvatorFactory avatarImageNamed:image messageAvatorType:WLMessageAvatorTypeCircle];
                                                        }
                                                        [_logoBtn setImage:avatorImage forState:UIControlStateNormal];
                                                    }];
//    [_logoImageView sd_setImageWithURL:[NSURL URLWithString:_projectInfo.rsProjectUser.avatar]
//                      placeholderImage:[UIImage imageNamed:@"user_small"]
//                               options:SDWebImageRetryFailed|SDWebImageLowPriority];
    //赞数量
    _praiseNumLabel.text = [_projectInfo displayZancountInfo];
    _nameLabel.text = _projectInfo.name;
    _msgLabel.text = _projectInfo.intro;
    //status 1 正在融资，0不融资
    _financingImageView.hidden = _projectInfo.status.integerValue == 1 ? NO : YES;
    self.isFinancing = _projectInfo.status.boolValue;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _praiseView.size = CGSizeMake(29.f, 40.f);
    _praiseView.centerY = self.height / 2.f;
    _praiseView.left = kMarginLeft;
    
    [_praiseImageView sizeToFit];
    _praiseImageView.centerX = _praiseView.width / 2.f;
    _praiseImageView.bottom = _praiseView.height / 2.f - 2.f;
    
    [_praiseNumLabel sizeToFit];
    _praiseNumLabel.width = _praiseView.width;
    _praiseNumLabel.centerX = _praiseView.width / 2.f;
    _praiseNumLabel.top = _praiseImageView.bottom + 4.f;
    
    _logoBtn.size = CGSizeMake(kLogoHeight, kLogoHeight);
    _logoBtn.right = self.width - kMarginLeft;
    _logoBtn.centerY = self.height / 2.f;
    
    [_financingImageView sizeToFit];
    //标题最大的长度
    CGFloat nameMaxWidth = _logoBtn.left - _praiseView.right - kMarginLeft * 2.f - (_isFinancing ? (_financingImageView.width + kFinancingLeft) : 0);
    [_nameLabel sizeToFit];
    _nameLabel.left = _praiseView.right + kMarginLeft;
    _nameLabel.top = _praiseView.top;
    if (_nameLabel.width > nameMaxWidth) {
        _nameLabel.width = nameMaxWidth;
    }
    //是否融资图标
    _financingImageView.left = _nameLabel.right + kFinancingLeft;
    _financingImageView.centerY = _nameLabel.centerY;
    
    [_msgLabel sizeToFit];
    _msgLabel.width = _logoBtn.left - _nameLabel.left - kMarginLeft;
    _msgLabel.left = _nameLabel.left;
    _msgLabel.bottom = _praiseView.bottom;
}

#pragma mark - Private
- (void)setup
{
    //赞内容
    UIView *praiseView = [[UIView alloc] initWithFrame:CGRectZero];
    praiseView.backgroundColor = RGB(247.f, 247.f, 247.f);
    //圆角
    praiseView.layer.cornerRadius = 5.f;
    praiseView.layer.masksToBounds = YES;
    praiseView.layer.borderColor = kNormalLineColor.CGColor;
    praiseView.layer.borderWidth = 0.5f;
    [self addSubview:praiseView];
    self.praiseView = praiseView;
    
    //赞图标 xiangmu_good  discovery_good
    UIImageView *praiseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xiangmu_good"]];
    praiseImageView.backgroundColor = [UIColor clearColor];
    [praiseView addSubview:praiseImageView];
    self.praiseImageView = praiseImageView;
    
    //赞数量
    UILabel *praiseNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    praiseNumLabel.backgroundColor = [UIColor clearColor];
    praiseNumLabel.textColor = RGB(0.f, 93.f, 180.f);
    praiseNumLabel.font = kNormal12Font;
    praiseNumLabel.minimumScaleFactor = 0.8f;
    praiseNumLabel.adjustsFontSizeToFitWidth = YES;
    praiseNumLabel.textAlignment = NSTextAlignmentCenter;
    [praiseView addSubview:praiseNumLabel];
    self.praiseNumLabel = praiseNumLabel;
    
    //项目名称
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = kNormal16Font;
    nameLabel.textColor = RGB(51.f, 51.f, 51.f);
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
//    [nameLabel setDebug:YES];
    
    //项目简介
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    msgLabel.backgroundColor = [UIColor clearColor];
    msgLabel.font = kNormal13Font;
    msgLabel.textColor = RGB(125.f, 125.f, 125.f);
    [self addSubview:msgLabel];
    self.msgLabel = msgLabel;
    
    //正在融资
    UIImageView *financingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xiangmu_rongziing"]];
    financingImageView.backgroundColor = [UIColor clearColor];
    financingImageView.hidden = YES;
    [self addSubview:financingImageView];
    self.financingImageView = financingImageView;
    
    //头像
    UIButton *logoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    logoBtn.backgroundColor = [UIColor clearColor];
    logoBtn.layer.cornerRadius = kLogoHeight / 2.f;
    logoBtn.layer.masksToBounds = YES;
    logoBtn.layer.borderColor = kNormalLineColor.CGColor;
    logoBtn.layer.borderWidth = 0.5f;
    [logoBtn addTarget:self action:@selector(logoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:logoBtn];
    self.logoBtn = logoBtn;
}

- (void)logoBtnClicked:(UIButton *)sender
{
    if (_userInfoBlock) {
        if (_projectInfo) {
            _userInfoBlock(_projectInfo);
        }
//        if (_iProjectInfo) {
//            _userInfoBlock(_iProjectInfo);
//        }
        if (_iProjectDetailInfo) {
            _userInfoBlock(_iProjectDetailInfo);
        }
    }
}

@end
