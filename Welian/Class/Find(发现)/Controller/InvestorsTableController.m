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
#import "InvestorUserModel.h"
#import "InvestorUserInfoController.h"

@interface InvestorsTableController ()
{
    InvestorsType invType;
    NSMutableArray *_dataArray;
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
        _dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)httpGetInvestorlist
{
    if (invType == InvestorsTypeUser) {
        [WeLianClient getInvestorListWithType:@(0) Page:@(1) Size:@(KCellConut) Success:^(id resultInfo) {
            NSArray *investorUM = [InvestorUserModel objectsWithInfo:resultInfo];
            [_dataArray removeAllObjects];
            [_dataArray addObjectsFromArray:investorUM];
            [self.tableView reloadData];
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
    [self.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    WEAKSELF
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf httpGetInvestorlist];
    }];
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        
    }];
    [self.tableView.header beginRefreshing];
    if (invType == InvestorsTypeUser) {
        [self.tableView registerNib:[UINib nibWithNibName:@"InvestorCell" bundle:nil] forCellReuseIdentifier:identifier];
    }else if (invType == InvestorsTypeOrganization){
        [self.tableView registerNib:[UINib nibWithNibName:@"InvestorOrgCell" bundle:nil] forCellReuseIdentifier:investorOrgCellid];
    }
//    [self.tableView.header beginRefreshing];
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

    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (invType == InvestorsTypeUser) {
      InvestorCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        InvestorUserModel *invesUserM = [_dataArray objectAtIndex:indexPath.row];
        [cell setInvestUserM:invesUserM];
        return cell;
    }else if (invType == InvestorsTypeOrganization){
      InvestorOrgCell *cell = [tableView dequeueReusableCellWithIdentifier:investorOrgCellid];
      return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (invType == InvestorsTypeUser) {
        InvestorUserModel *invesUserM = [_dataArray objectAtIndex:indexPath.row];
        InvestorUserInfoController *invesInfo = [[InvestorUserInfoController alloc] initWithUserModel:invesUserM];
        [self.navigationController pushViewController:invesInfo animated:YES];
    }else if (invType == InvestorsTypeOrganization){
    
    }
    
}

@end
