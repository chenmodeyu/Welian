//
//  ProjectInfoViewCell.h
//  Welian
//
//  Created by weLian on 15/5/21.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface ProjectInfoViewCell : BaseTableViewCell

@property (strong,nonatomic) IProjectInfo *iProjectInfo;
@property (strong,nonatomic) ProjectInfo *projectInfo;
@property (strong,nonatomic) IProjectDetailInfo *iProjectDetailInfo;

@end
