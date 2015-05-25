//
//  IInvestIndustryModel.h
//  Welian
//
//  Created by dong on 14/12/29.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "IFBase.h"
// 投资领域

@interface IInvestIndustryModel : IFBase
@property (nonatomic, retain) NSString * industryname;
@property (nonatomic, retain) NSNumber * industryid;

@property (nonatomic, assign) BOOL isSelect;
@end
