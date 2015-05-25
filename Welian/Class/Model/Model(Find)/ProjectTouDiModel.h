//
//  ProjectTouDiModel.h
//  Welian
//
//  Created by dong on 15/5/25.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IFBase.h"

@interface ProjectTouDiModel : IFBase
//  0,可以投递，1没bp，2 已投递
@property (nonatomic, strong) NSNumber *state;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSNumber *pid;

@end
