//
//  InvestorFirmInfoController.m
//  Welian
//
//  Created by dong on 15/5/27.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "InvestorFirmInfoController.h"
#import "InvestorCell.h"
#import "WLCustomSegmentedControl.h"
#import "InvestorUserModel.h"
#import "CasesModel.h"
#import "FirmCasesCell.h"

#define SegmentedH 50.0f

@interface InvestorFirmInfoController ()
{
    TouzijigouModel *_touziJiGouM;
    NSNumber *_firmID;
    NSInteger _userPage;
    NSInteger _casePage;
}

@property (nonatomic, strong) NSMutableArray *usersArray;
@property (nonatomic, strong) NSMutableArray *casesArray;

@property (nonatomic, strong) WLCustomSegmentedControl *wlSegmentedControl;

@end

static NSString *usercellid = @"investorcellid";
static NSString *casecellid = @"casecellid";

@implementation InvestorFirmInfoController


- (WLCustomSegmentedControl *)wlSegmentedControl
{
    if (!_wlSegmentedControl) {
        _wlSegmentedControl = [[WLCustomSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, SuperSize.width, SegmentedH)];
        _wlSegmentedControl.selectedTextColor = kTitleNormalTextColor;
        _wlSegmentedControl.textColor = kNormalGrayTextColor;
        _wlSegmentedControl.font = WLFONT(16);
        _wlSegmentedControl.detailTextColor = KBlueTextColor;
        _wlSegmentedControl.selectionIndicatorHeight = 4;//设置底部滑块的高度
        _wlSegmentedControl.selectionIndicatorColor = KBlueTextColor;
        _wlSegmentedControl.showLine = NO;//显示分割线
        _wlSegmentedControl.showBottomLine = YES;
        _wlSegmentedControl.isAllowTouchEveryTime = NO;//允许重复点击
        _wlSegmentedControl.detailLabelFont = kNormalBlod16Font;
        _wlSegmentedControl.font = kNormal14Font;
        //设置边线
        _wlSegmentedControl.layer.borderColorFromUIColor = WLLineColor;
        _wlSegmentedControl.layer.borderWidths = @"{0,0,0.8,0}";
        _wlSegmentedControl.layer.masksToBounds = YES;
    }
    return _wlSegmentedControl;
}

- (instancetype)initWithType:(FirmInfoType)firmType andFirmData:(id)firmdata
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _userPage = 1;
        _casePage = 1;
        self.usersArray = [NSMutableArray array];
        self.casesArray = [NSMutableArray array];
        [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(getNewInvestorListData)];
        
        if (firmType == FirmInfoTypeFirmID) {
            _firmID = firmdata;
        }else if (firmType == FirmInfoTypeModel){
            _touziJiGouM = firmdata;
            _firmID = _touziJiGouM.firmid;
            [self loadTableViewHeaderV];
        }
        [self.tableView.header beginRefreshing];
    }
    return self;
}

- (void)hideRefreshViewWithCount:(NSInteger)count
{
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    if (count>=KCellConut) {
        if (self.wlSegmentedControl.selectedSegmentIndex==0) {
            _userPage++;
        }else{
            _casePage++;
        }
    }
    self.tableView.footer.hidden = count<KCellConut;
}
// 取投资机构信息
- (void)getOneInvestorJigouData
{
    [WeLianClient getOneInvestorJigouWithFirmid:_firmID Success:^(id resultInfo) {
        _touziJiGouM = [TouzijigouModel objectWithDict:resultInfo];
        [self loadTableViewHeaderV];
        [self.tableView reloadData];
    } Failed:^(NSError *error) {
        
    }];
}


// 取最新投资人列表
- (void)getNewInvestorJigouPersonList
{
    [WeLianClient getInvestorJigouPersonWithJigouid:_firmID Page:@(_userPage) Size:@(KCellConut) Success:^(id resultInfo) {
        [_usersArray removeAllObjects];
        _usersArray = [NSMutableArray arrayWithArray:[InvestorUserModel objectsWithInfo:resultInfo]];
        [self hideRefreshViewWithCount:_usersArray.count];
        [self.tableView reloadData];
    } Failed:^(NSError *error) {
        
    }];
}
// 取更多投资人列表
- (void)getMoreInvestorJigouPersonList
{
    [WeLianClient getInvestorJigouPersonWithJigouid:_firmID Page:@(_userPage) Size:@(KCellConut) Success:^(id resultInfo) {
        NSArray *moreUser = [InvestorUserModel objectsWithInfo:resultInfo];
        [_usersArray addObjectsFromArray:moreUser];
        [self hideRefreshViewWithCount:moreUser.count];
        [self.tableView reloadData];
    } Failed:^(NSError *error) {
        
    }];
}


