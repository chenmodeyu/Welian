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

@interface NewsListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (assign,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSArray *datasource;
@property (assign,nonatomic) NSInteger pageIndex;
@property (assign,nonatomic) NSInteger pageSize;

@end

@implementation NewsListViewController

- (NSString *)title
{
    return @"创业头条";
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
    self.pageSize = KCellConut;
    
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
    
    //下拉刷新
    [_tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(loadNewDataInfo)];
    
    //上提加载更多
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    [_tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataInfo)];
    // 隐藏当前的上拉刷新控件
    _tableView.footer.hidden = YES;
    
    //初始化数据
    [_tableView.header beginRefreshing];
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
    //type == 0 ，取time时间后最新更新的.time 为客户端保存的最新的一条的头条的时间，
    //type==1 ，取time时间更新前的数量，time 为客户端保存的最早的一条头条的时间
    [WeLianClient getTouTiaoListWithTime:@"2015-05-19 19:21"
                                    Type:@(1)
                                    Size:@(30)
                                 Success:^(id resultInfo) {
                                     [_tableView.header endRefreshing];
                                     [_tableView.footer endRefreshing];
                                     
                                     self.datasource = resultInfo;
                                     [_tableView reloadData];
                                     
                                     if ([resultInfo count] == _pageSize) {
                                         _tableView.footer.hidden = NO;
                                     }else{
                                         _tableView.footer.hidden = YES;
                                     }
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

//下拉刷新数据
- (void)loadNewDataInfo
{
    [self initData];
}

//上拉加载更多数据
- (void)loadMoreDataInfo
{
    
}

@end
