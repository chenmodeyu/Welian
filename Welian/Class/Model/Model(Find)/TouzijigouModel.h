//
//  TouzijigouModel.h
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IFBase.h"

@interface TouzijigouModel : IFBase

@property (nonatomic, strong) NSNumber *firmid;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *logo;
@property (nonatomic, strong) NSString *intro;

@property (nonatomic, strong) NSNumber *casecount;
@property (nonatomic, strong) NSNumber *membercount;

@property (nonatomic, strong) NSArray *stages;
@property (nonatomic, strong) NSArray *cases;
@property (nonatomic, strong) NSArray *industrys;

@property (nonatomic, strong) NSString *stagesStr;
@property (nonatomic, strong) NSString *casesStr;
@property (nonatomic, strong) NSString *industrysStr;

@end
