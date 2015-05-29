//
//  InvestorInfoCell.m
//  Welian
//
//  Created by dong on 15/5/26.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "InvestorInfoCell.h"
#import "InvestorUserModel.h"

@interface InvestorInfoCell()
{
    UIView *_backgView;
    
    UIView *_industryView;
    UIView *_stageView;
    UIView *_itemView;
    UIView *_firmView;
    
    UILabel *_industryTiteLabel;
    UILabel *_stageTiteLabel;
    UILabel *_itemTiteLabel;
    UILabel *_firmTiteLabel;
    
    UILabel *_industryLabel;
    UILabel *_stageLabel;
    UILabel *_itemLabel;
    UILabel *_firmNameLabel;
    UILabel *_firmIntroLabel;
    UIImageView *_firmIconImage;
    
    UIView *_line1;
    UIView *_line2;
    UIView *_line3;
}
@end

@implementation InvestorInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _backgView = [[UIView alloc] init];
        [self addSubview:_backgView];
        
        _industryView = [[UIView alloc] init];
        [_backgView addSubview:_industryView];
        _industryTiteLabel = [self getTiteLabelWithText:@"投资领域："];
        [_industryView addSubview:_industryTiteLabel];
        _industryLabel = [self loadInfoLabel];
        [_industryView addSubview:_industryLabel];
        
        
        _stageView = [[UIView alloc] init];
        [_backgView addSubview:_stageView];
        _stageTiteLabel = [self getTiteLabelWithText:@"投资阶段："];
        [_stageView addSubview:_stageTiteLabel];
        _stageLabel = [self loadInfoLabel];
        [_stageView addSubview:_stageLabel];
        
        
        _itemView = [[UIView alloc] init];
        [_backgView addSubview:_itemView];
        _itemTiteLabel = [self getTiteLabelWithText:@"投资案例："];
        [_itemView addSubview:_itemTiteLabel];
        _itemLabel = [self loadInfoLabel];
        [_itemView addSubview:_itemLabel];
        
        
        _firmView = [[UIView alloc] init];
        [_backgView addSubview:_firmView];
        _firmTiteLabel = [self getTiteLabelWithText:@"投资机构："];
        [_firmView addSubview:_firmTiteLabel];
        _firmIconImage = [[UIImageView alloc] init];
        [_firmView addSubview:_firmIconImage];
        _firmNameLabel = [[UILabel alloc] init];
        [_firmNameLabel setFont:WLFONT(15)];
        [_firmNameLabel setTextColor:WLRGB(51, 51, 51)];
        [_firmView addSubview:_firmNameLabel];
        _firmIntroLabel = [[UILabel alloc] init];
        [_firmIntroLabel setTextColor:WLRGB(178, 178, 178)];
        [_firmIntroLabel setFont:WLFONT(15)];
        [_firmView addSubview:_firmIntroLabel];
        _firmBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_firmView addSubview:_firmBut];
        
        _line1 = [self loadLineView];
        [_industryView addSubview:_line1];
        _line2 = [self loadLineView];
        [_stageView addSubview:_line2];
        _line3 = [self loadLineView];
        [_itemView addSubview:_line3];
    }
    return self;
}

