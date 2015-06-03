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
@property (assign,nonatomic) NSInteger projectType;//1：推荐   2：热门  3：项目集 4：筛选
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
        switch (_projectType) {
            case 3:
                _notView = [[NotstringView alloc] initWithFrame:self.tableView.frame withTitleStr:@"暂无项目集"];
                break;
            case 4:
                _notView = [[NotstringView alloc] initWithFrame:Rect(0, 0, self.view.width, ScreenHeight) withTitStr:@"无筛选结果" andImageName:@"xiangmu_list_funnel_big"];
                break;
            default:
                _notView = [[NotstringView alloc] initWithFrame:self.tableView.frame withTitleStr:@"暂无创业项目"];
                break;
        }
    }
    return _notView;
}

//标题设置
- (NSString *)title
{
    return @"创业项目";
}

//1：最新   2：热门  3：项目集 4：筛选
- (instancetype)initWithProjectType:(NSInteger)projectType
{
    self = [super init];
    if (self) {
        self.allDataSource = [NSMutableArray array];
        self.pageIndex = 1;
        self.pageSize = KCellConut;
        self.projectType = projectType;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUiInfo];
    // 隐藏当前的上拉刷新控件
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //监听报名状态改变
    [KNSNotification addObserver:self selector:@selector(updateUiInfo) name:kUpdateProjectListUI object:nil];
    
    if(_projectType == 4){
        //监听 更新搜索数据 //1：最新   2：热门 3：项目集 4筛选
        [KNSNotification addObserver:self selector:@selector(reSearchProjectInfo) name:kSearchProjectInfoKey object:nil];
    }
    
    [self.tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    //隐藏表格分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.refreshControl addTarget:self action:@selector(loadReflshData) forControlEvents:UIControlEventValueChanged];
//    [self.tableView addSubview:self.refreshControl];
    
    //添加分享按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建项目" style:UIBarButtonItemStyleBordered target:self action:@selector(createProject)];
    
    
//    [self.tableView reloadData];
    
    //下拉刷新
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(loadReflshData)];
    
    //上提加载更多
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataArray)];
    // 隐藏当前的上拉刷新控件
    self.tableView.footer.hidden = YES;
    [self.tableView.header beginRefreshing];
    //加载数据
//    [self loadReflshData];
}

