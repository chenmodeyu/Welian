//
//  InvestorCell.m
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "InvestorCell.h"

@implementation InvestorCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setInvestUserM:(InvestorUserModel *)investUserM
{
    _investUserM = investUserM;
    IBaseUserM *user = investUserM.user;
    
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageLowPriority];
    CGSize citySize = CGSizeZero;
    if (investUserM.cityName.length) {
        citySize =[investUserM.cityName sizeWithCustomFont:WLFONT(14)];
        [self.cityBut setTitle:investUserM.cityName forState:UIControlStateNormal];
    }
    [self.cityBut setFrame:CGRectMake(SuperSize.width-citySize.width-10, 10, citySize.width, 20)];
    
    NSInteger friend = user.friendship.integerValue;
    CGSize friendSize = CGSizeZero;
    if (friend==1) {
        friendSize = [@"好友" sizeWithCustomFont:WLFONT(14)];
        [self.friendBut setTitle:@"好友" forState:UIControlStateNormal];
    }else if (friend ==2){
        friendSize = [@"好友的好友" sizeWithCustomFont:WLFONT(14)];
        [self.friendBut setTitle:@"好友的好友" forState:UIControlStateNormal];
    }
    [self.friendBut setFrame:CGRectMake(SuperSize.width-citySize.width-10-friendSize.width, 20, friendSize.width, 20)];

    [self.nameLabel setText:user.name];
    [self.nameLabel setFrame:CGRectMake(68, 10, SuperSize.width-68-friendSize.width-citySize.width-10, 20)];
    [self setNeedsDisplay];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
