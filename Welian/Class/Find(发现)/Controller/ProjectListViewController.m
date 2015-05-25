//
//  ProjectListViewController.m
//  Welian
//
//  Created by weLian on 15/2/2.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectListViewController.h"
#import "ProjectDetailsViewController.h"
#import "CreateProjectController.h"
#import "ProjcetClassViewController.h"
#import "UserInfoViewController.h"

#import "ProjectInfoViewCell.h"
#import "ProjectClassViewCell.h"
#import "NotstringView.h"
#import "MJRefresh.h"

@interface ProjectListViewController ()

@property (strong,nonatomic) NSArray *headDatasource;
@property (strong,nonatomic) NSArray *datasource;
@property (strong,nonatomic) NSMutableArray *allDataSource;

@property (assign,nonatomic) NSInteger pageIndex;
@property (assign,nonatomic) NSInteger pageSize;

@property (strong, nonatomic) NotstringView *notView;

@end

@implementation ProjectListViewController

- (void)dealloc
{
    _datasource = nil;
    _headDatasource = nil;
    _allDataSource = nil;
    _notView = nil;
    [KNSNotification removeObserver:self];
}

- (NotstringView *)notView
{
    if (!_notView) {
        _notView = [[NotstringView alloc] initWithFrame:self.tableView.frame withTitleStr:@"暂无创业项目"];
    }
    return _notView;
}

//标题设置
- (NSString *)title
{
    return @"创业项目44";
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allDataSource = [NSMutableArray array];
        self.pageIndex = 1;
        self.pageSize = KCellConut;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //监听报名状态改变
    [KNSNotification addObserver:self selector:@selector(updateUiInfo) name:kUpdateProjectListUI object:nil];
    
    //隐藏表格分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(loadReflshData) forControlEvents:UIControlEventValueChanged];
//    [self.tableView addSubview:self.refreshControl];
    
    //添加分享按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建项目" style:UIBarButtonItemStyleBordered target:self action:@selector(createProject)];
    
    //1：最新   2：热门 3：项目集 4筛选
    switch (_projectType) {
        case 1:
        {
            NSArray *sortedInfo = [ProjectInfo allNormalProjectInfos];
            self.headDatasource = sortedInfo[0];
            self.datasource = sortedInfo[1];
        }
            break;
        case 2:
        {
            //0：普通   1：收藏  2：创建  3：热门  4:上次筛选  -1：已删除
            self.datasource = [ProjectInfo allMyProjectInfoWithType:@(3)];
        }
            break;
        case 3:
        {
            self.tableView.backgroundColor = KBgLightGrayColor;
            //设置底部空白区域
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 20.f)];
            footerView.backgroundColor = KBgLightGrayColor;
            [self.tableView setTableFooterView:footerView];
            self.datasource = [ProjectClassInfo getAllProjectClassInfos];
        }
            break;
        case 4:
        {
            //0：普通   1：收藏  2：创建  3：热门  4:上次筛选  -1：已删除
            self.datasource = [ProjectInfo allMyProjectInfoWithType:@(4)];
        }
            break;
        default:
            
            break;
    }
   
    
    //下拉刷新
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(loadReflshData)];
    
    //上提加载更多
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataArray)];
    // 隐藏当前的上拉刷新控件
    self.tableView.footer.hidden = YES;
    
    //加载数据
//    [self loadReflshData];
    [self.tableView.header beginRefreshing];
}

