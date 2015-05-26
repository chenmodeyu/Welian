//
//  InvestorUserModel.h
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IFBase.h"
#import "IBaseUserM.h"
#import "TouzijigouModel.h"

@interface InvestorUserModel : IFBase

@property (nonatomic, strong) IBaseUserM *user;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSNumber *received;  // 收到的
@property (nonatomic, strong) NSNumber *feedback;   //反馈的
@property (nonatomic, strong) NSNumber *interview;  // 约谈

@property (nonatomic, strong) TouzijigouModel *firm;

@property (nonatomic, strong) NSArray *stages;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *industrys;

@property (nonatomic, strong) NSString *stagesStr;
@property (nonatomic, strong) NSString *itemsStr;
@property (nonatomic, strong) NSString *industrysStr;

@end
