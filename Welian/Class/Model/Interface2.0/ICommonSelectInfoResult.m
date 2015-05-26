//
//  ICommonSelectInfoResult.m
//  Welian
//
//  Created by weLian on 15/5/26.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ICommonSelectInfoResult.h"

@implementation ICommonSelectInfoResult

- (void)customOperation:(NSDictionary *)dict
{
    self.projectcity = [ICityModel objectsWithInfo:self.projectcity];
    self.industry = [IInvestIndustryModel objectsWithInfo:self.industry];
    self.activecity = [ICityModel objectsWithInfo:self.activecity];
}

@end
