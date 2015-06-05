//
//  NewsListViewCell.m
//  Welian
//
//  Created by weLian on 15/5/19.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "NewsListViewCell.h"
#import "CSLoadingImageView.h"

#define kMarginLeft 15.f
#define kTitleMarginEdge 8.f
#define kDetailMarginEdge 10.f
#define kBottomHeight 37.f
#define kTimeLabelHeight 19.f
#define kImageViewHeight [NSObject getHeightWithMaxWidth:maxWidth In4ScreWidth:260.f In4ScreeHeight:145.f]

@interface NewsListViewCell ()

@property (assign,nonatomic) UILabel *timeLabel;
@property (assign,nonatomic) UIView *cardView;
@property (assign,nonatomic) UILabel *titleLabel;
@property (assign,nonatomic) CSLoadingImageView *infoImageView;
@property (assign,nonatomic) UILabel *detailLabel;
@property (assign,nonatomic) UIView *lineView;
@property (assign,nonatomic) UILabel *operateLabel;
@property (assign,nonatomic) UIImageView *arrowRightImageView;

@end

@implementation NewsListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setInfoData:(TouTiaoInfo *)infoData
{
    [super willChangeValueForKey:@"infoData"];
    _infoData = infoData;
    [super didChangeValueForKey:@"infoData"];
    [_infoImageView sd_setImageWithURL:[NSURL URLWithString:_infoData.photo]
                      placeholderImage:nil
                               options:SDWebImageRetryFailed|SDWebImageLowPriority];
    _timeLabel.text = [_infoData displayCreateTime];
    _titleLabel.text = _infoData.title;
    _detailLabel.text = _infoData.intro;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_timeLabel sizeToFit];
    _timeLabel.width = _timeLabel.width + 15.f;
    _timeLabel.height = kTimeLabelHeight;
    _timeLabel.centerX = self.contentView.width / 2.f;
    _timeLabel.top = kMarginLeft;
    
    _cardView.size = CGSizeMake(self.contentView.width - kMarginLeft * 2.f, self.contentView.height - _timeLabel.height - kMarginLeft * 2.f);
    _cardView.centerX = self.contentView.width / 2.f;
    _cardView.bottom = self.contentView.height;
    
    CGFloat maxWidth = _cardView.width - kMarginLeft * 2.f;
    _titleLabel.width = maxWidth;
    [_titleLabel sizeToFit];
    _titleLabel.left = kMarginLeft;
    _titleLabel.top = kTitleMarginEdge;
    
    _infoImageView.size = CGSizeMake(_cardView.width - kMarginLeft * 2.f, kImageViewHeight);
    _infoImageView.centerX = _cardView.width / 2.f;
    _infoImageView.top = _titleLabel.bottom + kTitleMarginEdge;
    
    _detailLabel.width = maxWidth;
    [_detailLabel sizeToFit];
    _detailLabel.left = kMarginLeft;
    _detailLabel.top = _infoImageView.bottom + kDetailMarginEdge;
    
    _lineView.frame = CGRectMake(kMarginLeft, _detailLabel.bottom + kDetailMarginEdge, _cardView.width - kMarginLeft * 2.f, .8f);
    
    [_operateLabel sizeToFit];
    _operateLabel.left = kMarginLeft;
    _operateLabel.centerY = (_cardView.height - _lineView.bottom) / 2.f + _lineView.bottom;
    
    [_arrowRightImageView sizeToFit];
    _arrowRightImageView.right = _cardView.width - kMarginLeft;
    _arrowRightImageView.centerY = _operateLabel.centerY;
}

#pragma mark - private
- (void)setup
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = KBgLightGrayColor;
    
    //时间戳
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.backgroundColor = KBgGrayColor;
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = kNormal12Font;
    timeLabel.text = @"2015-05-15 09:32";
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.layer.cornerRadius = 10.f;
    timeLabel.layer.masksToBounds = YES;
    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    //内容页面
    UIView *cardView = [[UIView alloc] init];
    cardView.backgroundColor = [UIColor whiteColor];
    cardView.layer.cornerRadius = 5.f;
    cardView.layer.masksToBounds = YES;
    cardView.layer.borderColor = kNormalLineColor.CGColor;
    cardView.layer.borderWidth = 0.5f;
    [self.contentView addSubview:cardView];
    self.cardView = cardView;
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor blackColor];//kTitleNormalTextColor;
    titleLabel.font = WLFONT(18);
    titleLabel.text = @"";
    titleLabel.numberOfLines = 2.f;
    [cardView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    //图片
    CSLoadingImageView *infoImageView = [[CSLoadingImageView alloc ] init];
    infoImageView.backgroundColor = KBgLightGrayColor;
    infoImageView.image = nil;
    [cardView addSubview:infoImageView];
    self.infoImageView = infoImageView;
    
    //简介
    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.textColor = kTitleTextColor;
    detailLabel.font = kNormal14Font;
    detailLabel.text = @"";
    detailLabel.numberOfLines = 2.f;
    [cardView addSubview:detailLabel];
    self.detailLabel = detailLabel;
    
    //分割线
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = WLLineColor;
    [cardView addSubview:lineView];
    self.lineView = lineView;
    
    //操作提醒
    UILabel *operateLabel = [[UILabel alloc] init];
    operateLabel.textColor = kTitleNormalTextColor;
    operateLabel.font = kNormal14Font;
    operateLabel.text = @"阅读全文";
    [cardView addSubview:operateLabel];
    self.operateLabel = operateLabel;
    
    //箭头图标
    UIImageView *arrowRightImageView = [[UIImageView alloc ] initWithImage:[UIImage imageNamed:@"login_right"]];
    [cardView addSubview:arrowRightImageView];
    self.arrowRightImageView = arrowRightImageView;
}

//返回cell的高度
+ (CGFloat)configureWithNewInfo:(ITouTiaoModel *)newInfo
{
    CGFloat maxWidth = [[UIScreen mainScreen] bounds].size.width - kMarginLeft * 4.f;
    NSString *titleStr = newInfo.title;
    NSString *detailStr = newInfo.intro;
    //计算第一个label的高度
    CGSize size1 = [titleStr calculateSize:CGSizeMake(maxWidth, 44.f) font:WLFONT(18)];
    CGSize size2 = [detailStr calculateSize:CGSizeMake(maxWidth, 35.f) font:kNormal14Font];
    
    CGFloat titleHeight = (titleStr.length > 0 ? (size1.height + kTitleMarginEdge * 2.f) : kTitleMarginEdge);
    CGFloat detailHeight = (detailStr.length > 0 ? (size2.height + kDetailMarginEdge * 2.f) : kDetailMarginEdge);
    CGFloat height = titleHeight + detailHeight + kBottomHeight + kTimeLabelHeight + kMarginLeft * 2.f + kImageViewHeight;
    if (height > 60.f) {
        return height;
    }else{
        return 60.f;
    }
}

@end
