//
//  ActivityOrderInfoViewController.h
//  Welian
//
//  Created by weLian on 15/2/13.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "BasicViewController.h"

@interface ActivityOrderInfoViewController : BasicViewController

- (instancetype)initWithIActivityInfo:(IActivityInfo *)iActivityInfo Tickets:(NSArray *)tickets OrderTickets:(NSArray *)orderTickets payInfo:(IActivityOrderResultModel *)payInfo;

@end
