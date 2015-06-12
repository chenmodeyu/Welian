//
//  IAskInfoMdoel.h
//  Welian
//
//  Created by weLian on 15/6/10.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IFBase.h"

@interface IAskInfoMdoel : IFBase

@property (nonatomic,strong) NSNumber *confid;//id 排序
@property (nonatomic,strong) NSString *title;//问题标题
@property (nonatomic,strong) NSString *field;//返回的参数名

@end
