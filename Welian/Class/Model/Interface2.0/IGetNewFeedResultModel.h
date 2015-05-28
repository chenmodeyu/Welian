//
//  IGetNewFeedResultModel.h
//  Welian
//
//  Created by weLian on 15/5/28.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IFBase.h"

@interface IGetNewFeedResultModel : IFBase

@property (strong,nonatomic) NSString *time;
@property (strong,nonatomic) NSNumber *feedcount;
@property (strong,nonatomic) NSNumber *investorcount;
@property (strong,nonatomic) NSNumber *investornewcount;
@property (strong,nonatomic) NSNumber *activecount;
@property (strong,nonatomic) NSNumber *activenewcount;
@property (strong,nonatomic) NSNumber *projectcount;
@property (strong,nonatomic) NSNumber *projectnewcount;
@property (strong,nonatomic) NSNumber *toutiaocount;
@property (strong,nonatomic) NSNumber *toutiaonewcount;

@end
