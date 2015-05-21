//
//  FinancingInfoView.m
//  Welian
//
//  Created by weLian on 15/5/20.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "FinancingInfoView.h"

#define kMarginLeft 15.f
#define kMarginTop 20.f
#define kMarginEdge 10.f

@interface FinancingInfoView ()

@property (assign,nonatomic) UILabel *stempLabel;
@property (assign,nonatomic) UILabel *moneyLabel;
@property (assign,nonatomic) UILabel *stockLabel;
@property (assign,nonatomic) UILabel *valuationsLabel;
@property (assign,nonatomic) UILabel *aboutLabel;

@end

@implementation FinancingInfoView

- (void)dealloc
{
    _iProjectDetailInfo = nil;
}

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

- (void)setIProjectDetailInfo:(IProjectDetailInfo *)iProjectDetailInfo
{
    [super willChangeValueForKey:@"iProjectDetailInfo"];
    _iProjectDetailInfo = iProjectDetailInfo;
    [super didChangeValueForKey:@"iProjectDetailInfo"];
    _stempLabel.text = [NSString stringWithFormat:@"融资阶段：%@",[_iProjectDetailInfo displayStage]];
    [_stempLabel setAttributedText:[NSObject getAttributedInfoString:_stempLabel.text
                                                           searchStr:@"融资阶段："
                                                               color:kTitleNormalTextColor
                                                                font:kNormal14Font]];
    
    _moneyLabel.text = [NSString stringWithFormat:@"融资金额：%d 万",_iProjectDetailInfo.amount.intValue];
    [_moneyLabel setAttributedText:[NSObject getAttributedInfoString:_moneyLabel.text
                                                           searchStr:@"融资金额："
                                                               color:kTitleNormalTextColor
                                                                font:kNormal14Font]];
    
    _stockLabel.text = [NSString stringWithFormat:@"出让股份：%@ %%",_iProjectDetailInfo.share];
    [_stockLabel setAttributedText:[NSObject getAttributedInfoString:_stockLabel.text
                                                           searchStr:@"出让股份："
                                                               color:kTitleNormalTextColor
                                                                font:kNormal14Font]];
    
    float valuationInfo = _iProjectDetailInfo.amount.floatValue/_iProjectDetailInfo.share.floatValue * 100;
    _valuationsLabel.text = [NSString stringWithFormat:@"投后估值：%.0f 万",valuationInfo];
    [_valuationsLabel setAttributedText:[NSObject getAttributedInfoString:_valuationsLabel.text
                                                                searchStr:@"投后估值："
                                                                    color:kTitleNormalTextColor
                                                                     font:kNormal14Font]];
    
    _aboutLabel.text = [NSString stringWithFormat:@"融资说明：%@", _iProjectDetailInfo.financing.length > 0 ? _iProjectDetailInfo.financing : @"暂无说明"];
    [_aboutLabel setAttributedText:[NSObject getAttributedInfoString:_aboutLabel.text
                                                           searchStr:@"融资说明："
                                                               color:kTitleNormalTextColor
                                                                font:kNormal14Font]];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_stempLabel sizeToFit];
    _stempLabel.left = kMarginLeft;
    _stempLabel.top = kMarginTop;
    
    [_moneyLabel sizeToFit];
    _moneyLabel.left = kMarginLeft;
    _moneyLabel.top = _stempLabel.bottom + kMarginEdge;
    
    [_stockLabel sizeToFit];
    _stockLabel.left = kMarginLeft;
    _stockLabel.top = _moneyLabel.bottom + kMarginEdge;
    
    [_valuationsLabel sizeToFit];
    _valuationsLabel.left = kMarginLeft;
    _valuationsLabel.top = _stockLabel.bottom + kMarginEdge;
    
    _aboutLabel.width = self.width - kMarginLeft * 2.f;
    [_aboutLabel sizeToFit];
    _aboutLabel.left = kMarginLeft;
    _aboutLabel.top = _valuationsLabel.bottom + kMarginTop;
}

