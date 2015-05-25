//
//  InvestorCell.h
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InvestorUserModel.h"

@interface InvestorCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *stageLabel;

@property (weak, nonatomic) IBOutlet UILabel *caseLabel;

@property (weak, nonatomic) IBOutlet UIButton *friendBut;
@property (weak, nonatomic) IBOutlet UIButton *cityBut;

@property (nonatomic, strong) InvestorUserModel *investUserM;

@end
