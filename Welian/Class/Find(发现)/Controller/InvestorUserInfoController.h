//
//  InvestorUserInfoController.h
//  Welian
//
//  Created by dong on 15/5/25.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "BasicPlainTableViewController.h"
#import "InvestorUserModel.h"
#import "InvestorInfoHeadView.h"

@interface InvestorUserInfoController : BasicPlainTableViewController

- (instancetype)initWithUserType:(InvestorUserInfoType)userType andUserData:(id)userData;


@end
