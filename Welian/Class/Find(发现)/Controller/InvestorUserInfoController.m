//
//  InvestorUserInfoController.m
//  Welian
//
//  Created by dong on 15/5/25.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "InvestorUserInfoController.h"
#import "ProjectsMailingView.h"
#import "ProjectTouDiModel.h"
#import "InvestorInfoCell.h"
#import "InvestorFirmInfoController.h"

@interface InvestorUserInfoController ()
{
    InvestorUserInfoType _userType;
    InvestorUserModel *_investorUserM;
    NSNumber *_userID;
    NSNumber *_pID;
}

@property (nonatomic, strong) InvestorInfoHeadView *invesHeadView;

@end

@implementation InvestorUserInfoController

- (instancetype)initWithUserType:(InvestorUserInfoType)userType andUserData:(id)userData
{
    self = [super init];
    if (self) {
        _userType = userType;
        if (userType == InvestorUserTypeUID) {
            _userID = [userData objectAtIndex:0];
            _pID = [userData objectAtIndex:1];
            [WLHUDView showHUDWithStr:@"" dim:NO];
            [WeLianClient investorGetInfoWithUid:_userID pid:_pID Success:^(id resultInfo) {
                _investorUserM = [InvestorUserModel objectWithDict:resultInfo];
                [WLHUDView hiddenHud];
                [self reloadUserDataView];
                [self.tableView reloadData];
            } Failed:^(NSError *error) {
                
            }];
        }else if (userType == InvestorUserTypeModel){
            _investorUserM = userData;
            [self reloadUserDataView];
        }

    }
    return self;
}

- (void)reloadUserDataView
{
    self.title = _investorUserM.user.name;
    InvestorInfoHeadView *invesHeadView = [[InvestorInfoHeadView alloc] initWithFrame:CGRectMake(0, 0, SuperSize.width, 280)];
    [invesHeadView setInvestorUserModel:_investorUserM];
    [invesHeadView setUserType:_userType];
    [invesHeadView.mailingBut addTarget:self action:@selector(mailingInvestorClick) forControlEvents:UIControlEventTouchUpInside];
    [invesHeadView.agreeBut addTarget:self action:@selector(mailingInvestorClick) forControlEvents:UIControlEventTouchUpInside];
    [invesHeadView.rejectBut addTarget:self action:@selector(refusedMailingClick) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView setTableHeaderView:invesHeadView];
    self.invesHeadView = invesHeadView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setTableFooterView:[UIView new]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [InvestorInfoCell getCellHeightWith:_investorUserM];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    return [InvestorInfoCell getCellHeightWith:_investorUserM];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InvestorInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"infocell"];
    if (cell ==nil) {
        cell = [[InvestorInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"infocell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.firmBut addTarget:self action:@selector(firmButClick) forControlEvents:UIControlEventTouchUpInside];
    }
    [cell setInvestorUserM:_investorUserM];
    return cell;
}

// 跳转投资机构
- (void)firmButClick
{
    InvestorFirmInfoController *firmInfoVC = [[InvestorFirmInfoController alloc] initWithType:FirmInfoTypeFirmID andFirmData:_investorUserM.firm.firmid];
    [self.navigationController pushViewController:firmInfoVC animated:YES];
}

// 拒绝发送BP
- (void)refusedMailingClick
{
    // // 0 未处理， 1 不同意 ，2 同意，3 已发送。 -1 标示只查看投资人
    WEAKSELF
    [WeLianClient investorNoToudiWithUid:_investorUserM.user.uid Pid:_pID status:@(1) Success:^(id resultInfo) {
        [_investorUserM setStatus:@(1)];
        [weakSelf.invesHeadView setInvestorUserModel:_investorUserM];
    } Failed:^(NSError *error) {
        
    }];
}





// 投递
- (void)mailingInvestorClick
{
    WEAKSELF
    [WeLianClient getInvestorProjectsListPid:_investorUserM.user.uid Success:^(id resultInfo) {
        NSArray *projectArray = [ProjectTouDiModel objectsWithInfo:resultInfo];
        
        ProjectsMailingView *projectsMailingView = [[ProjectsMailingView alloc] initWithFrame:[UIScreen mainScreen].bounds andProjects:projectArray];
        __weak ProjectsMailingView *weakProView = projectsMailingView;
        projectsMailingView.mailingProBlock = ^(ProjectTouDiModel *touDiModel){
            [WeLianClient investorToudiWithPid:touDiModel.pid Uid:_investorUserM.user.uid Success:^(id resultInfo) {
                [_investorUserM setStatus:@(2)];
                if (_userType == InvestorUserTypeUID) {
                    [weakSelf.invesHeadView setInvestorUserModel:_investorUserM];
                }else if (_userType == InvestorUserTypeModel){
                    
                    
                }
                [WLHUDView showSuccessHUD:@"投递成功！"];
                [weakProView cancelSelfVC];
            } Failed:^(NSError *error) {
                
            }];
        };
        [self.view.window addSubview:projectsMailingView];
        DLog(@"%@",resultInfo);
    } Failed:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
