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

@interface InvestorUserInfoController ()
{
    InvestorUserInfoType _userType;
    InvestorUserModel *_investorUserM;
    NSNumber *_userID;
}
@end

@implementation InvestorUserInfoController

- (instancetype)initWithUserType:(InvestorUserInfoType)userType andUserData:(id)userData
{
    self = [super init];
    if (self) {
        _userType = userType;
        if (userType == InvestorUserTypeUID) {
            _userID = userData;
            [WLHUDView showCustomHUD:nil imageview:nil];
            [WeLianClient investorGetInfoWithUid:_userID Success:^(id resultInfo) {
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
    [self.tableView setTableHeaderView:invesHeadView];
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
    DLog(@"fdas");
}

// 投递
- (void)mailingInvestorClick
{
    IBaseUserM *meModel = [IBaseUserM getLoginUserBaseInfo];
    [WeLianClient getInvestorProjectsListPid:meModel.uid Success:^(id resultInfo) {
        NSArray *projectArray = [ProjectTouDiModel objectsWithInfo:resultInfo];
        
        ProjectsMailingView *projectsMailingView = [[ProjectsMailingView alloc] initWithFrame:[UIScreen mainScreen].bounds andProjects:projectArray];
        __weak ProjectsMailingView *weakProView = projectsMailingView;
        projectsMailingView.mailingProBlock = ^(ProjectTouDiModel *touDiModel){
            [WeLianClient investorToudiWithPid:touDiModel.pid Uid:_investorUserM.user.uid Success:^(id resultInfo) {
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
