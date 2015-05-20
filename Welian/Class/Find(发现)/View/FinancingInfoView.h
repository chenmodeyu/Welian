//
//  FinancingInfoView.h
//  Welian
//
//  Created by weLian on 15/5/20.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinancingInfoView : UIView

@property (strong,nonatomic) IProjectDetailInfo *iProjectDetailInfo;

//返回高度
+ (CGFloat)configureWithIProjectInfo:(IProjectDetailInfo *)iProjectInfo;

@end
