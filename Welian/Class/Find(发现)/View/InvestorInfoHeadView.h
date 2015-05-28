//
//  InvestorInfoHeadView.h
//  Welian
//
//  Created by dong on 15/5/24.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DALabeledCircularProgressView.h"

@class InvestorUserModel;

typedef NS_ENUM(NSInteger, InvestorMailingType) {
    InvestorMailingClick = 0,
    InvestorMailingAgree,
    InvestorMailingReject
};

typedef NS_ENUM(NSInteger, InvestorUserInfoType) {
    InvestorUserTypeUID,                  // 投资人uid
    InvestorUserTypeModel                 // 投资人数据模型
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
@property (nonatomic, strong) DALabeledCircularProgressView *receivedView;
//反馈的
@property (nonatomic, strong) DALabeledCircularProgressView *feedbackView;
// 约谈
@property (nonatomic, strong) DALabeledCircularProgressView *interviewView;

// 投递按钮
@property (nonatomic, strong) UIButton *mailingBut;

@property (nonatomic, strong) UIView *agreeView;
// 拒绝投递
@property (nonatomic, strong) UIButton *rejectBut;
// 同意投递
@property (nonatomic, strong) UIButton *agreeBut;

@property (nonatomic, weak) InvestorMailingBlock mailingBlock;

@property (nonatomic, strong) InvestorUserModel *investorUserModel;

@property (nonatomic, assign) InvestorUserInfoType userType;

@end
