//
//  BannerModel.h
//  Welian
//
//  Created by dong on 15/5/21.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IFBase.h"
#import "IProjectClassModel.h"

@interface BannerModel : IFBase

@property (nonatomic, strong) NSNumber *bid;
// 广告类型：0 网页，1 项目，2 活动，3 项目集合
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSString *photo;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) IProjectClassModel *classification;

@end
