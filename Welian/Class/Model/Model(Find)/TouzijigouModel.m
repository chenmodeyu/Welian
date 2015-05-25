//
//  TouzijigouModel.m
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "TouzijigouModel.h"
#import "IInvestStageModel.h"

@implementation TouzijigouModel

- (void)customOperation:(NSDictionary *)dict
{
    self.items = [InvestItemM objectsWithInfo:[dict objectForKey:@"items"]];
    self.industrys = [IInvestIndustryModel objectsWithInfo:[dict objectForKey:@"industrys"]];
    self.stages = [IInvestStageModel objectsWithInfo:[dict objectForKey:@"stages"]];
}

@end
