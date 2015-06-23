//
//  ActivityListViewCell.m
//  Welian
//
//  Created by weLian on 15/2/7.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ActivityListViewCell.h"
#import "CSLoadingImageView.h"

#define kImageViewWidth 115.f
#define kImageViewHeight 86.f
#define kMarginLeft 10.f
#define kMarginTop 15.f
#define kMarginEdge 10.f

@interface ActivityListViewCell ()

@property (assign,nonatomic) CSLoadingImageView *iconImageView;
@property (assign,nonatomic) UIImageView *specialImageView;
@property (assign,nonatomic) UIImageView *joinedImageView;
@property (assign,nonatomic) UILabel *titleLabel;
@property (assign,nonatomic) UILabel *detailTitleLabel;
@property (assign,nonatomic) UIButton *timeBtn;
@property (assign,nonatomic) UIButton *locationBtn;
@property (assign,nonatomic) UILabel *statusLabel;
@property (assign,nonatomic) UILabel *numLabel;
@property (assign,nonatomic) UILabel *dateLabel;

@end

@implementation ActivityListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

//最大的图片宽度不超过屏幕一般
- (CGSize)fitsize:(CGSize)thisSize
{
    if(thisSize.width == 0 && thisSize.height ==0)
        return CGSizeMake(0, 0);
    CGFloat maxWidth = ScreenWidth / 1.5f;
    CGFloat wscale = thisSize.width / maxWidth;
    
    if (thisSize.width > maxWidth) {
        return CGSizeMake(maxWidth, thisSize.height/wscale);
    }else{
        return thisSize;
    }
}

- (void)setActivityInfo:(ActivityInfo *)activityInfo
{
    [super willChangeValueForKey:@"activityInfo"];
    _activityInfo = activityInfo;
    [super didChangeValueForKey:@"activityInfo"];
    //设置图片    
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:_activityInfo.logo]
                      placeholderImage:nil
                               options:SDWebImageRetryFailed|SDWebImageLowPriority
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 //黑白
                                 //status 0 还没开始，1进行中。2结束
                                 if (_activityInfo.status.integerValue == 2) {
                                     //压缩原图片的一半大小
                                     image = [image imageByScalingAndCroppingForSize:[self fitsize:image.size]];
                                     [_iconImageView setImage:[image partialImageWithPercentage:0 vertical:YES grayscaleRest:YES]];
                                     //已报名的
                                     [_joinedImageView setImage:[[UIImage imageNamed:@"discovery_activity_list_already"] partialImageWithPercentage:0 vertical:YES grayscaleRest:YES]];
                                 }else{
                                     _iconImageView.image = image;
                                     _joinedImageView.image = [UIImage imageNamed:@"discovery_activity_list_already"];
                                 }
                             }];
     //特殊标记  activity_list_hot_logo    activity_list_new_logo
    //0正常，1:new,2:hot
    if (_activityInfo.sorttype.integerValue == 0) {
        _specialImageView.image = nil;
    }else{
        _specialImageView.image = [UIImage imageNamed:_activityInfo.sorttype.integerValue == 1 ? @"activity_list_new_logo" : @"activity_list_hot_logo"];
    }
    //status 0 还没开始，1进行中。2结束
    _specialImageView.hidden = _activityInfo.status.integerValue == 2 ? YES : NO;
    _joinedImageView.hidden = !_activityInfo.isjoined.boolValue;
    _titleLabel.text = _activityInfo.name;
    _detailTitleLabel.text = _activityInfo.sponsor.length > 0 ? [NSString stringWithFormat:@"主办方：%@",_activityInfo.sponsor] : @"";
    
    //设置城市
    [_locationBtn setTitle:(_activityInfo.city.length > 0 ? _activityInfo.city : @"未知") forState:UIControlStateNormal];
    //设置日期
    [_timeBtn setTitle:[[_activityInfo.startime dateFromNormalString] formattedDateWithFormat:@"MM/dd"] forState:UIControlStateNormal];
    _dateLabel.text = [_activityInfo displayStartWeekDay];
    
    if(_activityInfo.type.integerValue == 0){
        //免费活动
        if(_activityInfo.limited.integerValue == 0){
            //不限人数，可以报名
            _statusLabel.text = @"报名";
            _numLabel.hidden = NO;
            _numLabel.text = _activityInfo.joined.stringValue;
        }else{
            if(_activityInfo.joined.integerValue >= _activityInfo.limited.integerValue){
                _numLabel.hidden = YES;
                _numLabel.text = @"";
                _statusLabel.text = @"已报满";
            }else{
                _statusLabel.text = @"报名";
                _numLabel.hidden = NO;
                _numLabel.text = _activityInfo.joined.stringValue;
            }
        }
    }else{
        //收费
        if(_activityInfo.limited.integerValue > 0){
            _statusLabel.text = @"报名";
            _numLabel.hidden = NO;
            _numLabel.text = _activityInfo.joined.stringValue;
        }else{
            _numLabel.hidden = YES;
            _numLabel.text = @"";
            _statusLabel.text = @"已报满";
        }
    }
    
    //设置字体颜色
