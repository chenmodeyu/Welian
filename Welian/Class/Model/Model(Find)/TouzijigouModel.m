//
//  TouzijigouModel.m
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "TouzijigouModel.h"
#import "IInvestStageModel.h"
#import "CasesJiGouModel.h"

@implementation TouzijigouModel

- (void)customOperation:(NSDictionary *)dict
{
    self.cases = [CasesJiGouModel objectsWithInfo:[dict objectForKey:@"cases"]];
    self.industrys = [IInvestIndustryModel objectsWithInfo:[dict objectForKey:@"industrys"]];
    self.stages = [IInvestStageModel objectsWithInfo:[dict objectForKey:@"stages"]];
    
    if (self.cases.count) {
        NSMutableArray *caseNameArrayM = [NSMutableArray array];
        for (CasesJiGouModel *caseM in self.cases) {
            [caseNameArrayM addObject:caseM.title];
        }
        self.casesStr = [caseNameArrayM componentsJoinedByString:@"、"];
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