- (void)setInvestorUserM:(InvestorUserModel *)investorUserM
{
    _investorUserM = investorUserM;
    
    CGFloat titeLabelW = 78;
    CGFloat labelY = 10;
    CGSize labelSize = CGSizeMake(SuperSize.width-60-titeLabelW-2*10, MAXFLOAT);
    CGFloat labelX = titeLabelW+10;
    CGFloat viewWidth = SuperSize.width - 60;
    
    NSString *industryStr = investorUserM.industrysStr?:@"暂无";
    NSString *stagesStr = investorUserM.stagesStr?:@"暂无";
    NSString *itemsStr = investorUserM.itemsStr?:@"暂无";
    
    CGSize indusSize = [industryStr sizeWithCustomFont:WLFONT(14) constrainedToSize:labelSize];
    CGSize stageSize = [stagesStr sizeWithCustomFont:WLFONT(14) constrainedToSize:labelSize];
    CGSize itemSize = [itemsStr sizeWithCustomFont:WLFONT(14) constrainedToSize:labelSize];
   
    [_industryLabel setFrame:CGRectMake(labelX, labelY, indusSize.width, indusSize.height)];
    [_industryTiteLabel setFrame:CGRectMake(0, 0, titeLabelW, indusSize.height+2*labelY)];
    [_industryView setFrame:CGRectMake(0, 0, viewWidth, _industryTiteLabel.height)];
    [_line1 setLeft:0];
    [_line1 setTop:_industryTiteLabel.bottom-0.5];
    [_industryLabel setText:industryStr];
    
    [_stageLabel setFrame:CGRectMake(labelX, labelY, stageSize.width, stageSize.height)];
    [_stageTiteLabel setFrame:CGRectMake(0, 0, titeLabelW, stageSize.height+2*labelY)];
    [_stageView setFrame:CGRectMake(0, _industryView.bottom, viewWidth, _stageTiteLabel.height)];
    [_line2 setLeft:0];
    [_line2 setTop:_stageTiteLabel.bottom-0.5];
    [_stageLabel setText:stagesStr];

    [_itemLabel setFrame:CGRectMake(labelX, labelY, itemSize.width, itemSize.height)];
    [_itemTiteLabel setFrame:CGRectMake(0, 0, titeLabelW, _itemLabel.height+2*labelY)];
    [_itemView setFrame:CGRectMake(0, _stageView.bottom, viewWidth, _itemTiteLabel.height)];
    [_line3 setLeft:0];
    [_line3 setTop:_itemTiteLabel.bottom-0.5];
    [_itemLabel setText:itemsStr];
    
    
    CGFloat firmViewH = 70;
    if (investorUserM.firm.firmid) {
        [_firmNameLabel setText:investorUserM.firm.title];
        [_firmIconImage sd_setImageWithURL:[NSURL URLWithString:investorUserM.firm.logo] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageLowPriority];
        [_firmIntroLabel setText:investorUserM.firm.intro];
        
        [_firmView setFrame:CGRectMake(0, _itemView.bottom, viewWidth, firmViewH)];
        [_firmTiteLabel setFrame:CGRectMake(0, 0, titeLabelW, firmViewH)];
        [_firmIconImage setFrame:CGRectMake(labelX, labelY, 40, 40)];
        [_firmNameLabel setFrame:CGRectMake(_firmIconImage.right+labelY, labelY, labelSize.width-50, 20)];
        [_firmIntroLabel setFrame:CGRectMake(_firmNameLabel.left, _firmNameLabel.bottom+5, _firmNameLabel.width, 20)];
        [_firmBut setFrame:CGRectMake(0, 0, SuperSize.width-30*2, firmViewH)];
        
    }else{
        [_firmView setFrame:CGRectZero];
        _firmView.top = _itemView.bottom;
    }
    
    [_backgView setFrame:CGRectMake(30, 10, SuperSize.width-30*2, _firmView.bottom)];
    _backgView.layer.borderWidth = 0.5;
    _backgView.layer.masksToBounds = YES;
    _backgView.layer.cornerRadius = 8;
    _backgView.layer.borderColor = [WLRGB(204, 204, 204) CGColor];
}

+ (CGFloat)getCellHeightWith:(InvestorUserModel *)investorUserM
{
    CGFloat titeLabelW = 78;
    CGFloat labelY = 10;
    CGSize labelSize = CGSizeMake(SuperSize.width-60-titeLabelW-2*10, MAXFLOAT);
    CGSize indusSize = CGSizeZero;
    CGSize stageSize = CGSizeZero;
    CGSize itemSize = CGSizeZero;
    CGFloat firmH = 0.0;
    NSInteger count = 9;
    
    indusSize = [investorUserM.industrysStr?:@"暂无" sizeWithCustomFont:WLFONT(14) constrainedToSize:labelSize];
    
    stageSize = [investorUserM.stagesStr?:@"暂无" sizeWithCustomFont:WLFONT(14) constrainedToSize:labelSize];

    itemSize = [investorUserM.itemsStr?:@"暂无" sizeWithCustomFont:WLFONT(14) constrainedToSize:labelSize];

    if (investorUserM.firm.firmid) {
        firmH = 70;
    }
    CGFloat cellHeigh = indusSize.height+stageSize.height+itemSize.height+count*labelY+firmH;
    return cellHeigh;
}


- (UILabel *)getTiteLabelWithText:(NSString *)text
{
    UILabel *titeLabel = [[UILabel alloc] init];
    [titeLabel setText:text];
    [titeLabel setFont:WLFONT(13)];
    [titeLabel setTextAlignment:NSTextAlignmentCenter];
    [titeLabel setTextColor:WLRGB(69, 69, 69)];
    [titeLabel setBackgroundColor:WLRGB(242, 242, 242)];
    return titeLabel;
}


- (UILabel *)loadInfoLabel
{
    UILabel *titeLabel = [[UILabel alloc] init];
    [titeLabel setFont:WLFONT(14)];
    [titeLabel setNumberOfLines:0];
    [titeLabel setTextAlignment:NSTextAlignmentLeft];
    [titeLabel setTextColor:WLRGB(69, 69, 69)];
    return titeLabel;
}

- (UIView *)loadLineView
{
    UIView *lineView = [[UIView alloc] init];
    [lineView setBounds:CGRectMake(0, 0, SuperSize.width-60, 0.5)];
    [lineView setBackgroundColor:WLRGB(204, 204, 204)];
    return lineView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
