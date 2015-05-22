//
//  IProjectClassModel.m
//  Welian
//
//  Created by weLian on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IProjectClassModel.h"

@implementation IProjectClassModel

- (void)customOperation:(NSDictionary *)dict
{
    self.projectCount = dict[@"count"];
}

@end
