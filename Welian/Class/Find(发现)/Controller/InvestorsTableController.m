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
#import "NotstringView.h"

@interface InvestorsTableController ()
{
    InvestorsType invType;
    NSMutableArray *_dataArray;
    NSInteger _page;
}

@property (nonatomic, strong) UIView *headerView;

@property (strong, nonatomic) NotstringView *notView;

@end

static NSString *identifier = @"InvestorCell";
static NSString *investorOrgCellid = @"InvestorOrgCell";

@implementation InvestorsTableController

- (NotstringView *)notView
{
    if (_notView == nil) {
        _notView = [[NotstringView alloc] initWithFrame:CGRectMake(0, 0, SuperSize.width, SuperSize.height) withTitStr:@"无筛选结果" andImageName:@"xiangmu_list_funnel_big.png"];
    }
    return _notView;
}


- (UIView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SuperSize.width, 22.f)];
    }
    for (UIView *label in _headerView.subviews) {
        [label removeFromSuperview];
    }
    NSMutableArray *selectInfos = [NSMutableArray array];
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (!loginUser) {
        return _headerView;
    }
    NSDictionary *searchIndustryinfo = [UserDefaults objectForKey:[NSString stringWithFormat:kInvestorSearchIndustryKey,loginUser.uid]];
    NSDictionary *searchStage = [UserDefaults objectForKey:[NSString stringWithFormat:kInvestorSearchStageKey,loginUser.uid]];
    NSDictionary *searchCity = [UserDefaults objectForKey:[NSString stringWithFormat:kInvestorSearchCityKey,loginUser.uid]];
    if (searchIndustryinfo) {
        [selectInfos addObject:searchIndustryinfo[@"industryname"]];
    }
    if (searchStage) {
        [selectInfos addObject:searchStage[@"stagename"]];
    }
    if (searchCity) {
        [selectInfos addObject:searchCity[@"name"]];
    }
    if (selectInfos.count > 0) {
        CGFloat leftWith = 15.f;
        for (int i = 0; i < selectInfos.count; i++) {
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.backgroundColor = [UIColor whiteColor];
            titleLabel.textColor = kNormalTextColor;
            titleLabel.font = kNormal12Font;
            titleLabel.text = selectInfos[i];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.layer.cornerRadius = 3.f;
            titleLabel.layer.masksToBounds = YES;
            titleLabel.layer.borderColor = kNormalLineColor.CGColor;
            titleLabel.layer.borderWidth = 0.6f;
            [titleLabel sizeToFit];
            titleLabel.width = titleLabel.width + 10.f;
            titleLabel.height = 22.f;
            titleLabel.left = leftWith;
            titleLabel.centerY = _headerView.height-3;
            leftWith = titleLabel.right + 5.f;
            [_headerView addSubview:titleLabel];
        }
    }
    return _headerView;
}


- (void)dealloc
{
    if (invType == InvestorsTypeShaiXuan) {
        [KNSNotification removeObserver:self];
    }
}

