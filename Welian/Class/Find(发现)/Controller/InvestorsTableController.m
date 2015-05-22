//
//  InvestorsTableController.m
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "InvestorsTableController.h"
#import "InvestorCell.h"
#import "InvestorOrgCell.h"

@interface InvestorsTableController ()
{
    InvestorsType invType;
}

@end

static NSString *identifier = @"InvestorCell";
static NSString *investorOrgCellid = @"InvestorOrgCell";

@implementation InvestorsTableController

- (instancetype)initWithInvestorsType:(InvestorsType)investorsType
{
    self = [super init];
    if (self) {
        invType = investorsType;
        
    }
    return self;
}

- (void)httpGetInvestorlist
{
    if (invType == InvestorsTypeUser) {
        [WeLianClient getInvestorListWithType:@(0) Page:@(1) Size:@(KCellConut) Success:^(id resultInfo) {
            
        } Failed:^(NSError *error) {
            
        }];
    }else if (invType == InvestorsTypeOrganization){
        
        [WeLianClient getInvestorJigouWithPage:@(1) Size:@(KCellConut) Success:^(id resultInfo) {
            
        } Failed:^(NSError *error) {
            
        }];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    WEAKSELF
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf httpGetInvestorlist];
    }];
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        
    }];
    if (invType == InvestorsTypeUser) {
        [self.tableView registerNib:[UINib nibWithNibName:@"InvestorCell" bundle:nil] forCellReuseIdentifier:identifier];
    }else if (invType == InvestorsTypeOrganization){
        [self.tableView registerNib:[UINib nibWithNibName:@"InvestorOrgCell" bundle:nil] forCellReuseIdentifier:investorOrgCellid];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 23;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (invType == InvestorsTypeUser) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    }else if (invType == InvestorsTypeOrganization){
        cell = [tableView dequeueReusableCellWithIdentifier:investorOrgCellid];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

@end
