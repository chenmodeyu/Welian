//
//  FinancingInfoViewController.m
//  Welian
//
//  Created by weLian on 15/5/20.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "FinancingInfoViewController.h"

#import "FinancingInfoView.h"
#import "NoteMsgView.h"
#import "NoteTableViewCell.h"
#import "ProjectBPViewCell.h"

#define kNotViewHeight 40.f

@interface FinancingInfoViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (assign,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSArray *datasource;
@property (strong,nonatomic) IProjectDetailInfo *iProjectDetailInfo;

@end

@implementation FinancingInfoViewController

- (NSString *)title
{
    return @"融资信息";
}

- (instancetype)initWithProjectInfo:(IProjectDetailInfo *)iProjectDetailInfo
{
    self = [super init];
    if (self) {
        self.iProjectDetailInfo = iProjectDetailInfo;
        self.datasource = @[@""];
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
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f,ViewCtrlTopBarHeight,self.view.width,self.view.height - ViewCtrlTopBarHeight)];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    //隐藏表格分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    //    [tableView setDebug:YES];
    
    //设置头部内容
    CGFloat headerHeight = [FinancingInfoView configureWithIProjectInfo:_iProjectDetailInfo];
    FinancingInfoView *financingInfoView = [[FinancingInfoView alloc] initWithFrame:Rect(0, 0, _tableView.width, headerHeight)];
    financingInfoView.iProjectDetailInfo = _iProjectDetailInfo;
    financingInfoView.layer.borderColorFromUIColor = kNormalLineColor;
    financingInfoView.layer.borderWidths = @"{0,0,0.5,0}";
    [_tableView setTableHeaderView:financingInfoView];
    
    //设置提醒
    NoteMsgView *noteView = [[NoteMsgView alloc] initWithFrame:Rect(0, 0, _tableView.width, kNotViewHeight)];
    noteView.noteInfo = @"BP非公开文件，如果想要查看，可发送请求";
    [_tableView setTableFooterView:noteView];
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
        static NSString *cellIdentifier = @"FinancingInfo_List_View_Cell";
        ProjectBPViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ProjectBPViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.fineName = @"微链商业计划书.pdf";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }else{
        static NSString *cellIdentifier = @"FinancingInfo_Not_View_Cell";
        NoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[NoteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.noteInfo = @"该项目暂未上传BP文件";
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
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
    return 43.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 43.f;
}

@end
