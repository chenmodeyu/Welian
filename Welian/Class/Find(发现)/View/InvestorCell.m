//
//  InvestorCell.m
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "InvestorCell.h"

@interface InvestorCell()
{
    UIView *_backgView;
    UIImageView *_iconImage;
    UIImageView *_vCimage;
    
    UILabel *_nameLabel;
    UILabel *_jobLabel;
    UILabel *_stageLabel;
    UILabel *_itmesLabel;
    
    UIButton *_friendBut;
    UIButton *_cityBut;
    
}
@end

@implementation InvestorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [UIView new];
        CGFloat selfHeigh = 115;
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        CGFloat iconX = 15;
        CGFloat iconW = 40;
        CGFloat labelH = 20;
        CGFloat labelX = iconW+2*iconX;
        CGFloat labelW = SuperSize.width-labelX-iconX;
        _backgView = [[UIView alloc] initWithFrame:CGRectMake(0, iconX, SuperSize.width, 115)];
        [_backgView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_backgView];
    
        _iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconX, iconW, iconW)];
        [_iconImage setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        _iconImage.layer.masksToBounds = YES;
        _iconImage.layer.cornerRadius = iconW/2;
        [_backgView addSubview:_iconImage];
        _vCimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_mycard_tou_big.png"]];
        _vCimage.right = _iconImage.right;
        _vCimage.bottom = _iconImage.bottom;
        [_backgView addSubview:_vCimage];
        
        
        _itmesLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, selfHeigh-10-labelH, labelW, labelH)];
        [_itmesLabel setTextColor:WLRGB(125, 125, 125)];
        [_itmesLabel setFont:WLFONT(14)];
        [_backgView addSubview:_itmesLabel];
        
        _stageLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, _itmesLabel.top-labelH, labelW, labelH)];
        [_stageLabel setTextColor:WLRGB(125, 125, 125)];
        [_stageLabel setFont:WLFONT(14)];
        [_backgView addSubview:_stageLabel];
        
        _jobLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, _stageLabel.top-10-labelH, labelW, labelH)];
        [_jobLabel setTextColor:WLRGB(125, 125, 125)];
        [_jobLabel setFont:WLFONT(14)];
        [_backgView addSubview:_jobLabel];
        
        UIView *lienView = [[UIView alloc] initWithFrame:CGRectMake(labelX, _jobLabel.bottom+5, SuperSize.width-labelX, 0.5)];
        [lienView setBackgroundColor:WLRGB(225, 225, 225)];
        [_backgView addSubview:lienView];
        
        
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:WLFONT(16)];
        [_nameLabel setTextColor:WLRGB(51, 51, 51)];
        [_backgView addSubview:_nameLabel];
        
        
        _friendBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_friendBut setEnabled:NO];
        [_friendBut setTitleColor:WLRGB(173, 173, 173) forState:UIControlStateDisabled];
        [_friendBut setImage:[UIImage imageNamed:@"touziren_list_friend.png"] forState:UIControlStateDisabled];
        [_friendBut.titleLabel setFont:WLFONT(12)];
        [_backgView addSubview:_friendBut];
        
        _cityBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cityBut setEnabled:NO];
        [_cityBut setImage:[UIImage imageNamed:@"discovery_activity_list_place.png"] forState:UIControlStateDisabled];
        [_cityBut setTitleColor:WLRGB(173, 173, 173) forState:UIControlStateDisabled];
        [_cityBut.titleLabel setFont:WLFONT(12)];
        [_backgView addSubview:_cityBut];

    }
    return self;
}

- (void)setInvestUserM:(InvestorUserModel *)investUserM
{
    _investUserM = investUserM;
    IBaseUserM *user = investUserM.user;
    
    [_iconImage sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageLowPriority];
    
    UIEdgeInsets edgeImage = UIEdgeInsetsMake(0, 0, 0, 5);
    [_cityBut setTitle:investUserM.cityname forState:UIControlStateNormal];
    CGSize citySize =[investUserM.cityname sizeWithCustomFont:WLFONT(12)];
    if (citySize.width) {
        citySize.width += 20;
        [_cityBut setImageEdgeInsets:edgeImage];
    }else{
        [_cityBut setImageEdgeInsets:UIEdgeInsetsZero];
    }
    [_cityBut setFrame:CGRectMake(SuperSize.width-citySize.width-15, 15, citySize.width, 15)];
    
    NSInteger friend = user.friendship.integerValue;
    CGSize friendSize = CGSizeZero;
    if (friend==1) {
        friendSize = [@"好友" sizeWithCustomFont:WLFONT(12)];
        [_friendBut setTitle:@"好友" forState:UIControlStateNormal];
    }else if (friend ==2){
        friendSize = [@"好友的好友" sizeWithCustomFont:WLFONT(12)];
        [_friendBut setTitle:@"好友的好友" forState:UIControlStateNormal];
    }else{
        [_friendBut setTitle:@"" forState:UIControlStateNormal];
    }
    if (friendSize.width) {
        friendSize.width += 20;
        [_friendBut setImageEdgeInsets:edgeImage];
    }else{
        [_friendBut setImageEdgeInsets:UIEdgeInsetsZero];
    }
    
    [_friendBut setFrame:CGRectMake(SuperSize.width-citySize.width-15-friendSize.width, 15, friendSize.width, 15)];
    
    [_nameLabel setText:user.name];
    [_nameLabel setFrame:CGRectMake(70, 15, SuperSize.width-70-friendSize.width-citySize.width-15, 20)];
    
    [_jobLabel setText:[NSString stringWithFormat:@"%@  %@",user.position,user.company?:@""]];
    [_stageLabel setText:[NSString stringWithFormat:@"投资阶段：%@",investUserM.stagesStr?:@"暂无"]];
    [_itmesLabel setText:[NSString stringWithFormat:@"投资案例：%@",investUserM.itemsStr?:@"暂无"]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