#pragma mark - UITableView Datasource&Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //1：推荐   2：热门  3：项目集 4：筛选
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
    //1：推荐   2：热门  3：项目集 4：筛选
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
    //1：推荐   2：热门 3：项目集 4筛选
    if (_projectType == 1 || _projectType == 4) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 32.f)];
        headerView.backgroundColor = RGB(236.f, 238.f, 241.f);
        
        if (_projectType == 1) {
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
        }else{
            LogInUser *loginUser = [LogInUser getCurrentLoginUser];
            NSMutableArray *selectInfos = [NSMutableArray array];
            //项目 领域搜索条件
            NSDictionary *searchIndustryinfo = [UserDefaults objectForKey:[NSString stringWithFormat:kProjectSearchIndustryKey,loginUser.uid]];
            //项目 地区条件
            NSDictionary *searchCity = [UserDefaults objectForKey:[NSString stringWithFormat:kProjectSearchCityKey,loginUser.uid]];
            //项目 投资阶段条件
            NSDictionary *searchStage = [UserDefaults objectForKey:[NSString stringWithFormat:kProjectSearchStageKey,loginUser.uid]];
            if (searchIndustryinfo) {
                [selectInfos addObject:searchIndustryinfo[@"industryname"]];
            }
            if (searchStage) {
                [selectInfos addObject:searchStage[@"stagename"]];
            }
            if (searchCity) {
                [selectInfos addObject:searchCity[@"name"]];
            }
            if (selectInfos.count > 0) {
                CGFloat leftWith = 15.f;
                for (int i = 0; i < selectInfos.count; i++) {
                    UILabel *titleLabel = [[UILabel alloc] init];
                    titleLabel.backgroundColor = [UIColor whiteColor];
                    titleLabel.textColor = kNormalTextColor;
                    titleLabel.font = kNormal12Font;
                    titleLabel.text = selectInfos[i];
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    titleLabel.layer.cornerRadius = 3.f;
                    titleLabel.layer.masksToBounds = YES;
                    titleLabel.layer.borderColor = kNormalLineColor.CGColor;
                    titleLabel.layer.borderWidth = 0.6f;
                    [titleLabel sizeToFit];
                    titleLabel.width = titleLabel.width + 10.f;
                    titleLabel.height = 22.f;
                    titleLabel.left = leftWith;
                    titleLabel.centerY = headerView.height / 2.f;
                    leftWith = titleLabel.right + 5.f;
                    [headerView addSubview:titleLabel];
                }
            }
        }
        return headerView;
    }else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1：推荐   2：热门  3：项目集 4：筛选
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
    //1：推荐   2：热门  3：项目集 4：筛选
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
    //1：推荐   2：热门  3：项目集 4：筛选
    switch (_projectType) {
        case 1:
            return 32.f;
            break;
        case 4:
        {
            LogInUser *loginUser = [LogInUser getCurrentLoginUser];
            //项目 领域搜索条件
            NSDictionary *searchIndustryinfo = [UserDefaults objectForKey:[NSString stringWithFormat:kProjectSearchIndustryKey,loginUser.uid]];
            //项目 地区条件
            NSDictionary *searchCity = [UserDefaults objectForKey:[NSString stringWithFormat:kProjectSearchCityKey,loginUser.uid]];
            //项目 投资阶段条件
            NSDictionary *searchStage = [UserDefaults objectForKey:[NSString stringWithFormat:kProjectSearchStageKey,loginUser.uid]];
            if (searchIndustryinfo || searchStage || searchCity) {
                return 32.f;
            }else{
                return 0.f;
            }
        }
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
            return [NSObject getHeightWithMaxWidth:ScreenWidth - 20.f In4ScreWidth:300.f In4ScreeHeight:110.f];
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
            return [NSObject getHeightWithMaxWidth:ScreenWidth - 20.f In4ScreWidth:300.f In4ScreeHeight:110.f];
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

//重新搜索项目信息
- (void)reSearchProjectInfo
{
    // 隐藏当前的上拉刷新控件
    self.tableView.footer.hidden = YES;
    [self.tableView.header beginRefreshing];
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
//    [self checkFooterViewWith:_datasource];
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
//                                            [self.tableView.header endRefreshing];
//                                            [self.tableView.footer endRefreshing];
                                            //保存数据
                                            [self saveProjectInfoWithResultInfo:resultInfo Type:@(0)];
//                                            WEAKSELF
//                                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                                //0：普通   1：收藏  2：创建  3：热门  4:上次筛选  -1：已删除
//                                                NSArray *sortedInfo = [ProjectInfo allNormalProjectInfos];
//                                                weakSelf.headDatasource = sortedInfo[0];
//                                                weakSelf.datasource = sortedInfo[1];
//                                                
//                                                //添加数据
//                                                [weakSelf.allDataSource addObjectsFromArray:resultInfo];
//                                                dispatch_async(dispatch_get_main_queue(), ^{
//                                                    [weakSelf.tableView.header endRefreshing];
//                                                    [weakSelf.tableView.footer endRefreshing];
//                                                    [weakSelf.tableView reloadData];
//                                                    
//                                                    if(weakSelf.allDataSource.count == 0){
//                                                        [weakSelf.tableView addSubview:weakSelf.notView];
//                                                        [weakSelf.tableView sendSubviewToBack:weakSelf.notView];
//                                                    }else{
//                                                        [weakSelf.notView removeFromSuperview];
//                                                    }
//                                                    [weakSelf checkFooterViewWith:resultInfo];
//                                                });
//                                            });
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
//                                            [self.tableView.header endRefreshing];
//                                            [self.tableView.footer endRefreshing];
                                            //保存数据
                                            [self saveProjectInfoWithResultInfo:resultInfo Type:@(3)];
//                                            WEAKSELF
//                                            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                                //获取热门项目
//                                                weakSelf.datasource = [ProjectInfo allMyProjectInfoWithType:@(3)];
//                                                
//                                                dispatch_async(dispatch_get_main_queue(), ^{
//                                                    [weakSelf.tableView.header endRefreshing];
//                                                    [weakSelf.tableView.footer endRefreshing];
//                                                    
//                                                    [weakSelf.tableView reloadData];
//                                                    
//                                                    [weakSelf checkNotViewShow];
//                                                    [weakSelf checkFooterViewWith:resultInfo];
//                                                });
//                                            });
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
                //0：普通   1：收藏  2：创建  3：热门  4:上次筛选  -1：已删除
                if (_pageIndex == 1) {
                    //第一页
                    [ProjectClassInfo deleteAllProjectClassInfos];
                }
                
                NSArray *projectClasss = resultInfo;
                if (projectClasss.count > 0) {
                    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                        NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"isNow",@(YES)];
                        LogInUser *loginUser = [LogInUser MR_findFirstWithPredicate:pre inContext:localContext];
                        
                        for (IProjectClassModel *iProjectClassModel in projectClasss) {
                            NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"cid",iProjectClassModel.cid];
                            ProjectClassInfo *projectClassInfo = [ProjectClassInfo MR_findFirstWithPredicate:pre inContext:localContext];
                            if (!projectClassInfo) {
                                projectClassInfo = [ProjectClassInfo MR_createEntityInContext:localContext];
                            }
                            projectClassInfo.cid = iProjectClassModel.cid;
                            projectClassInfo.title = iProjectClassModel.title;
                            projectClassInfo.photo = iProjectClassModel.photo;
                            projectClassInfo.projectCount = iProjectClassModel.projectCount;
                            projectClassInfo.isShow = @(YES);
                            
                            [loginUser addRsProjectClassInfosObject:projectClassInfo];
                        }
                    } completion:^(BOOL contextDidSave, NSError *error) {
                        [self.tableView.header endRefreshing];
                        [self.tableView.footer endRefreshing];
                        
                        //获取项目集
                        self.datasource = [ProjectClassInfo getAllProjectClassInfos];
                        [self.tableView reloadData];
                        
                        [self checkNotViewShow];
                        [self checkFooterViewWith:resultInfo];
                    }];
                }else{
                    [self.tableView.header endRefreshing];
                    [self.tableView.footer endRefreshing];
                    
                    //获取项目集
                    self.datasource = [ProjectClassInfo getAllProjectClassInfos];
                    [self.tableView reloadData];
                    
                    [self checkNotViewShow];
                    [self checkFooterViewWith:resultInfo];
                }
                
