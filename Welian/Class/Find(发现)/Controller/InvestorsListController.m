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

@interface InvestorsListController () <XZPageViewControllerDataSource,XZPageViewControllerDelegate>

@property (nonatomic, strong) ShaiXuanView *shaixuanView;
@property (nonatomic, assign) __block NSInteger selectIndex;
@property (nonatomic, strong) NSArray *titArray;

@end

@implementation InvestorsListController

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
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        
    }];
}

- (UIViewController *)viewPageController:(XZPageViewController *)pageViewController contentViewControllerForNavAtIndex:(NSInteger)index
{
    UIViewController *fda = [[UIViewController alloc] init];
//    fda.view.backgroundColor = [UIColor orangeColor];
    return fda;
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
