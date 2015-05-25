//
//  ProjcetClassViewController.m
//  Welian
//
//  Created by weLian on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjcetClassViewController.h"
#import "ProjectDetailsViewController.h"
#import "UserInfoViewController.h"

#import "ProjectInfoViewCell.h"
#import "NoteTableViewCell.h"
#import "CSLoadingImageView.h"

#define kHeaderImageHeight 100.f

@interface ProjcetClassViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (assign,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSArray *datasource;
@property (strong,nonatomic) ProjectClassInfo *projectClassInfo;

@property (assign,nonatomic) NSInteger pageIndex;
@property (assign,nonatomic) NSInteger pageSize;

@end

@implementation ProjcetClassViewController

- (NSString *)title
{
    return @"项目集";
}

- (instancetype)initWithProjectClassInfo:(ProjectClassInfo *)projectClassInfo
{
    self = [super init];
    if (self) {
        self.projectClassInfo = projectClassInfo;
        self.pageIndex = 1;
        self.pageSize = KCellConut;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_tableView shouldPositionParallaxHeader];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //tableview头部距离问题
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //获取数据
    self.datasource = [ProjectInfo allMyProjectInfoWithType:_projectClassInfo.cid];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f,ViewCtrlTopBarHeight,self.view.width,self.view.height - ViewCtrlTopBarHeight)];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    //隐藏表格分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    //    [tableView setDebug:YES];
    
    //设置底部空白区域
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 40.f)];
    [tableView setTableFooterView:footerView];
    
    //下拉刷新
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(loadInitData)];
    
    //上提加载更多
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataArray)];
    // 隐藏当前的上拉刷新控件
    self.tableView.footer.hidden = YES;
    
    //加载数据
    //    [self loadReflshData];
    [self.tableView.header beginRefreshing];
    
    CSLoadingImageView *headerView = [[CSLoadingImageView alloc] init];
    //设置图片
    [headerView sd_setImageWithURL:[NSURL URLWithString:_projectClassInfo.photo]
                      placeholderImage:nil
                               options:SDWebImageRetryFailed|SDWebImageLowPriority
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 //图片进行染色（Tinting）、增加亮度（lightening）以及降低亮度（darkening）
                                 [headerView setImage:[image rt_darkenWithLevel:0.5f]];
                             }];
    [_tableView setParallaxHeaderView:headerView
                                 mode:VGParallaxHeaderModeFill
                               height:kHeaderImageHeight];
    
    UIView *stickyView = [[UIView alloc] initWithFrame:Rect(0, 0, _tableView.width, kHeaderImageHeight)];
    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = kNormalBlod19Font;
    titleLabel.text = _projectClassInfo.title;
    [titleLabel sizeToFit];
    titleLabel.centerX = stickyView.width / 2.f;
    titleLabel.centerY = stickyView.height / 2.f - 10.f;
    [stickyView addSubview:titleLabel];
    
    //副标题
    UILabel *detailTitleLabel = [[UILabel alloc] init];
    detailTitleLabel.textColor = [UIColor whiteColor];
    detailTitleLabel.font = kNormal12Font;
    detailTitleLabel.text = [NSString stringWithFormat:@"%d个项目",_projectClassInfo.projectCount.integerValue];
    [detailTitleLabel sizeToFit];
    detailTitleLabel.centerX = titleLabel.centerX;
    detailTitleLabel.top = titleLabel.bottom + 10.f;
    [stickyView addSubview:detailTitleLabel];
//    [stickyView setDebug:YES];
    
    self.tableView.parallaxHeader.stickyViewPosition = VGParallaxHeaderStickyViewPositionTop;
    [self.tableView.parallaxHeader setStickyView:stickyView
                                      withHeight:kHeaderImageHeight];
}

#pragma mark - Private
- (void)loadInitData
{
    [WeLianClient getProjectClassListWithCid:_projectClassInfo.cid
                                        Page:@(_pageIndex)
                                        Size:@(_pageSize)
                                     Success:^(id resultInfo) {
                                         [self.tableView.header endRefreshing];
                                         [self.tableView.footer endRefreshing];
                                         
                                         //0：普通   1：收藏  2：创建  3：热门  4:上次筛选  -1：已删除  other:对应项目集的id
                                         if (_pageIndex == 1) {
                                             //第一页
                                             [ProjectInfo deleteAllProjectInfoWithType:_projectClassInfo.cid];
                                         }
                                         NSArray *projects = resultInfo;
                                         if (projects.count > 0) {
                                             
                                             for (IProjectInfo *iProjectInfo in projects) {
                                                 [ProjectInfo createProjectInfoWith:iProjectInfo withType:_projectClassInfo.cid];
                                             }
                                         }
                                         
                                         //获取数据
                                         self.datasource = [ProjectInfo allMyProjectInfoWithType:_projectClassInfo.cid];
                                         
                                         [self.tableView reloadData];
                                         
                                         //设置是否可以下拉刷新
                                         if ([resultInfo count] != _pageSize) {
                                             self.tableView.footer.hidden = YES;
                                         }else{
                                             self.tableView.footer.hidden = NO;
                                         }
                                         
//                                         if(_datasource.count == 0){
//                                             [self.tableView addSubview:self.notView];
//                                             [self.tableView sendSubviewToBack:self.notView];
//                                         }else{
//                                             [_notView removeFromSuperview];
//                                         }
                                     } Failed:^(NSError *error) {
                                         [self.tableView.header endRefreshing];
                                         [self.tableView.footer endRefreshing];
                                     }];
}

- (void)loadMoreDataArray
{
    _pageIndex++;
    [self loadInitData];
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

#pragma mark - UITableView Datasource&Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datasource.count ? : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //评论列表
    if (_datasource.count > 0) {
        //项目列表
        static NSString *cellIdentifier = @"ProjectClass_View_Cell";
        ProjectInfoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ProjectInfoViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.projectInfo = _datasource[indexPath.row];
        WEAKSELF
        [cell setUserInfoBlock:^(id userInfo){
            [weakSelf lookCreateUserInfo:userInfo];
        }];
        return cell;
    }else{
        static NSString *cellIdentifier = @"ProjectClass_No_View_Cell";
        NoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[NoteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.noteInfo = @"该项目集暂无项目";
        cell.hidBottomLine = YES;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //项目列表
    if (_datasource.count > 0) {
        ProjectInfo *projectInfo = _datasource[indexPath.row];
        if (projectInfo) {
            ProjectDetailsViewController *projectDetailVC = [[ProjectDetailsViewController alloc] initWithProjectInfo:projectInfo];
            [self.navigationController pushViewController:projectDetailVC animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_datasource.count > 0) {
        return 70.f;
    }else{
        return _tableView.height - kHeaderImageHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_datasource.count > 0) {
        return 70.f;
    }else{
        return _tableView.height - kHeaderImageHeight;
    }
}

@end
