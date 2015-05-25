//
//  TouzijigouModel.h
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IFBase.h"

@interface TouzijigouModel : IFBase

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *photo;
@property (nonatomic, strong) NSString *intro;

@property (nonatomic, strong) NSArray *stages;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *industrys;

@property (nonatomic, strong) NSString *stagesStr;
@property (nonatomic, strong) NSString *itemsStr;
@property (nonatomic, strong) NSString *industrysStr;

@end