//                WEAKSELF
//                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    //获取项目集
//                    weakSelf.datasource = [ProjectClassInfo getAllProjectClassInfos];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [weakSelf.tableView.header endRefreshing];
//                        [weakSelf.tableView.footer endRefreshing];
//                        [weakSelf.tableView reloadData];
//                        
//                        [weakSelf checkNotViewShow];
//                        [weakSelf checkFooterViewWith:resultInfo];
//                    });
//                });
            } Failed:^(NSError *error) {
                [self.tableView.header endRefreshing];
                [self.tableView.footer endRefreshing];
            }];
        }
            break;
        case 4:
        {
            LogInUser *loginUser = [LogInUser getCurrentLoginUser];
            //项目 领域搜索条件
            NSDictionary *searchIndustryinfo = [UserDefaults objectForKey:[NSString stringWithFormat:kProjectSearchIndustryKey,loginUser.uid]];
            //项目 地区条件
            NSDictionary *searchCity = [UserDefaults objectForKey:[NSString stringWithFormat:kProjectSearchCityKey,loginUser.uid]];
            //项目 投资阶段条件
            NSDictionary *searchStage = [UserDefaults objectForKey:[NSString stringWithFormat:kProjectSearchStageKey,loginUser.uid]];
            
            if (!searchIndustryinfo && !searchCity && !searchStage) {
                //第一次进入 无筛选条件时
                [self.tableView.header endRefreshing];
                [self.tableView.footer endRefreshing];
                
                //获取项目
                self.datasource = [ProjectInfo allMyProjectInfoWithType:@(4)];
                [self.tableView reloadData];
                
                [self checkNotViewShow];
                [self checkFooterViewWith:nil];
            }else{
                //检索项目 -1  //不限制
                [WeLianClient searchProcjetWithIndustryid:searchIndustryinfo ? @([searchIndustryinfo[@"industryid"] integerValue]) : @(-1) //领域
                                                    Stage:searchStage ? @([searchStage[@"stage"] integerValue]) : @(-1) //投资阶段
                                                   Cityid:searchCity ? @([searchCity[@"cityid"] integerValue]) : @(-1) //地区
                                                  Success:^(id resultInfo) {
                                                      //保存数据
                                                      [self saveProjectInfoWithResultInfo:resultInfo Type:@(4)];
                                                  } Failed:^(NSError *error) {
                                                      [self.tableView.header endRefreshing];
                                                      [self.tableView.footer endRefreshing];
                                                  }];
            }
        }
            break;
        default:
            break;
    }
}

