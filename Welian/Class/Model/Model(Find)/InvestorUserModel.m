//
//  InvestorUserModel.m
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "InvestorUserModel.h"
#import "InvestItemM.h"
#import "IInvestIndustryModel.h"
#import "IInvestStageModel.h"

@implementation InvestorUserModel

- (void)customOperation:(NSDictionary *)dict
{
    self.user = [IBaseUserM objectWithDict:[dict objectForKey:@"user"]];
    self.firm = [TouzijigouModel objectWithDict:[dict objectForKey:@"firm"]];
    
    self.items = [InvestItemM objectsWithInfo:[dict objectForKey:@"items"]];
    self.industrys = [IInvestIndustryModel objectsWithInfo:[dict objectForKey:@"industrys"]];
    self.stages = [IInvestStageModel objectsWithInfo:[dict objectForKey:@"stages"]];
    
    if (self.items.count) {
        NSMutableArray *itemNameArrayM = [NSMutableArray array];
        for (InvestItemM *itemM in self.items) {
            [itemNameArrayM addObject:itemM.item];
        }
        self.itemsStr = [itemNameArrayM componentsJoinedByString:@"、"];
    }
    
    if (self.industrys.count) {
        NSMutableArray *industryNameArrayM = [NSMutableArray array];
        for (IInvestIndustryModel *industryM in self.industrys) {
            [industryNameArrayM addObject:industryM.industryname];
        }
        self.industrysStr = [industryNameArrayM componentsJoinedByString:@"、"];
    }
    
    if (self.stages.count) {
        NSMutableArray *stageNameArrayM = [NSMutableArray array];
        for (IInvestStageModel *stageM in self.stages) {
            [stageNameArrayM addObject:stageM.stagename];
        }
        self.stagesStr = [stageNameArrayM componentsJoinedByString:@"、"];
    }


}

@end
