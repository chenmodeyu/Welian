//
//  InvestorsTableController.h
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, InvestorsType) {
    InvestorsTypeUser,                  // 投资人
    InvestorsTypeOrganization,          // 投资机构
    InvestorsTypeShaiXuan               // 筛选
};

@interface InvestorsTableController : UITableViewController

- (instancetype)initWithInvestorsType:(InvestorsType)investorsType;

@end