#pragma mark - Private
- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    
    //融资阶段
    UILabel *stempLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    stempLabel.backgroundColor = [UIColor clearColor];
    stempLabel.font = kNormal14Font;
    stempLabel.textColor = kTitleTextColor;
    stempLabel.text = @"融资阶段：A轮";
    [stempLabel setAttributedText:[NSObject getAttributedInfoString:stempLabel.text
                                                                 searchStr:@"融资阶段："
                                                              color:kTitleNormalTextColor
                                                               font:kNormal14Font]];
    [self addSubview:stempLabel];
    self.stempLabel = stempLabel;
    
    //融资金额
    UILabel *moneyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    moneyLabel.backgroundColor = [UIColor clearColor];
    moneyLabel.font = kNormal14Font;
    moneyLabel.textColor = kTitleTextColor;
    moneyLabel.text = @"融资金额：100 万";
    [moneyLabel setAttributedText:[NSObject getAttributedInfoString:moneyLabel.text
                                                          searchStr:@"融资金额："
                                                              color:kTitleNormalTextColor
                                                               font:kNormal14Font]];
    [self addSubview:moneyLabel];
    self.moneyLabel = moneyLabel;
    
    
    //出让股份
    UILabel *stockLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    stockLabel.backgroundColor = [UIColor clearColor];
    stockLabel.font = kNormal14Font;
    stockLabel.textColor = kTitleTextColor;
    stockLabel.text = @"出让股份：10 %";
    [stockLabel setAttributedText:[NSObject getAttributedInfoString:stockLabel.text
                                                          searchStr:@"出让股份："
                                                              color:kTitleNormalTextColor
                                                               font:kNormal14Font]];
    [self addSubview:stockLabel];
    self.stockLabel = stockLabel;
    
    
    //投后估值
    UILabel *valuationsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    valuationsLabel.backgroundColor = [UIColor clearColor];
    valuationsLabel.font = kNormal14Font;
    valuationsLabel.textColor = kTitleTextColor;
    valuationsLabel.text = @"投后估值：1000 万";
    [valuationsLabel setAttributedText:[NSObject getAttributedInfoString:valuationsLabel.text
                                                               searchStr:@"投后估值："
                                                                   color:kTitleNormalTextColor
                                                                    font:kNormal14Font]];
    [self addSubview:valuationsLabel];
    self.valuationsLabel = valuationsLabel;
    
    //融资说明
    UILabel *aboutLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    aboutLabel.backgroundColor = [UIColor clearColor];
    aboutLabel.numberOfLines = 0;
    aboutLabel.font = kNormal14Font;
    aboutLabel.textColor = kTitleTextColor;
    aboutLabel.text = @"融资说明：杭州传送门网络科技有限公司成立于2014年8月，旗下产品“微链”专注于为互联网创业提供社交服务，并基于社交关系衍生出系统性的创业服务解决方案。公司的主要创始人均具有丰富的创业、投资及媒体从业经验。公司扎根于中国互联网重镇杭州，深刻意识到互联网对中国未来的巨大影响，并全力投身其中。这是创业最好的年代，抓住机遇吧，创业者们！微链是一款专注于互联网创业的社交产品，致力于通过人与人的连接让创业变得更加简单有趣，与互联网创业有关的伙伴们可以在微链上享受自由且专注的交流。微链的团队在互联网创业和投资领域有很深的积累，团队聚集了一批心怀梦想、坚信创业必将改变中国的年轻人。在创立一个月之内，微链已经获得了投资界的青睐并顺利拿到了风险投资。这是一个属于创业者的时代，在我们的理解中，创业是一种态度，创始人、投资人、已经和正要加入创业企业的人才，都是创业者。对你而言，最重要的，是找到他们，并且连接他们。我们认为，移动互联网的时代里，单打独斗那不叫创业，圈子将产生巨大的力量。微链正是这样一款产品，帮助你连接他人，与圈子一起创业。";
    [aboutLabel setAttributedText:[NSObject getAttributedInfoString:aboutLabel.text
                                                          searchStr:@"融资说明："
                                                              color:kTitleNormalTextColor
                                                               font:kNormal14Font]];
    [self addSubview:aboutLabel];
    self.aboutLabel = aboutLabel;
}

//返回高度
+ (CGFloat)configureWithIProjectInfo:(IProjectDetailInfo *)iProjectInfo
{
    NSString *stemStr = [NSString stringWithFormat:@"融资阶段：%@",[iProjectInfo displayStage]];
    NSString *moneyStr = [NSString stringWithFormat:@"融资金额：%d 万",iProjectInfo.amount.intValue];
    NSString *stockStr = [NSString stringWithFormat:@"出让股份：%@ %%",iProjectInfo.share];
    float valuationInfo = iProjectInfo.amount.floatValue/iProjectInfo.share.floatValue * 100;
    NSString *valuationsStr = [NSString stringWithFormat:@"投后估值：%.0f 万",valuationInfo];
    NSString *aboutStr = [NSString stringWithFormat:@"融资说明：%@", iProjectInfo.financing.length > 0 ? iProjectInfo.financing : @"暂无说明"];
    
    CGFloat maxWidth = [[UIScreen mainScreen] bounds].size.width - kMarginLeft * 2.f;
    //计算第一个label的高度
    CGSize size1 = [stemStr calculateSize:CGSizeMake(maxWidth, FLT_MAX) font:kNormal14Font];
    CGSize size2 = [moneyStr calculateSize:CGSizeMake(maxWidth, FLT_MAX) font:kNormal14Font];
    CGSize size3 = [stockStr calculateSize:CGSizeMake(maxWidth, FLT_MAX) font:kNormal14Font];
    CGSize size4 = [valuationsStr calculateSize:CGSizeMake(maxWidth, FLT_MAX) font:kNormal14Font];
    CGSize size5 = [aboutStr calculateSize:CGSizeMake(maxWidth, FLT_MAX) font:kNormal14Font];
    
    CGFloat height = size1.height + size2.height + size3.height + size4.height + size5.height + kMarginEdge * 3.f + kMarginTop * 3.f;
    if (height > 60.f) {
        return height;
    }else{
        return 60.f;
    }

    
}

@end
