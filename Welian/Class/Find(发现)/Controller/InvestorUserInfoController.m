//
//  InvestorUserInfoController.m
//  Welian
//
//  Created by dong on 15/5/25.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "InvestorUserInfoController.h"
#import "InvestorInfoHeadView.h"
#import "ProjectsMailingView.h"

@interface InvestorUserInfoController ()

@end

@implementation InvestorUserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    InvestorInfoHeadView *invesHeadView = [[InvestorInfoHeadView alloc] initWithFrame:CGRectMake(0, 0, SuperSize.width, 280)];
    [invesHeadView.mailingBut addTarget:self action:@selector(mailingInvestorClick) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView setTableHeaderView:invesHeadView];
    [self.tableView setTableFooterView:[UIView new]];
}



// 投递
- (void)mailingInvestorClick
{
    ProjectsMailingView *projectsMailingView = [[ProjectsMailingView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view.window addSubview:projectsMailingView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
