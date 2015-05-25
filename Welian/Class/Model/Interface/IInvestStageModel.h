//
//  IInvestStageModel.h
//  Welian
//
//  Created by dong on 14/12/29.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "IFBase.h"
// 投资阶段

@interface IInvestStageModel : IFBase
@property (nonatomic, retain) NSNumber * stage;
@property (nonatomic, retain) NSString * stagename;
@property (nonatomic, assign) BOOL isSelect;
@end
