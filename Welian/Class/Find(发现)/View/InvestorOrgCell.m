//
//  InvestorOrgCell.m
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "InvestorOrgCell.h"
#import "TouzijigouModel.h"

@implementation InvestorOrgCell

- (void)awakeFromNib {
//    self.selectedBackgroundView = [UIView new];
}

- (void)setTouziJiGouM:(TouzijigouModel *)touziJiGouM
{
    _touziJiGouM = touziJiGouM;
    
    [self.nameLabel setText:touziJiGouM.title];
    [self.logoImage sd_setImageWithURL:[NSURL URLWithString:touziJiGouM.logo] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageLowPriority];
    [self.logoImage setBackgroundColor:[UIColor lightGrayColor]];
    [self.stageLabel setText:[NSString stringWithFormat:@"投资阶段：%@",touziJiGouM.stagesStr?:@"暂无"]];
    [self.industryLabel setText:[NSString stringWithFormat:@"投资领域：%@",touziJiGouM.industrysStr?:@"暂无"]];
    [self.userAndCaseLabel setText:[NSString stringWithFormat:@"入驻投资人 %ld 投资案例 %ld",(long)touziJiGouM.membercount.integerValue,(long)touziJiGouM.casecount.integerValue]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
