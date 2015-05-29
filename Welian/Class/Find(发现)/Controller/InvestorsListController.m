//
//  InvestorsListController.m
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "InvestorsListController.h"
#import "InvestCerVC.h"
#import "ShaiXuanView.h"
#import "InvestorsTableController.h"

@interface InvestorsListController () <XZPageViewControllerDataSource,XZPageViewControllerDelegate>

@property (nonatomic, strong) ShaiXuanView *shaixuanView;
//@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, strong) NSArray *titArray;

@end

@implementation InvestorsListController

- (ShaiXuanView *)shaixuanView
{
    if (_shaixuanView == nil) {
        _shaixuanView = [[ShaiXuanView alloc] initWithShaiXuanType:ShaiXuanTypeInvestorUser];
        _shaixuanView.titleText = @"创业项目";
    }
    return _shaixuanView;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.navTitlesArr = @[@"最新",@"投资机构",@"筛选"];
        self.navTitleImagesArr = @[@"",@"",@"xiangmu_list_funnel"];
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"认证投资人" style:UIBarButtonItemStyleBordered target:self action:@selector(goToInvestor)];
    self.segmentedControl.sectionImages = @[@"",@"",@"",@"xiangmu_list_funnel_selected"];
    WEAKSELF
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        if (index == self.navTitlesArr.count-1) {
            [weakSelf.shaixuanView showVC];
            weakSelf.shaixuanView.shaixuanBlock = ^(){
                //通知获取搜索数据
                [KNSNotification postNotificationName:kSearchInvestorUserKey object:nil];
            };
        }
        [weakSelf transitionToViewControllerAtIndex:index];
    }];
}

- (UIViewController *)viewPageController:(XZPageViewController *)pageViewController contentViewControllerForNavAtIndex:(NSInteger)index
{
    if (index==0) {
        InvestorsTableController *investTableVC = [[InvestorsTableController alloc] initWithInvestorsType:InvestorsTypeUser];
        return investTableVC;
    }else if (index==1){
        InvestorsTableController *investOrgTableVC = [[InvestorsTableController alloc] initWithInvestorsType:InvestorsTypeOrganization];
        return investOrgTableVC;
    }else if (index ==2){
        InvestorsTableController *investOrgTableVC = [[InvestorsTableController alloc] initWithInvestorsType:InvestorsTypeShaiXuan];
        return investOrgTableVC;
    }
    return nil;
    

}

- (void)viewPageController:(XZPageViewController *)pageViewController pageViewControllerChangedAtIndex:(NSInteger)index
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 去认证
- (void)goToInvestor
{
    InvestCerVC *investVC = [[InvestCerVC alloc] init];
    [self.navigationController pushViewController:investVC animated:YES];
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