#pragma mark - UITableView Datasource&Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //1：最新   2：热门  3：项目集 4：筛选
    switch (_projectType) {
        case 1:
            return _headDatasource.count;
            break;
        default:
            return 1;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //1：最新   2：热门  3：项目集 4：筛选
    switch (_projectType) {
        case 1:
            return [_datasource[section] count];
            break;
        default:
            return _datasource.count;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_projectType == 1) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30.f)];
        headerView.backgroundColor = RGB(236.f, 238.f, 241.f);
        
        NSString *titile = _headDatasource[section];
        if ([[_headDatasource[section] dateFromShortString] isToday]) {
            titile = @"今天";
        }else if([[_headDatasource[section] dateFromShortString] isYesterday]){
            titile = @"昨天";
        }
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = RGB(125.f, 125.f, 125.f);
        titleLabel.font = kNormal14Font;
        titleLabel.text = titile;
        [titleLabel sizeToFit];
        titleLabel.left = 15.f;
        titleLabel.centerY = headerView.height / 2.f;
        [headerView addSubview:titleLabel];
        
        return headerView;
    }else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1：最新   2：热门  3：项目集 4：筛选
    switch (_projectType) {
        case 3:
        {
            //项目集
            static NSString *cellIdentifier = @"Project_Class_List_Cell";
            ProjectClassViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[ProjectClassViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.projectClassInfo = _datasource[indexPath.row];
            return cell;
        }
            break;
        default:
        {
            //项目列表
            static NSString *cellIdentifier = @"Project_List_Cell";
            ProjectInfoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[ProjectInfoViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.projectInfo = _projectType == 1 ? _datasource[indexPath.section][indexPath.row] : _datasource[indexPath.row];
            WEAKSELF
            [cell setUserInfoBlock:^(id userInfo){
                [weakSelf lookCreateUserInfo:userInfo];
            }];
            return cell;
        }
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //1：最新   2：热门  3：项目集 4：筛选
    switch (_projectType) {
        case 3:
        {
            //项目集
            ProjcetClassViewController *projcetClassVC = [[ProjcetClassViewController alloc] initWithProjectClassInfo:_datasource[indexPath.row]];
            [self.navigationController pushViewController:projcetClassVC animated:YES];
        }
            break;
        default:
        {
            //项目列表
            ProjectInfo *projectInfo = _projectType == 1 ? _datasource[indexPath.section][indexPath.row] : _datasource[indexPath.row];
            if (projectInfo) {
                ProjectDetailsViewController *projectDetailVC = [[ProjectDetailsViewController alloc] initWithProjectInfo:projectInfo];
                [self.navigationController pushViewController:projectDetailVC animated:YES];
            }
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //1：最新   2：热门  3：项目集 4：筛选
    switch (_projectType) {
        case 1:
            return 30.f;
            break;
        default:
            return 0.f;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   //1：最新   2：热门  3：项目集 4：筛选
    switch (_projectType) {
        case 3:
            return 110.f;
            break;
        default:
            return 70.f;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1：最新   2：热门  3：项目集 4：筛选
    switch (_projectType) {
        case 3:
            return 110.f;
            break;
        default:
            return 70.f;
            break;
    }
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

//下拉刷新数据
- (void)loadReflshData
{
    //开始刷新动画
//    [self.refreshControl beginRefreshing];
    self.pageIndex = 1;
    self.allDataSource = [NSMutableArray array];
    [self initData];
}

//加载更多数据
- (void)loadMoreDataArray
{
//    if (_pageIndex * _pageSize > _allDataSource.count) {
//        //隐藏加载更多动画
//        [self.tableView.header endRefreshing];
//        [self.tableView.footer endRefreshing];
//        self.tableView.footer.hidden = YES;
//    }else{
//        _pageIndex++;
//        self.tableView.footer.hidden = NO;
//        [self initData];
//    }
    _pageIndex++;
    [self initData];
}

- (void)updateUiInfo
{
    //获取数据
//    NSArray *sortedInfo = [ProjectInfo allNormalProjectInfos];
//    self.headDatasource = sortedInfo[0];
//    self.datasource = sortedInfo[1];
    //1：最新   2：热门 3：项目集 4筛选
    switch (_projectType) {
        case 1:
        {
            NSArray *sortedInfo = [ProjectInfo allNormalProjectInfos];
            self.headDatasource = sortedInfo[0];
            self.datasource = sortedInfo[1];
            self.allDataSource = [NSMutableArray arrayWithArray:_datasource];
        }
            break;
        case 2:
        {
            //0：普通   1：收藏  2：创建  3：热门  4:上次筛选  -1：已删除
            self.datasource = [ProjectInfo allMyProjectInfoWithType:@(3)];
        }
            break;
        case 3:
        {
            self.tableView.backgroundColor = KBgLightGrayColor;
            //设置底部空白区域
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 20.f)];
            footerView.backgroundColor = KBgLightGrayColor;
            [self.tableView setTableFooterView:footerView];
            self.datasource = [ProjectClassInfo getAllProjectClassInfos];
        }
            break;
        case 4:
        {
            //0：普通   1：收藏  2：创建  3：热门  4:上次筛选  -1：已删除
            self.datasource = [ProjectInfo allMyProjectInfoWithType:@(4)];
        }
            break;
        default:
            
            break;
    }
    [self.tableView reloadData];
}

//获取数据
- (void)initData{
    //1：最新   2：热门  3：项目集 4：筛选
    switch (_projectType) {
        case 1:
        {
            //大于零取某个用户的，-1取自己的，不传或者0取全部
            [WeLianClient getProjectListWithUid:@(0)//"uid":10086,// -1 取自己，0 取推荐的项目，大于0取id为uid的用户
                                           Page:@(_pageIndex)
                                           Size:@(_pageSize)
                                        Success:^(id resultInfo) {
                                            [self.tableView.header endRefreshing];
                                            [self.tableView.footer endRefreshing];
                                            
                                            //0：普通   1：收藏  2：创建  3：热门  4:上次筛选  -1：已删除
                                            if (_pageIndex == 1) {
                                                //第一页
                                                [ProjectInfo deleteAllProjectInfoWithType:@(0)];
                                            }
                                            NSArray *projects = resultInfo;
                                            if (projects.count > 0) {
                                                
                                                for (IProjectInfo *iProjectInfo in projects) {
                                                    [ProjectInfo createProjectInfoWith:iProjectInfo withType:@(0)];
                                                }
                                            }
                                            
                                            NSArray *sortedInfo = [ProjectInfo allNormalProjectInfos];
                                            self.headDatasource = sortedInfo[0];
                                            self.datasource = sortedInfo[1];
                                            
                                            //添加数据
                                            [_allDataSource addObjectsFromArray:projects];
                                            [self.tableView reloadData];
                                            
                                            //设置是否可以下拉刷新
                                            if ([resultInfo count] != KCellConut) {
                                                self.tableView.footer.hidden = YES;
                                            }else{
                                                self.tableView.footer.hidden = NO;
                                            }
                                            
                                            if(_allDataSource.count == 0){
                                                [self.tableView addSubview:self.notView];
                                                [self.tableView sendSubviewToBack:self.notView];
                                            }else{
                                                [_notView removeFromSuperview];
                                            }
                                        } Failed:^(NSError *error) {
                                            [self.tableView.header endRefreshing];
                                            [self.tableView.footer endRefreshing];
                                        }];
        }
            break;
        case 2:
        {
            //获取最热项目
            [WeLianClient getHotProjectWithPage:@(_pageIndex)
                                           Size:@(_pageSize)
                                        Success:^(id resultInfo) {
                                            [self.tableView.header endRefreshing];
                                            [self.tableView.footer endRefreshing];
                                            
                                            //0：普通   1：收藏  2：创建  3：热门  4:上次筛选  -1：已删除
                                            if (_pageIndex == 1) {
                                                //第一页
                                                [ProjectInfo deleteAllProjectInfoWithType:@(3)];
                                            }
                                            NSArray *projects = resultInfo;
                                            if (projects.count > 0) {
                                                
                                                for (IProjectInfo *iProjectInfo in projects) {
                                                    [ProjectInfo createProjectInfoWith:iProjectInfo withType:@(3)];
                                                }
                                            }
                                            
                                            //获取热门项目
                                            NSArray *hotProjects = [ProjectInfo allMyProjectInfoWithType:@(3)];
                                            self.datasource = hotProjects;
                                            
                                            [self.tableView reloadData];
                                            
                                            //设置是否可以下拉刷新
                                            if ([resultInfo count] != _pageSize) {
                                                self.tableView.footer.hidden = YES;
                                            }else{
                                                self.tableView.footer.hidden = NO;
                                            }
                                            
                                            if(_datasource.count == 0){
                                                [self.tableView addSubview:self.notView];
                                                [self.tableView sendSubviewToBack:self.notView];
                                            }else{
                                                [_notView removeFromSuperview];
                                            }
                                        } Failed:^(NSError *error) {
                                            [self.tableView.header endRefreshing];
                                            [self.tableView.footer endRefreshing];
                                        }];
        }
            break;
        case 3:
        {
            //项目集
            [WeLianClient getProjectClassificationsWithSuccess:^(id resultInfo) {
                [self.tableView.header endRefreshing];
                [self.tableView.footer endRefreshing];
                
                //0：普通   1：收藏  2：创建  3：热门  4:上次筛选  -1：已删除
                if (_pageIndex == 1) {
                    //第一页
                    [ProjectClassInfo deleteAllProjectClassInfos];
                }
                NSArray *projectClasss = resultInfo;
                if (projectClasss.count > 0) {
                    
                    for (IProjectClassModel *iProjectClassModel in projectClasss) {
                        [ProjectClassInfo createProjectClassInfoWith:iProjectClassModel];
                    }
                }
                
                //获取项目集
                self.datasource = [ProjectClassInfo getAllProjectClassInfos];
                [self.tableView reloadData];
                
                //设置是否可以下拉刷新
                if ([resultInfo count] != _pageSize) {
                    self.tableView.footer.hidden = YES;
                }else{
                    self.tableView.footer.hidden = NO;
                }
                
                if(_datasource.count == 0){
                    [self.tableView addSubview:self.notView];
                    [self.tableView sendSubviewToBack:self.notView];
                }else{
                    [_notView removeFromSuperview];
                }
            } Failed:^(NSError *error) {
                [self.tableView.header endRefreshing];
                [self.tableView.footer endRefreshing];
            }];
        }
            break;
        case 4:
        {
            //检索项目 -1  //不限制
            [WeLianClient searchProcjetWithIndustryid:@(-1) //领域
                                                Stage:@(-1) //投资阶段
                                               Cityid:@(-1) //地区
                                              Success:^(id resultInfo) {
                                                  [self.tableView.header endRefreshing];
                                                  [self.tableView.footer endRefreshing];
                                                  
                                                  //0：普通   1：收藏  2：创建  3：热门  4:上次筛选  -1：已删除
                                                  if (_pageIndex == 1) {
                                                      //第一页
                                                      [ProjectInfo deleteAllProjectInfoWithType:@(4)];
                                                  }
                                                  NSArray *projects = resultInfo;
                                                  if (projects.count > 0) {
                                                      for (IProjectInfo *iProjectInfo in projects) {
                                                          [ProjectInfo createProjectInfoWith:iProjectInfo withType:@(4)];
                                                      }
                                                  }
                                                  
                                                  //获取项目
                                                  self.datasource = [ProjectInfo allMyProjectInfoWithType:@(4)];
                                                  [self.tableView reloadData];
                                                  
                                                  //设置是否可以下拉刷新
                                                  if ([resultInfo count] != _pageSize) {
                                                      self.tableView.footer.hidden = YES;
                                                  }else{
                                                      self.tableView.footer.hidden = NO;
                                                  }
                                                  
                                                  if(_datasource.count == 0){
                                                      [self.tableView addSubview:self.notView];
                                                      [self.tableView sendSubviewToBack:self.notView];
                                                  }else{
                                                      [_notView removeFromSuperview];
                                                  }
                                              } Failed:^(NSError *error) {
                                                  [self.tableView.header endRefreshing];
                                                  [self.tableView.footer endRefreshing];
                                              }];
        }
            break;
        default:
            break;
    }
}

//查看创建用户的信息
- (void)lookCreateUserInfo:(id)userInfo
{
    if ([userInfo isKindOfClass:[ProjectInfo class]]) {
        IBaseUserM *baseUser = [[userInfo rsProjectUser] toIBaseUserModelInfo];
        if (baseUser) {
            UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] initWithBaseUserM:baseUser OperateType:nil HidRightBtn:NO];
            [self.navigationController pushViewController:userInfoVC animated:YES];
        }
    }
}

@end
