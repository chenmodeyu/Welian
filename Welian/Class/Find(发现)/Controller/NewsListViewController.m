//
//  NewsListViewController.m
//  Welian
//
//  Created by weLian on 15/5/19.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "NewsListViewController.h"
#import "NewsListViewCell.h"
#import "TOWebViewController.h"
#import "NotstringView.h"

@interface NewsListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (assign,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSArray *datasource;
@property (assign,nonatomic) NSInteger pageIndex;
@property (assign,nonatomic) NSInteger pageSize;
@property (strong,nonatomic) NotstringView *notView;

@end

@implementation NewsListViewController

- (void)dealloc
{
    _datasource = nil;
    _notView = nil;
}

- (NSString *)title
{
    return @"创业头条";
}

- (NotstringView *)notView
{
    if (!_notView) {
        _notView = [[NotstringView alloc] initWithFrame:self.tableView.frame withTitleStr:@"暂无创业头条"];
    }
    return _notView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //tableview头部距离问题
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //背景色
    self.view.backgroundColor = KBgLightGrayColor;
    self.pageIndex = 1;
    self.pageSize = KCellConut;
    self.datasource = [TouTiaoInfo getAllTouTiaos];
    
    //添加创建活动按钮
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建活动" style:UIBarButtonItemStyleDone target:self action:@selector(createActivity)];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f,ViewCtrlTopBarHeight,self.view.width,self.view.height - ViewCtrlTopBarHeight)];
    tableView.backgroundColor = KBgLightGrayColor;
    tableView.dataSource = self;
    tableView.delegate = self;
    //隐藏表格分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    //    [tableView setDebug:YES];
    
    //设置底部空白区域
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 30.f)];
    footerView.backgroundColor = KBgLightGrayColor;
    [tableView setTableFooterView:footerView];
    
    //下拉刷新
    [_tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewDataInfo)];
    
    //上提加载更多
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    [_tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataInfo)];
    // 隐藏当前的上拉刷新控件
    _tableView.footer.hidden = YES;
    
    if (_datasource.count > 0) {
        //默认加载数据
        [self loadNewDataInfo];
    }else{
        //下拉刷新数据
        [_tableView.header beginRefreshing];
    }
}

#pragma mark - UITableView Datasource&Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"News_List_View_Cell";
    
    NewsListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[NewsListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.infoData = _datasource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ITouTiaoModel *touTiao = _datasource[indexPath.row];
    TOWebViewController *webVC = [[TOWebViewController alloc] initWithURLString:touTiao.url];
    webVC.navigationButtonsHidden = NO;//隐藏底部操作栏目
    webVC.showRightShareBtn = YES;//现实右上角分享按钮
    webVC.isTouTiao = YES;
//    webVC.showPageTitles = NO;//隐藏标题
    [self.navigationController pushViewController:webVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NewsListViewCell configureWithNewInfo:_datasource[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NewsListViewCell configureWithNewInfo:_datasource[indexPath.row]];
}


#pragma mark - Private
//初始化数据
- (void)initData
{
    [WeLianClient getTouTiaoListWithPage:@(_pageIndex)
                                    Size:@(_pageSize)
                                 Success:^(id resultInfo) {
                                     if (_pageIndex == 1) {
                                         //隐性删除数据库数据
                                         [TouTiaoInfo deleteAllTouTiaoInfos];
                                     }
                                     
                                     //异步保存数据到数据库
                                     if ([resultInfo count] > 0) {
                                         [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                             NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"isNow",@(YES)];
                                             LogInUser *loginUser = [LogInUser MR_findFirstWithPredicate:pre inContext:localContext];
                                             if (!loginUser) {
                                                 return;
                                             }
                                             for (ITouTiaoModel *iTouTiaoModel in resultInfo) {
                                                 NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"touTiaoId",iTouTiaoModel.touTiaoId];
                                                 TouTiaoInfo *touTiaoInfo = [TouTiaoInfo MR_findFirstWithPredicate:pre inContext:localContext];
                                                 if (!touTiaoInfo) {
                                                     touTiaoInfo = [TouTiaoInfo MR_createEntityInContext:localContext];
                                                 }
                                                 touTiaoInfo.touTiaoId = iTouTiaoModel.touTiaoId;
                                                 touTiaoInfo.author = iTouTiaoModel.author;
                                                 touTiaoInfo.created = [iTouTiaoModel.created dateFromNormalStringNoss];
                                                 touTiaoInfo.intro = iTouTiaoModel.intro;
                                                 touTiaoInfo.photo = iTouTiaoModel.photo;
                                                 touTiaoInfo.title = iTouTiaoModel.title;
                                                 touTiaoInfo.url = iTouTiaoModel.url;
                                                 touTiaoInfo.isShow = @(YES);
                                                 
                                                 [loginUser addRsTouTiaoInfosObject:touTiaoInfo];
                                             }
                                         } completion:^(BOOL contextDidSave, NSError *error) {
                                             [self updateDataAndUIWithResultInfo:resultInfo];
                                         }];
                                     }else{
                                         [self updateDataAndUIWithResultInfo:resultInfo];
                                     }
                                     
//                                     for (ITouTiaoModel *iTouTiaoModel in resultInfo) {
//                                         [TouTiaoInfo createTouTiaoInfoWith:iTouTiaoModel];
//                                     }
//                                     
//                                     self.datasource = [TouTiaoInfo getAllTouTiaos];
//                                     [_tableView reloadData];
//                                     
//                                     //是否显示上拉加载更多
//                                     if ([resultInfo count] == _pageSize) {
//                                         _tableView.footer.hidden = NO;
//                                     }else{
//                                         _tableView.footer.hidden = YES;
//                                     }
//                                     
//                                     //提醒信息显示
//                                     if(_datasource.count == 0){
//                                         [_tableView addSubview:self.notView];
//                                         [_tableView sendSubviewToBack:self.notView];
//                                     }else{
//                                         [_notView removeFromSuperview];
//                                     }
                                 } Failed:^(NSError *error) {
                                     [_tableView.header endRefreshing];
                                     [_tableView.footer endRefreshing];
                                     
                                     if (error) {
                                         [WLHUDView showErrorHUD:error.localizedDescription];
                                     }else{
                                         [WLHUDView showErrorHUD:@"网络无法连接，请重试！"];
                                     }
                                     DLog(@"getTouTiaoList error:%@",error.localizedDescription);
                                 }];
}

- (void)updateDataAndUIWithResultInfo:(id)resultInfo
{
    [_tableView.header endRefreshing];
    [_tableView.footer endRefreshing];
    
    self.datasource = [TouTiaoInfo getAllTouTiaos];
    [_tableView reloadData];
    
    //是否显示上拉加载更多
    if ([resultInfo count] == _pageSize) {
        _tableView.footer.hidden = NO;
    }else{
        _tableView.footer.hidden = YES;
    }
    
    //提醒信息显示
    if(_datasource.count == 0){
        [_tableView addSubview:self.notView];
        [_tableView sendSubviewToBack:self.notView];
    }else{
        [_notView removeFromSuperview];
    }
}

//下拉刷新数据
- (void)loadNewDataInfo
{
    _pageIndex = 1;
    [self initData];
}

//上拉加载更多数据
- (void)loadMoreDataInfo
{
    self.pageIndex = _pageIndex + 1;
    [self initData];
}

@end