- (void)saveProjectInfoWithResultInfo:(NSArray *)resultInfo Type:(NSNumber *)type
{
    //0：普通   1：收藏  2：创建  3：热门  4:上次筛选  -1：已删除
    if (_pageIndex == 1) {
        //第一页
        [ProjectInfo deleteAllProjectInfoWithType:type];
    }
    
//    if (resultInfo.count > 0) {
//        for (IProjectInfo *iProjectInfo in resultInfo) {
//            [ProjectInfo createProjectInfoWith:iProjectInfo withType:type];
//        }
//    }
    //异步保存数据到数据库
    if (resultInfo.count > 0) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"isNow",@(YES)];
            LogInUser *loginUser = [LogInUser MR_findFirstWithPredicate:pre inContext:localContext];
            
            for (IProjectInfo *iProjectInfo in resultInfo) {
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"type",type,@"pid",iProjectInfo.pid];
                ProjectInfo *projectInfo = [ProjectInfo MR_findFirstWithPredicate:pre inContext:localContext];
                if (!projectInfo) {
                    projectInfo = [ProjectInfo MR_createEntityInContext:localContext];
                }
                projectInfo.pid = iProjectInfo.pid;
                projectInfo.name = iProjectInfo.name;
                projectInfo.intro = iProjectInfo.intro;
                projectInfo.des = iProjectInfo.des;
                projectInfo.date = iProjectInfo.date;
                projectInfo.membercount = iProjectInfo.membercount;
                projectInfo.commentcount = iProjectInfo.commentcount;
                projectInfo.status = iProjectInfo.status;
                projectInfo.zancount = iProjectInfo.zancount;
                projectInfo.iszan = iProjectInfo.iszan;
                projectInfo.industrys = [iProjectInfo displayIndustrys];
                projectInfo.type = type;
                //设置用户
                if(!projectInfo.rsProjectUser){
                    //如果不存在，创建
                    ProjectUser *projectUser = [ProjectUser MR_createEntityInContext:localContext];
                    IBaseUserM *iBaseUserM = iProjectInfo.user;
                    projectUser.avatar = iBaseUserM.avatar;
                    projectUser.name = iBaseUserM.name;
                    projectUser.uid = iBaseUserM.uid;
                    projectUser.address = iBaseUserM.address;
                    projectUser.email = iBaseUserM.email;
                    projectUser.friendship = iBaseUserM.friendship;
                    projectUser.investorauth = iBaseUserM.investorauth;
                    projectUser.inviteurl = iBaseUserM.inviteurl;
                    projectUser.mobile = iBaseUserM.mobile;
                    //    baseUser.startupauth = iBaseUserM.startupauth;
                    projectUser.company = iBaseUserM.company;
                    projectUser.position = iBaseUserM.position;
                    projectUser.provinceid = iBaseUserM.provinceid;
                    projectUser.provincename = iBaseUserM.provincename;
                    projectUser.cityid = iBaseUserM.cityid;
                    projectUser.cityname = iBaseUserM.cityname;
                    projectUser.shareurl = iBaseUserM.shareurl;
                    projectInfo.rsProjectUser = projectUser;
                }
                
                if (type != 0) {
                    [loginUser addRsProjectInfosObject:projectInfo];
                }
            }
        } completion:^(BOOL contextDidSave, NSError *error) {
            [self reloadDataAndUpdateUIWithResultInfo:resultInfo Type:type];
        }];
    }else{
        [self reloadDataAndUpdateUIWithResultInfo:resultInfo Type:type];
    }
}

- (void)reloadDataAndUpdateUIWithResultInfo:(NSArray *)resultInfo Type:(NSNumber *)type
{
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    
    if (type.integerValue == 0) {
        NSArray *sortedInfo = [ProjectInfo allNormalProjectInfos];
        self.headDatasource = sortedInfo[0];
        self.datasource = sortedInfo[1];
        //添加数据
        [self.allDataSource addObjectsFromArray:resultInfo];
        [self.tableView reloadData];
        
        if(self.allDataSource.count == 0){
            [self.tableView addSubview:self.notView];
            [self.tableView sendSubviewToBack:self.notView];
        }else{
            [self.notView removeFromSuperview];
            _notView = nil;
        }
    }else{
        //获取热门项目
        self.datasource = [ProjectInfo allMyProjectInfoWithType:type];
        [self.tableView reloadData];
        
        [self checkNotViewShow];
    }
    
    [self checkFooterViewWith:resultInfo];
}

//检查页面展示信息
- (void)checkNotViewShow
{
    if(_datasource.count == 0){
        [self.tableView addSubview:self.notView];
        [self.tableView sendSubviewToBack:self.notView];
    }else{
        [self.notView removeFromSuperview];
        _notView = nil;
    }
}

//检查下拉按钮
- (void)checkFooterViewWith:(id)resultInfo
{
    //设置是否可以下拉刷新
    if ([resultInfo count] != _pageSize) {
        self.tableView.footer.hidden = YES;
    }else{
        self.tableView.footer.hidden = NO;
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
