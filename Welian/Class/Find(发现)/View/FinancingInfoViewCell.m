//
//  FinancingInfoViewCell.m
//  Welian
//
//  Created by weLian on 15/5/21.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "FinancingInfoViewCell.h"
#import "FinancingInfoView.h"

@interface FinancingInfoViewCell ()

@property (assign,nonatomic) FinancingInfoView *financingInfoView;

@end

@implementation FinancingInfoViewCell

- (void)dealloc
{
    _iProjectDetailInfo = nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setIProjectDetailInfo:(IProjectDetailInfo *)iProjectDetailInfo
{
    [super willChangeValueForKey:@"iProjectDetailInfo"];
    _iProjectDetailInfo = iProjectDetailInfo;
    [super didChangeValueForKey:@"iProjectDetailInfo"];
    _financingInfoView.iProjectDetailInfo = _iProjectDetailInfo;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _financingInfoView.frame = CGRectMake(0, 0, self.width, self.height - 0.5);
}

#pragma mark - Private
- (void)setup
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //融资信息
    FinancingInfoView *financingInfoView = [[FinancingInfoView alloc] initWithFrame:CGRectZero];
    [self addSubview:financingInfoView];
    self.financingInfoView = financingInfoView;
}

@end
