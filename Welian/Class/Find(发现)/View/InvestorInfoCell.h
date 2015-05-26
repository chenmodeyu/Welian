//
//  InvestorInfoCell.h
//  Welian
//
//  Created by dong on 15/5/26.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InvestorUserModel;

@interface InvestorInfoCell : UITableViewCell
@property (nonatomic, strong) UIButton *firmBut;
@property (nonatomic, strong) InvestorUserModel *investorUserM;

+ (CGFloat)getCellHeightWith:(InvestorUserModel *)investorUserM;
@end