//    [_timeBtn setTitleColor:(_activityInfo.status.integerValue == 2 ? kNormalTextColor : KBlueTextColor) forState:UIControlStateNormal];
//    _numLabel.textColor = _activityInfo.status.integerValue == 2 ? kNormalTextColor : KBlueTextColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _iconImageView.size = CGSizeMake(kImageViewWidth, self.contentView.height - kMarginTop * 2.f);
    _iconImageView.left = kMarginLeft;
    _iconImageView.centerY = self.contentView.height / 2.f;
    
    [_specialImageView sizeToFit];
    _specialImageView.left = _iconImageView.left - 3.f;
    _specialImageView.top = _iconImageView.top + 6.f;
    
    [_joinedImageView sizeToFit];
    _joinedImageView.right = self.contentView.width;
    _joinedImageView.top = 0.f;
    
    _titleLabel.width = self.contentView.width - _iconImageView.right - kMarginEdge - (_joinedImageView.hidden == NO ? _joinedImageView.width : kMarginEdge);
    [_titleLabel sizeToFit];
    _titleLabel.left = _iconImageView.right + kMarginEdge;
    _titleLabel.top = _iconImageView.top;
    
    [_detailTitleLabel sizeToFit];
    _detailTitleLabel.width = _titleLabel.width;
    _detailTitleLabel.left = _titleLabel.left;
    _detailTitleLabel.top = _titleLabel.bottom + 6.f;
    
    [_timeBtn sizeToFit];
    _timeBtn.width = _timeBtn.width + 5.f;
    _timeBtn.left = _titleLabel.left;
    _timeBtn.bottom = _iconImageView.bottom;
    
    [_dateLabel sizeToFit];
    _dateLabel.left = _timeBtn.right;
    _dateLabel.centerY = _timeBtn.centerY;
    
    [_statusLabel sizeToFit];
    _statusLabel.right = self.contentView.width - kMarginLeft;
    _statusLabel.centerY = _timeBtn.centerY;
    
    [_numLabel sizeToFit];
    _numLabel.right = _statusLabel.left;
    _numLabel.centerY = _statusLabel.centerY;
    
    [_locationBtn sizeToFit];
    _locationBtn.width = _numLabel.left - _dateLabel.right - kMarginEdge;
    _locationBtn.left = _dateLabel.right + kMarginEdge / 2.f;
    _locationBtn.centerY = _dateLabel.centerY;
}

#pragma mark - Private
- (void)setup
{
    //图标
    CSLoadingImageView *iconImageView = [[CSLoadingImageView alloc] init];
    iconImageView.backgroundColor = IWGlobalBg;
    iconImageView.layer.borderColor = kNormalLineColor.CGColor;
    iconImageView.layer.borderWidth = 0.5f;
    iconImageView.layer.cornerRadius = 3.f;
    iconImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:iconImageView];
    self.iconImageView = iconImageView;
//    [iconImageView setDebug:YES];
    
    //特殊标记  activity_list_hot_logo    activity_list_new_logo
    UIImageView *specialImageView = [[UIImageView alloc] init];
    specialImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:specialImageView];
    self.specialImageView = specialImageView;
//    [_specialImageView setDebug:YES];
    
    //以报名标记
    UIImageView *joinedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"discovery_activity_list_already"]];
    joinedImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:joinedImageView];
    self.joinedImageView = joinedImageView;
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = kTitleNormalTextColor;
    titleLabel.font = kNormal16Font;
//    titleLabel.text = @"杭州布鲁姆斯伯里沙龙咯好哦好哦配合哦好累了据了解";
    titleLabel.numberOfLines = 2;
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
//    [titleLabel setDebug:YES];
    
    //副标题
    UILabel *detailTitleLabel = [[UILabel alloc] init];
    detailTitleLabel.backgroundColor = [UIColor clearColor];
    detailTitleLabel.textColor = kNormalTextColor;
    detailTitleLabel.font = kNormal13Font;
//    detailTitleLabel.text = @"主办方：微链、迭代资本";
    [self.contentView addSubview:detailTitleLabel];
    self.detailTitleLabel = detailTitleLabel;
    
    //时间
    UIButton *timeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    timeBtn.backgroundColor = [UIColor clearColor];
    timeBtn.titleLabel.font = kNormal12Font;
    [timeBtn setTitle:@"6/18" forState:UIControlStateNormal];
    [timeBtn setTitleColor:kNormalTextColor forState:UIControlStateNormal];
    //discovery_activity_list_time
    [timeBtn setImage:[UIImage imageNamed:@"activity_list_time_logo"] forState:UIControlStateNormal];
    timeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    [self.contentView addSubview:timeBtn];
    self.timeBtn = timeBtn;
    
    //星期几
    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.textColor = kNormalTextColor;
    dateLabel.font = kNormal12Font;
//    dateLabel.text = @"周日";
    [self.contentView addSubview:dateLabel];
    self.dateLabel = dateLabel;
    
    //城市
    UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn.backgroundColor = [UIColor clearColor];
    locationBtn.titleLabel.font = kNormal12Font;
    [locationBtn setTitle:@"上海" forState:UIControlStateNormal];
    [locationBtn setTitleColor:kNormalTextColor forState:UIControlStateNormal];
    //discovery_activity_list_place
    locationBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    [locationBtn setImage:[UIImage imageNamed:@"activity_list_place_logo"] forState:UIControlStateNormal];
    [self.contentView addSubview:locationBtn];
    self.locationBtn = locationBtn;
//    [locationBtn setDebug:YES];
    
    //状态
    UILabel *statusLabel = [[UILabel alloc] init];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textColor = kNormalTextColor;
    statusLabel.font = kNormal12Font;
    statusLabel.text = @"报名";
    [self.contentView addSubview:statusLabel];
    self.statusLabel = statusLabel;
    
    //人数
    UILabel *numLabel = [[UILabel alloc] init];
    numLabel.backgroundColor = [UIColor clearColor];
    numLabel.textColor = KBlueTextColor;
    numLabel.font = kNormal12Font;
    numLabel.text = @"0";
    [self.contentView addSubview:numLabel];
    self.numLabel = numLabel;
}

@end
