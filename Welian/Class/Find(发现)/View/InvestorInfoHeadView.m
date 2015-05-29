//
//  InvestorInfoHeadView.m
//  Welian
//
//  Created by dong on 15/5/24.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "InvestorInfoHeadView.h"
#import "InvestorUserModel.h"
#import "UIImage+ImageEffects.h"

@implementation InvestorInfoHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _friendTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 100, 20)];
        _friendTypeLabel.right = self.right-15;
        [_friendTypeLabel setFont:WLFONT(14)];
        [_friendTypeLabel setTextColor:[UIColor grayColor]];
        [_friendTypeLabel setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_friendTypeLabel];

        _iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 70, 70)];
        [_iconImage setCenterX:self.centerX];
        _iconImage.layer.borderWidth = 2;
        _iconImage.layer.masksToBounds = YES;
        _iconImage.layer.cornerRadius = 35;
        _iconImage.layer.borderColor = [WLRGBA(52, 116, 186,0.3) CGColor];
        [self addSubview:_iconImage];
        _vCimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_mycard_tou_big.png"]];
        _vCimage.right = _iconImage.right;
        _vCimage.bottom = _iconImage.bottom;
        [self addSubview:_vCimage];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _iconImage.bottom+10, 80, 20)];
        [_nameLabel setCenterX:self.centerX];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        [_nameLabel setTextColor:WLRGB(51, 51, 51)];
        [self addSubview:_nameLabel];
        
        _positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, _nameLabel.bottom+5, SuperSize.width-60, 16)];
        [_positionLabel setFont:WLFONT(15)];
        [_positionLabel setTextColor:[UIColor grayColor]];
        [_positionLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_positionLabel];
        
        _receivedView = [[DALabeledCircularProgressView alloc] initWithFrame:CGRectMake(30, _positionLabel.bottom+15, 60, 60)];
        _receivedView.thicknessRatio = 0.05;
        [_receivedView setTrackTintColor:[UIColor colorWithWhite:0.9 alpha:1]];
        [_receivedView.titleLabel setText:@"收获项目"];
        [_receivedView.titleLabel setTextColor:WLRGB(173, 173, 173)];
        _receivedView.progresColor = WLRGB(253, 204, 101);
        [_receivedView setProgressTintColor:WLRGB(253, 204, 101)];
        [self addSubview:_receivedView];
        
        _feedbackView = [[DALabeledCircularProgressView alloc] initWithFrame:CGRectMake((SuperSize.width-60-3*60)*0.5+_receivedView.right, _positionLabel.bottom+15, 60, 60)];
        [_feedbackView setTrackTintColor:[UIColor colorWithWhite:0.9 alpha:1]];
        _feedbackView.thicknessRatio = 0.05;
        [_feedbackView.titleLabel setTextColor:WLRGB(173, 173, 173)];
        [_feedbackView.titleLabel setText:@"反馈率"];
        [_feedbackView setProgresColor:WLRGB(255, 119, 119)];
        [_feedbackView setProgressTintColor:WLRGB(255, 119, 119)];
        [self addSubview:_feedbackView];
        
        _interviewView = [[DALabeledCircularProgressView alloc] initWithFrame:CGRectMake((SuperSize.width-60-3*60)*0.5+_feedbackView.right, _positionLabel.bottom+15, 60, 60)];
        [_interviewView setTrackTintColor:[UIColor colorWithWhite:0.9 alpha:1]];
        _interviewView.thicknessRatio = 0.05;
        [_interviewView.titleLabel setText:@"约谈率"];
        [_interviewView.titleLabel setTextColor:WLRGB(173, 173, 173)];
        [_interviewView setProgresColor:WLRGB(98, 201, 141)];
        [_interviewView setProgressTintColor:WLRGB(98, 201, 141)];
        [self addSubview:_interviewView];
        
        _mailingBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mailingBut setFrame:CGRectMake(30, _interviewView.bottom+15, SuperSize.width-60, 40)];
        [_mailingBut setTitle:@"投递项目" forState:UIControlStateNormal];
        [_mailingBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_mailingBut setBackgroundImage:[UIImage resizedImage:@"login_my_button"] forState:UIControlStateNormal];
        [_mailingBut setBackgroundImage:[UIImage resizedImage:@"login_my_button_pre"] forState:UIControlStateHighlighted];
        [_mailingBut setImage:[UIImage imageNamed:@"touziren_detail_toudi_button.png"] forState:UIControlStateNormal];
        [_mailingBut setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
        [self addSubview:_mailingBut];
        
        _agreeView = [[UIView alloc] initWithFrame:CGRectMake(30, _interviewView.bottom+15, SuperSize.width-60, _mailingBut.height)];
        [_agreeView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_agreeView];
        
        _rejectBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rejectBut setTitle:@"拒绝发送BP" forState:UIControlStateNormal];
        [_rejectBut setFrame:CGRectMake(0, 0, (_agreeView.width-20)*0.5, _agreeView.height)];
        [_rejectBut setTitleColor:WLRGB(52, 116, 186) forState:UIControlStateNormal];
        [_rejectBut setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        _rejectBut.layer.borderWidth = 0.6;
        _rejectBut.layer.masksToBounds = YES;
        _rejectBut.layer.cornerRadius = 5;
        _rejectBut.layer.borderColor = [WLRGB(52, 116, 186) CGColor];
        [_agreeView addSubview:_rejectBut];
        
        
        _agreeBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [_agreeBut setTitle:@"同意发送BP" forState:UIControlStateNormal];
        [_agreeBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_agreeBut setFrame:CGRectMake(_rejectBut.right+20, 0, (_agreeView.width-20)*0.5, _agreeView.height)];
        [_agreeBut setBackgroundImage:[UIImage resizedImage:@"login_my_button"] forState:UIControlStateNormal];
        [_agreeBut setBackgroundImage:[UIImage resizedImage:@"login_my_button_pre"] forState:UIControlStateHighlighted];
        [_agreeView addSubview:_agreeBut];
    }
    return self;
}

