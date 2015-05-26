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
        _industryTiteLabel = [self getTiteLabelWithText:@"投资领域："];
        [_backgView addSubview:_industryTiteLabel];
        _stageTiteLabel = [self getTiteLabelWithText:@"投资阶段："];
        [_backgView addSubview:_stageTiteLabel];
        _itemTiteLabel = [self getTiteLabelWithText:@"投资案例："];
        [_backgView addSubview:_itemTiteLabel];
        _firmTiteLabel = [self getTiteLabelWithText:@"投资机构："];
        [_backgView addSubview:_firmTiteLabel];
        
        _industryLabel = [self loadInfoLabel];
        [_backgView addSubview:_industryLabel];
        _stageLabel = [self loadInfoLabel];
        [_backgView addSubview:_stageLabel];
        _itemLabel = [self loadInfoLabel];
        [_backgView addSubview:_itemLabel];
        
        _firmIconImage = [[UIImageView alloc] init];
        [_backgView addSubview:_firmIconImage];
        _firmNameLabel = [[UILabel alloc] init];
        [_firmNameLabel setTextColor:WLRGB(51, 51, 51)];
        [_backgView addSubview:_firmNameLabel];
        _firmIntroLabel = [[UILabel alloc] init];
        [_firmIntroLabel setTextColor:WLRGB(178, 178, 178)];
        [_backgView addSubview:_firmIntroLabel];
        
        _line1 = [self loadLineView];
        [_backgView addSubview:_line1];
        _line2 = [self loadLineView];
        [_backgView addSubview:_line2];
        _line3 = [self loadLineView];
        [_backgView addSubview:_line3];
        
        _firmBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backgView addSubview:_firmBut];
    }
    return self;
}

- (void)setInvestorUserM:(InvestorUserModel *)investorUserM
{
    _investorUserM = investorUserM;
    [_industryLabel setText:investorUserM.industrysStr];
    [_stageLabel setText:investorUserM.stagesStr];
    [_itemLabel setText:investorUserM.itemsStr];
    [_firmNameLabel setText:investorUserM.firm.name];
    [_firmIconImage sd_setImageWithURL:[NSURL URLWithString:investorUserM.firm.logo] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageLowPriority];
    [_firmIntroLabel setText:investorUserM.firm.intro];
    
    CGFloat titeLabelW = 88;
    CGFloat labelY = 15;
    CGSize labelSize = CGSizeMake(SuperSize.width-60-titeLabelW-2*10, MAXFLOAT);
    CGFloat labelX = titeLabelW+10;
    
   CGSize indusSize = [investorUserM.industrysStr sizeWithCustomFont:WLFONT(16) constrainedToSize:labelSize];
    CGSize stageSize = [investorUserM.stagesStr sizeWithCustomFont:WLFONT(16) constrainedToSize:labelSize];
    CGSize itemSize = [investorUserM.itemsStr sizeWithCustomFont:WLFONT(16) constrainedToSize:labelSize];
    
    [_industryLabel setFrame:CGRectMake(labelX, labelY, indusSize.width, indusSize.height)];
    [_industryTiteLabel setFrame:CGRectMake(0, 0, titeLabelW, indusSize.height+2*labelY)];
    [_line1 setLeft:0];
    [_line1 setTop:_industryTiteLabel.bottom];
    
    [_stageLabel setFrame:CGRectMake(labelX, _industryTiteLabel.bottom+labelY, stageSize.width, stageSize.height)];
    [_stageTiteLabel setFrame:CGRectMake(0, _industryTiteLabel.bottom, titeLabelW, stageSize.height+2*labelY)];
    [_line2 setLeft:0];
    [_line2 setTop:_stageTiteLabel.bottom];
    
    [_itemLabel setFrame:CGRectMake(labelX, _stageTiteLabel.bottom+labelY, itemSize.width, itemSize.height)];
    [_itemTiteLabel setFrame:CGRectMake(0, _stageTiteLabel.bottom, titeLabelW, _itemLabel.height+2*labelY)];
    
    [_line3 setLeft:0];
    [_line3 setTop:_itemTiteLabel.bottom];
    
    [_firmTiteLabel setFrame:CGRectMake(0, _itemTiteLabel.bottom, titeLabelW, 70)];
    [_firmIconImage setFrame:CGRectMake(labelX, _itemTiteLabel.bottom+labelY, 40, 40)];
    [_firmNameLabel setFrame:CGRectMake(_firmIconImage.right+labelY, _firmIconImage.top, labelSize.width-50, 20)];
    [_firmIntroLabel setFrame:CGRectMake(_firmNameLabel.left, _firmNameLabel.bottom+5, _firmNameLabel.width, 20)];
    
    [_firmBut setFrame:CGRectMake(0, _itemTiteLabel.bottom, SuperSize.width-30*2, 70)];
    [_backgView setFrame:CGRectMake(30, 10, SuperSize.width-30*2, _firmTiteLabel.bottom)];
    _backgView.layer.borderWidth = 0.5;
    _backgView.layer.masksToBounds = YES;
    _backgView.layer.cornerRadius = 8;
    _backgView.layer.borderColor = [WLRGB(204, 204, 204) CGColor];
    
    self.height = _backgView.height;
}

+ (CGFloat)getCellHeightWith:(InvestorUserModel *)investorUserM
{
    CGFloat titeLabelW = 88;
    CGFloat labelY = 15;
    CGSize labelSize = CGSizeMake(SuperSize.width-60-titeLabelW-2*10, MAXFLOAT);
    CGSize indusSize = [investorUserM.industrysStr sizeWithCustomFont:WLFONT(16) constrainedToSize:labelSize];
    CGSize stageSize = [investorUserM.stagesStr sizeWithCustomFont:WLFONT(16) constrainedToSize:labelSize];
    CGSize itemSize = [investorUserM.itemsStr sizeWithCustomFont:WLFONT(16) constrainedToSize:labelSize];
    
    return indusSize.height+stageSize.height+itemSize.height+8*labelY+70;
}


- (UILabel *)getTiteLabelWithText:(NSString *)text
{
    UILabel *titeLabel = [[UILabel alloc] init];
    [titeLabel setText:text];
    [titeLabel setFont:WLFONT(14)];
    [titeLabel setTextAlignment:NSTextAlignmentCenter];
    [titeLabel setTextColor:WLRGB(69, 69, 69)];
    [titeLabel setBackgroundColor:WLRGB(242, 242, 242)];
    return titeLabel;
}


- (UILabel *)loadInfoLabel
{
    UILabel *titeLabel = [[UILabel alloc] init];
    [titeLabel setFont:WLFONT(16)];
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
