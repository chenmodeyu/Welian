//
//  InvestorUserModel.m
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "InvestorUserModel.h"
#import "InvestItemM.h"
#import "IInvestIndustryModel.h"
#import "IInvestStageModel.h"

@implementation InvestorUserModel

- (void)customOperation:(NSDictionary *)dict
{
    self.user = [IBaseUserM objectWithDict:[dict objectForKey:@"user"]];
    self.touzijigou = [TouzijigouModel objectWithDict:[dict objectForKey:@"touzijigou"]];
    
    self.items = [InvestItemM objectsWithInfo:[dict objectForKey:@"items"]];
    self.industrys = [IInvestIndustryModel objectsWithInfo:[dict objectForKey:@"industrys"]];
    self.stages = [IInvestStageModel objectsWithInfo:[dict objectForKey:@"stages"]];

}

@end