- (void)setInvestorUserModel:(InvestorUserModel *)investorUserModel
{
    _investorUserModel = investorUserModel;
    /**  好友关系，1好友，2好友的好友,-1自己，0没关系   */
    IBaseUserM *userM = investorUserModel.user;
    if (userM.friendship.integerValue==1) {
        [_friendTypeLabel setText:@"好友"];
    }else if (userM.friendship.integerValue ==2){
        [_friendTypeLabel setText:@"好友的好友"];
    }else{
        [_friendTypeLabel setText:@""];
    }
    
    [_iconImage sd_setImageWithURL:[NSURL URLWithString:userM.avatar] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageLowPriority];
    
    [_nameLabel setText:userM.name];
    [_positionLabel setText:[NSString stringWithFormat:@"%@  %@",userM.position,userM.company]];
    
    [_receivedView setProgress:investorUserModel.received.floatValue animated:YES];
    [_receivedView.progressLabel setText:[NSString stringWithFormat:@"%ld",(long)investorUserModel.received.integerValue]];

    [_feedbackView setProgress:investorUserModel.received.floatValue?investorUserModel.feedback.floatValue/investorUserModel.received.floatValue:0.0 animated:YES];
    [_feedbackView.progressLabel setText:[NSString stringWithFormat:@"%ld%@",investorUserModel.feedback.integerValue*100/investorUserModel.received.integerValue,@"%"]];
    
    [_interviewView setProgress:investorUserModel.received.floatValue?investorUserModel.interview.floatValue/investorUserModel.received.floatValue:0.0 animated:YES];
    [_interviewView.progressLabel setText:[NSString stringWithFormat:@"%ld%@",investorUserModel.interview.integerValue*100/investorUserModel.received.integerValue,@"%"]];
}

- (void)setUserType:(InvestorUserInfoType)userType
{
    _userType = userType;
    if (userType == InvestorUserTypeUID) {
        [_agreeView setHidden:NO];
        [_mailingBut setHidden:YES];
    }else if (userType ==InvestorUserTypeModel){
        [_agreeView setHidden:YES];
        [_mailingBut setHidden:NO];
    }
}

@end
