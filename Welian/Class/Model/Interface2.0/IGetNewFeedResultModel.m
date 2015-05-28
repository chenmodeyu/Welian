//
//  IGetNewFeedResultModel.m
//  Welian
//
//  Created by weLian on 15/5/28.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IGetNewFeedResultModel.h"

@implementation IGetNewFeedResultModel

- (void)customOperation:(NSDictionary *)dict
{
    self.feedcount = dict[@"count"];
}

@end
