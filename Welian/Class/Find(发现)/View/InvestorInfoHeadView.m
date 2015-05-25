//
//  InvestorInfoHeadView.m
//  Welian
//
//  Created by dong on 15/5/24.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "InvestorInfoHeadView.h"

@implementation InvestorInfoHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _friendTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 100, 20)];
        _friendTypeLabel.right = self.right-15;
        [_friendTypeLabel setText:@"好友的好友"];
        [_friendTypeLabel setFont:WLFONT(14)];
        [_friendTypeLabel setTextColor:[UIColor grayColor]];
        [_friendTypeLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_friendTypeLabel];

        _iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 70, 70)];
        [_iconImage setCenterX:self.centerX];        
        _iconImage.layer.borderWidth = 2;
        _iconImage.layer.cornerRadius = 35;
        _iconImage.layer.borderColor = [WLRGB(52, 116, 186) CGColor];
        [self addSubview:_iconImage];
        _vCimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_mycard_tou_big.png"]];
        _vCimage.right = _iconImage.right;
        _vCimage.bottom = _iconImage.bottom;
        [self addSubview:_vCimage];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _iconImage.bottom+10, 80, 20)];
        [_nameLabel setCenterX:self.centerX];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        [_nameLabel setTextColor:WLRGB(51, 51, 51)];
        [_nameLabel setText:@"陈日莎"];
        [self addSubview:_nameLabel];
        
        _positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _nameLabel.bottom+5, SuperSize.width, 16)];
        [_positionLabel setText:@"产品经理  微链"];
        [_positionLabel setFont:WLFONT(15)];
        [_positionLabel setTextColor:[UIColor grayColor]];
        [_positionLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_positionLabel];
        
        
        _receivedView = [[UIView alloc] initWithFrame:CGRectMake(30, _positionLabel.bottom+15, 60, 60)];
        [_receivedView setBackgroundColor:[UIColor redColor]];
        [self addSubview:_receivedView];
        
        _feedbackView = [[UIView alloc] initWithFrame:CGRectMake((SuperSize.width-60-3*60)*0.5+_receivedView.right, _positionLabel.bottom+15, 60, 60)];
        [_feedbackView setBackgroundColor:[UIColor redColor]];
        [self addSubview:_feedbackView];
        
        _interviewView = [[UIView alloc] initWithFrame:CGRectMake((SuperSize.width-60-3*60)*0.5+_feedbackView.right, _positionLabel.bottom+15, 60, 60)];
        [_interviewView setBackgroundColor:[UIColor redColor]];
        [self addSubview:_interviewView];
        
        _mailingBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mailingBut setFrame:CGRectMake(30, _interviewView.bottom+15, SuperSize.width-60, 40)];
        [_mailingBut setBackgroundColor:[UIColor blueColor]];
        [_mailingBut setTitle:@"投递项目" forState:UIControlStateNormal];
        [self addSubview:_mailingBut];
        
        _agreeView = [[UIView alloc] initWithFrame:CGRectMake(30, _interviewView.bottom+15, SuperSize.width-60, _mailingBut.height)];
        [_agreeView setBackgroundColor:[UIColor whiteColor]];
//        [self addSubview:_agreeView];
        
        _rejectBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rejectBut setTitle:@"拒绝发送BP" forState:UIControlStateNormal];
        [_rejectBut setFrame:CGRectMake(0, 0, (_agreeView.width-20)*0.5, _agreeView.height)];
        [_rejectBut setBackgroundColor:[UIColor redColor]];
        [_agreeView addSubview:_rejectBut];
        
        _agreeBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_agreeBut setTitle:@"同意发送BP" forState:UIControlStateNormal];
        [_agreeBut setFrame:CGRectMake(_rejectBut.right+20, 0, (_agreeView.width-20)*0.5, _agreeView.height)];
        [_agreeBut setBackgroundColor:[UIColor orangeColor]];
        [_agreeView addSubview:_agreeBut];
        
    }
    return self;
}

@end