- (instancetype)initWithInvestorsType:(InvestorsType)investorsType
{
    self = [super init];
    if (self) {
        invType = investorsType;
        _dataArray = [NSMutableArray array];
        _page = 1;

        if (investorsType == InvestorsTypeUser) {
            YTKKeyValueItem *usersItem = [[WLDataDBTool sharedService] getYTKKeyValueItemById:KInvestrUserTableName fromTable:KInvestrUserTableName];
            NSArray *investArray = [InvestorUserModel objectsWithInfo:usersItem.itemObject];
            [_dataArray removeAllObjects];
            [_dataArray addObjectsFromArray:investArray];
        }else if (investorsType == InvestorsTypeOrganization){
            YTKKeyValueItem *usersItem = [[WLDataDBTool sharedService] getYTKKeyValueItemById:KInvestrJiGouTableName fromTable:KInvestrJiGouTableName];
            NSArray *investArray = [TouzijigouModel objectsWithInfo:usersItem.itemObject];
            [_dataArray removeAllObjects];
            [_dataArray addObjectsFromArray:investArray];
        }
        
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
    if (invType == InvestorsTypeShaiXuan) {
        if (!_dataArray.count) {
            [self.tableView addSubview:self.notView];
        }else{
            [self.notView removeFromSuperview];
        }
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
            [[WLDataDBTool sharedService] putObject:resultInfo withId:KInvestrUserTableName intoTable:KInvestrUserTableName];
            NSArray *investorUM = [InvestorUserModel objectsWithInfo:resultInfo];
            [_dataArray removeAllObjects];
            [_dataArray addObjectsFromArray:investorUM];
            [weakSelf hideRefreshViewWithCount:investorUM.count];
            [weakSelf.tableView reloadData];
        } Failed:^(NSError *error) {
            
        }];
    }else if (invType == InvestorsTypeOrganization){
        [WeLianClient getInvestorJigouWithPage:@(_page) Size:@(KCellConut) Success:^(id resultInfo) {
            [[WLDataDBTool sharedService] putObject:resultInfo withId:KInvestrJiGouTableName intoTable:KInvestrJiGouTableName];
            NSArray *investorJiGou = [TouzijigouModel objectsWithInfo:resultInfo];
            [_dataArray removeAllObjects];
            [_dataArray addObjectsFromArray:investorJiGou];
            [weakSelf hideRefreshViewWithCount:investorJiGou.count];
            [weakSelf.tableView reloadData];
        } Failed:^(NSError *error) {
            
        }];
    }else if (invType == InvestorsTypeShaiXuan){
        NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
        LogInUser *loginUser = [LogInUser getCurrentLoginUser];
        if (!loginUser) {
            return;
        }
        //投资人领域搜索条件
       NSDictionary *searchIndustryinfo = [UserDefaults objectForKey:[NSString stringWithFormat:kInvestorSearchIndustryKey,loginUser.uid]];
        //投资人 投资阶段条件
        NSDictionary *searchStage = [UserDefaults objectForKey:[NSString stringWithFormat:kInvestorSearchStageKey,loginUser.uid]];
        //投资人 地区条件
        NSDictionary *searchCity = [UserDefaults objectForKey:[NSString stringWithFormat:kInvestorSearchCityKey,loginUser.uid]];
        
        
        if (searchIndustryinfo||searchStage||searchCity) {
            if (searchIndustryinfo) {
                [paramsDic setObject:[searchIndustryinfo objectForKey:@"industryid"] forKey:@"industryid"];
            }
            if (searchStage) {
                [paramsDic setObject:[searchStage objectForKey:@"stage"] forKey:@"stage"];
            }
            if (searchCity) {
                [paramsDic setObject:[searchCity objectForKey:@"cityid"] forKey:@"cityid"];
            }
            [WeLianClient investorSearchPersonWithParams:paramsDic Success:^(id resultInfo) {
                NSArray *investorUM = [InvestorUserModel objectsWithInfo:resultInfo];
                [_dataArray removeAllObjects];
                [_dataArray addObjectsFromArray:investorUM];
                [weakSelf hideRefreshViewWithCount:0];
                [weakSelf.tableView reloadData];
            } Failed:^(NSError *error) {
                
            }];
            [self.tableView setTableHeaderView:self.headerView];
        }else{
            [self hideRefreshViewWithCount:0];
            [self.tableView addSubview:self.notView];
        }
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
    if (_dataArray.count) {
        [self httpGetInvestorlist];
    }else{
        [self.tableView.header beginRefreshing];
    }
    [self.tableView.footer setHidden:YES];

    if (invType == InvestorsTypeOrganization){
        [self.tableView registerNib:[UINib nibWithNibName:@"InvestorOrgCell" bundle:nil] forCellReuseIdentifier:investorOrgCellid];
    }
    
    if (invType == InvestorsTypeShaiXuan) {
        [KNSNotification addObserver:self selector:@selector(updataUsersList) name:kSearchInvestorUserKey object:nil];
    }
}

- (void)updataUsersList
{
    [self.tableView.header beginRefreshing];
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
    if (invType == InvestorsTypeUser||invType == InvestorsTypeShaiXuan) {
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
