//
//  ActivityOrderInfoViewController.h
//  Welian
//
//  Created by weLian on 15/2/13.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "BasicViewController.h"

@interface ActivityOrderInfoViewController : BasicViewController

- (instancetype)initWithActivityInfo:(ActivityInfo *)activityInfo Tickets:(NSArray *)tickets payInfo:(IActivityOrderResultModel *)payInfo;

@end
