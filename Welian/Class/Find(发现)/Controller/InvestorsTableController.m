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
#import "TouzijigouModel.h"
#import "InvestorFirmInfoController.h"

@interface InvestorsTableController ()
{
    InvestorsType invType;
    NSMutableArray *_dataArray;
    NSInteger _page;
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
        _page = 1;
    }
    return self;
}

- (void)hideRefreshViewWithCount:(NSInteger)count
{
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    if (count>=KCellConut) {
        _page++;
    }
    self.tableView.footer.hidden = count<KCellConut;
}

// 刷新数据
- (void)httpGetInvestorlist
{
    _page = 1;
    WEAKSELF
    if (invType == InvestorsTypeUser) {
        [WeLianClient getInvestorListWithType:@(0) Page:@(_page) Size:@(KCellConut) Success:^(id resultInfo) {
            NSArray *investorUM = [InvestorUserModel objectsWithInfo:resultInfo];
            [_dataArray removeAllObjects];
            [_dataArray addObjectsFromArray:investorUM];
            [weakSelf hideRefreshViewWithCount:investorUM.count];
            [weakSelf.tableView reloadData];
        } Failed:^(NSError *error) {
            
        }];
    }else if (invType == InvestorsTypeOrganization){
        
        [WeLianClient getInvestorJigouWithPage:@(_page) Size:@(KCellConut) Success:^(id resultInfo) {
            NSArray *investorJiGou = [TouzijigouModel objectsWithInfo:resultInfo];
            [_dataArray removeAllObjects];
            [_dataArray addObjectsFromArray:investorJiGou];
            [weakSelf hideRefreshViewWithCount:investorJiGou.count];
            [weakSelf.tableView reloadData];
        } Failed:^(NSError *error) {
            
        }];
    }
}

// 加载更多数据
- (void)httpGetMoreInvestorlist
{
    WEAKSELF
    if (invType == InvestorsTypeUser) {
        [WeLianClient getInvestorListWithType:@(0) Page:@(_page) Size:@(KCellConut) Success:^(id resultInfo) {
            NSArray *investorUM = [InvestorUserModel objectsWithInfo:resultInfo];
            [_dataArray addObjectsFromArray:investorUM];
            [weakSelf hideRefreshViewWithCount:investorUM.count];
            [weakSelf.tableView reloadData];
            
        } Failed:^(NSError *error) {
            
        }];
    }else if (invType == InvestorsTypeOrganization){
        
        [WeLianClient getInvestorJigouWithPage:@(_page) Size:@(KCellConut) Success:^(id resultInfo) {
            NSArray *investorJiGou = [TouzijigouModel objectsWithInfo:resultInfo];
            [_dataArray addObjectsFromArray:investorJiGou];
            [weakSelf hideRefreshViewWithCount:investorJiGou.count];
            [weakSelf.tableView reloadData];
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
        [weakSelf httpGetMoreInvestorlist];
    }];
    [self.tableView.header beginRefreshing];
    [self.tableView.footer setHidden:YES];

    if (invType == InvestorsTypeOrganization){
        [self.tableView registerNib:[UINib nibWithNibName:@"InvestorOrgCell" bundle:nil] forCellReuseIdentifier:investorOrgCellid];
    }
    
    if (invType == InvestorsTypeShaiXuan) {
        
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

    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (invType == InvestorsTypeUser) {
      InvestorCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[InvestorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        InvestorUserModel *invesUserM = [_dataArray objectAtIndex:indexPath.row];
        [cell setInvestUserM:invesUserM];
        return cell;
    }else if (invType == InvestorsTypeOrganization){
      InvestorOrgCell *cell = [tableView dequeueReusableCellWithIdentifier:investorOrgCellid];
        TouzijigouModel *touzijigouM = [_dataArray objectAtIndex:indexPath.row];
        [cell setTouziJiGouM:touzijigouM];
      return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (invType == InvestorsTypeUser||invType == InvestorsTypeShaiXuan) {
        InvestorUserModel *invesUserM = [_dataArray objectAtIndex:indexPath.row];
        InvestorUserInfoController *invesInfo = [[InvestorUserInfoController alloc] initWithUserType:InvestorUserTypeModel andUserData:invesUserM];
        [self.navigationController pushViewController:invesInfo animated:YES];
    }else if (invType == InvestorsTypeOrganization){
        TouzijigouModel *touzijigouM = [_dataArray objectAtIndex:indexPath.row];
        InvestorFirmInfoController *firmInfoVC = [[InvestorFirmInfoController alloc] initWithType:FirmInfoTypeModel andFirmData:touzijigouM];
        [self.navigationController pushViewController:firmInfoVC animated:YES];
    }
    
}

@end
