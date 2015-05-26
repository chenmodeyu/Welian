//
//  InvestorInfoHeadView.h
//  Welian
//
//  Created by dong on 15/5/24.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InvestorUserModel;
//typedef NS_ENUM

typedef NS_ENUM(NSInteger, InvestorMailingType) {
    InvestorMailingClick = 0,
    InvestorMailingAgree,
    InvestorMailingReject
};


typedef void(^InvestorMailingBlock)(InvestorMailingType mailingType);

@interface InvestorInfoHeadView : UIView

@property (nonatomic, strong) UILabel *friendTypeLabel;
@property (nonatomic, strong) UIImageView *iconImage;
@property (nonatomic, strong) UIImageView *vCimage;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *cityBut;
@property (nonatomic, strong) UILabel *positionLabel;
// 收获所有项目
@property (nonatomic, strong) UIView *receivedView;
//反馈的
@property (nonatomic, strong) UIView *feedbackView;
// 约谈
@property (nonatomic, strong) UIView *interviewView;

// 投递按钮
@property (nonatomic, strong) UIButton *mailingBut;

@property (nonatomic, strong) UIView *agreeView;
// 拒绝投递
@property (nonatomic, strong) UIButton *rejectBut;
// 同意投递
@property (nonatomic, strong) UIButton *agreeBut;

@property (nonatomic, weak) InvestorMailingBlock mailingBlock;

@property (nonatomic, strong) InvestorUserModel *investorUserModel;

@end
