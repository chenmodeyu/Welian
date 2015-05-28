//
//  InvestorFirmInfoController.h
//  Welian
//
//  Created by dong on 15/5/27.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirmInfoHeaderView.h"

typedef NS_ENUM(NSInteger, FirmInfoType) {
    FirmInfoTypeFirmID,                  // 投资机构uid
    FirmInfoTypeModel                 // 投资机构数据模型
};

@interface InvestorFirmInfoController : UITableViewController

- (instancetype)initWithType:(FirmInfoType)firmType andFirmData:(id)firmdata;

@end
