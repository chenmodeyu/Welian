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

#import "ShaiXuanView.h"

@interface ProjectMainViewController ()<XZPageViewControllerDataSource,XZPageViewControllerDelegate>

@property (nonatomic,strong) ShaiXuanView *shaixuanView;

@property (nonatomic, strong) NSArray *shaiXuanArray;

@end

@implementation ProjectMainViewController

- (NSString *)title
{
    return @"创业项目";
}

- (ShaiXuanView *)shaixuanView
{
    if (!_shaixuanView) {
        _shaixuanView = [[ShaiXuanView alloc] initWithShaiXuanType:ShaiXuanTypeProject];
        _shaixuanView.titleText = @"创业项目";
    }
    return _shaixuanView;
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
        [weakSelf updateSegmentUIWithIndex:index];
        [weakSelf transitionToViewControllerAtIndex:index];
    }];
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

//设置切换按钮
- (void)updateSegmentUIWithIndex:(NSInteger)index
{
    if (index == (self.navTitleImagesArr.count - 1)) {
        self.segmentedControl.sectionImages = @[@"",@"",@"",@"xiangmu_list_funnel_selected"];
        [self.shaixuanView showVC];
//        WEAKSELF
        self.shaixuanView.shaixuanBlock = ^(){
            //通知获取搜索数据
            [KNSNotification postNotificationName:kSearchProjectInfoKey object:nil];
        };
    }else{
        self.segmentedControl.sectionImages = self.navTitleImagesArr;
    }
}

#pragma mark - XZPageViewControllerDataSource Delegate
- (UIViewController *)viewPageController:(XZPageViewController *)pageViewController contentViewControllerForNavAtIndex:(NSInteger)index
{
    //项目 //1：最新   2：热门  3：项目集 4：筛选
    ProjectListViewController *projectListVC = [[ProjectListViewController alloc] initWithProjectType:index + 1];
    return projectListVC;
}

- (void)viewPageController:(XZPageViewController *)pageViewController pageViewControllerChangedAtIndex:(NSInteger)index
{
    [self.segmentedControl setSelectedSegmentIndex:index animated:YES];
    [self updateSegmentUIWithIndex:index];
}


@end
