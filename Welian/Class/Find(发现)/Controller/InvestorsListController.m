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

@interface InvestorsListController () <XZPageViewControllerDataSource,XZPageViewControllerDelegate,ShaiXuanViewDataSource>

@property (nonatomic, strong) ShaiXuanView *shaixuanView;
@property (nonatomic, assign) __block NSInteger selectIndex;
@property (nonatomic, strong) NSArray *titArray;

@end

@implementation InvestorsListController

- (ShaiXuanView *)shaixuanView
{
    if (_shaixuanView == nil) {
        _shaixuanView = [[ShaiXuanView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _shaixuanView.dataSource = self;
        _shaixuanView.titleText = @"创业项目";
    }
    return _shaixuanView;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.navTitlesArr = @[@"最新",@"投资机构",@"筛选"];
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"认证投资人" style:UIBarButtonItemStyleBordered target:self action:@selector(goToInvestor)];
    WEAKSELF
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        if (index == self.navTitlesArr.count-1) {
//            [weakSelf.view.window addSubview:weakSelf.shaixuanView];
            [weakSelf.shaixuanView showVC];
        }else{
            [weakSelf transitionToViewControllerAtIndex:index];
        }
        
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
        InvestorsTableController *investOrgTableVC = [[InvestorsTableController alloc] initWithInvestorsType:InvestorsTypeOrganization];
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

#pragma mark - 筛选代理方法
// 多少组
- (NSInteger)numberOfSections
{
    return 3;
}
// 每组多少个
- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    return 13;
}
// 每组组头文字
- (NSString *)titleWithSectionsTextatIndexPath:(NSIndexPath *)indexPath
{
    return @"dsa";
}

- (NSString *)textCellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return @"fda";
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
