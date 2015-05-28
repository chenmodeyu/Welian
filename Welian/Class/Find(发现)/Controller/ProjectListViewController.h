//
//  ProjectListViewController.h
//  Welian
//
//  Created by weLian on 15/2/2.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "BasicPlainTableViewController.h"

@interface ProjectListViewController : BasicPlainTableViewController

//1：最新   2：热门  3：项目集 4：筛选
- (instancetype)initWithProjectType:(NSInteger)projectType;

@end
