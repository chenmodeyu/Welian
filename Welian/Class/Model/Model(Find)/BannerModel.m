//
//  BannerModel.m
//  Welian
//
//  Created by dong on 15/5/21.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "BannerModel.h"

@implementation BannerModel

- (void)customOperation:(NSDictionary *)dict
{
    self.classification = [IProjectClassModel objectWithDict:[dict objectForKey:@"classification"]];
}

@end