// 取最新投资案例列表
- (void)getNewInvestorJigouCasesList
{
    [WeLianClient getInvestorCasesWithJigouid:_firmID Page:@(_casePage) Size:@(KCellConut) Success:^(id resultInfo) {
        [_casesArray removeAllObjects];
        _casesArray = [NSMutableArray arrayWithArray:[CasesModel objectsWithInfo:resultInfo]];
        [self hideRefreshViewWithCount:_casesArray.count];
        [self.tableView reloadData];
    } Failed:^(NSError *error) {
        
    }];
}
// 取更多投资案例列表
- (void)getMoreInvestorJigouCasesList
{
    [WeLianClient getInvestorCasesWithJigouid:_firmID Page:@(_casePage) Size:@(KCellConut) Success:^(id resultInfo) {
        NSArray *moreCases = [CasesModel objectsWithInfo:resultInfo];
        [_casesArray addObjectsFromArray:moreCases];
        [self hideRefreshViewWithCount:moreCases.count];
        [self.tableView reloadData];
    } Failed:^(NSError *error) {
        
    }];
}

// 刷新最新数据
- (void)getNewInvestorListData
{
    _userPage = 1;
    _casePage = 1;
    [self getOneInvestorJigouData];
    if (self.wlSegmentedControl.selectedSegmentIndex==0) {
        [self getNewInvestorJigouPersonList];
    }else{
        [self getNewInvestorJigouCasesList];
    }
}

// 加载更多数据
- (void)getMoreInvestorListData
{
    if (self.wlSegmentedControl.selectedSegmentIndex==0) {
        [self getMoreInvestorJigouPersonList];
    }else{
        [self getMoreInvestorJigouCasesList];
    }
}

- (void)loadTableViewHeaderV
{
    self.title = _touziJiGouM.title;
    CGFloat headerH = [FirmInfoHeaderView getFirmHeaderHeigh:_touziJiGouM];
    FirmInfoHeaderView *firmHeader =[[FirmInfoHeaderView alloc] init];
    [firmHeader setFrame:CGRectMake(0, 0, SuperSize.width, headerH)];
    [firmHeader setTouziJiGouM:_touziJiGouM];
    [self.tableView setTableHeaderView:firmHeader];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [self.tableView registerNib:[UINib nibWithNibName:@"FirmCasesCell" bundle:nil] forCellReuseIdentifier:casecellid];
    [self.tableView setTableFooterView:[UIView new]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SegmentedH;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.wlSegmentedControl.selectedSegmentIndex==0) {
        return 130;
    }else{
        return 80;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WEAKSELF
    NSString *userCountStr = [NSString stringWithFormat:@"投资人 %ld",(long)_touziJiGouM.membercount.integerValue];
    NSString *caseCountStr = [NSString stringWithFormat:@"投资案例 %ld",(long)_touziJiGouM.casecount.integerValue];
    [self.wlSegmentedControl setSectionTitles:@[userCountStr,caseCountStr]];
    [self.wlSegmentedControl setIndexChangeBlock:^(NSInteger index) {
        if (index ==0) {
            if (weakSelf.usersArray.count) {
                [weakSelf.tableView reloadData];
            }else{
                [weakSelf getNewInvestorListData];
            }
        }else if (index ==1){
            if (weakSelf.casesArray.count) {
                [weakSelf.tableView reloadData];
            }else{
                [weakSelf getNewInvestorListData];
            }
        }

    }];

    return self.wlSegmentedControl;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.wlSegmentedControl.selectedSegmentIndex) {
        return _casesArray.count;
    }
    return _usersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.wlSegmentedControl.selectedSegmentIndex==0) {
        InvestorCell *cell = [tableView dequeueReusableCellWithIdentifier:usercellid];
        if (cell == nil) {
            cell = [[InvestorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:usercellid];
        }
        InvestorUserModel *userM = _usersArray[indexPath.row];
        [cell setInvestUserM:userM];
        return cell;
    }else{
        FirmCasesCell *cell = [tableView dequeueReusableCellWithIdentifier:casecellid];
        [cell.nameLabel setTextColor:KBlueTextColor];
        [cell.timeLabel setTextColor:kNormalTextColor];
        [cell.stageLabel setTextColor:kTitleNormalTextColor];
        if (indexPath.row == _casesArray.count-1) {
            cell.lineImage.image = [UIImage imageNamed:@"me_lvli_line_end"];
        }else{
            cell.lineImage.image = [UIImage imageNamed:@"me_lvli_line"];
        }
        CasesModel *casesM = _casesArray[indexPath.row];
        [cell.nameLabel setText:casesM.title];
        [cell.timeLabel setText:casesM.investtime];
        [cell.stageLabel setText:[NSString stringWithFormat:@"%@  %@",casesM.amount,casesM.stage]];
        
        return cell;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
