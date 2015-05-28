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

@interface ProjectMainViewController ()<XZPageViewControllerDataSource,XZPageViewControllerDelegate,ShaiXuanViewDataSource>

@property (nonatomic,strong) ShaiXuanView *shaixuanView;
@property (nonatomic,strong) NSArray *industrys;
@property (nonatomic,strong) NSArray *citys;
@property (nonatomic,strong) NSArray *stages;

@end

@implementation ProjectMainViewController

- (NSString *)title
{
    return @"创业项目";
}

- (ShaiXuanView *)shaixuanView
{
    if (!_shaixuanView) {
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
        self.navTitlesArr = @[@"最新",@"热门",@"项目集",@"筛选"];
        self.navTitleImagesArr = @[@"",@"",@"",@"xiangmu_list_funnel"];
        self.dataSource = self;
        self.delegate = self;
        
        //项目领域
//        NSArray *industryInfos = [InvestIndustry getAllInvestIndustrys];
//        NSArray *projectCitys = [CityInfo getAllCityInfosType:@(2)];
        
        //获取领域
        self.industrys = [NSArray arrayWithContentsOfFile:[[ResManager documentPath] stringByAppendingString:@"/Industrys.plist"]];
        //获取城市
        self.citys = [NSArray arrayWithContentsOfFile:[[ResManager documentPath] stringByAppendingString:@"/ProjectCitys.plist"]];
        //融资阶段 0:种子轮投资  1:天使轮投资  2:pre-A轮投资 3:A轮投资 4:B轮投资  5:C轮投资
        self.stages = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"FinancingStagePlist" withExtension:@"plist"]];
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

#pragma mark - 筛选代理方法
// 多少组
- (NSInteger)numberOfSections
{
    return 3;
}
// 每组多少个
- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return _industrys.count;
        }
            break;
        case 1:
        {
            return _stages.count;
        }
            break;
        case 2:
        {
            return _citys.count;
        }
            break;
        default:
            return 0;
            break;
    }
}
// 每组组头文字
- (NSString *)titleWithSectionsTextatIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            return [_industrys[indexPath.row] objectForKey:@"industryname"];
        }
            break;
        case 1:
        {
            return [_stages[indexPath.row] objectForKey:@"stagename"];
        }
            break;
        case 2:
        {
            return [_citys[indexPath.row] objectForKey:@"name"];
        }
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *)textCellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            return [_industrys[indexPath.row] objectForKey:@"industryname"];
        }
            break;
        case 1:
        {
            return [_stages[indexPath.row] objectForKey:@"stagename"];
        }
            break;
        case 2:
        {
            return [_citys[indexPath.row] objectForKey:@"name"];
        }
            break;
        default:
            return @"";
            break;
    }
}

@end
