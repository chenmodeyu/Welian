//
//  ProjectMainViewController.m
//  Welian
//
//  Created by weLian on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectMainViewController.h"
#import "CreateProjectController.h"
#import "ProjectListViewController.h"

@interface ProjectMainViewController ()<XZPageViewControllerDataSource,XZPageViewControllerDelegate>

@end

@implementation ProjectMainViewController

- (NSString *)title
{
    return @"创业项目";
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.navTitlesArr = @[@"最新",@"热门",@"项目集",@"筛选"];
        self.navTitleImagesArr = @[@"",@"",@"",@"xiangmu_list_funnel"];
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //添加分享按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建项目" style:UIBarButtonItemStyleBordered target:self action:@selector(createProject)];
    
    WEAKSELF
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        DLog(@"segmentedControl select:%d",(int)index);
        if (index == (weakSelf.navTitleImagesArr.count - 1)) {
            weakSelf.segmentedControl.sectionImages = @[@"",@"",@"",@"xiangmu_list_funnel_selected"];
        }else{
            weakSelf.segmentedControl.sectionImages = weakSelf.navTitleImagesArr;
        }
        [weakSelf transitionToViewControllerAtIndex:index];
    }];
}

#pragma mark - XZPageViewControllerDataSource Delegate
- (UIViewController *)viewPageController:(XZPageViewController *)pageViewController contentViewControllerForNavAtIndex:(NSInteger)index
{
    //项目
    ProjectListViewController *projectListVC = [[ProjectListViewController alloc] init];
    //1：最新   2：热门  3：项目集 4：筛选
    projectListVC.projectType = index + 1;
    return projectListVC;
}

- (void)viewPageController:(XZPageViewController *)pageViewController pageViewControllerChangedAtIndex:(NSInteger)index
{
    [self.segmentedControl setSelectedSegmentIndex:index animated:YES];
}

#pragma mark - Private
/**
 *  创建项目
 */
- (void)createProject
{
    CreateProjectController *createProjectVC = [[CreateProjectController alloc] initIsEdit:NO withData:nil];
    [self.navigationController pushViewController:createProjectVC animated:YES];
}


@end
