//
//  ProjectPostDetailInfoViewController.m
//  Welian
//
//  Created by weLian on 15/5/20.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectPostDetailInfoViewController.h"

#import "FinancingInfoView.h"
#import "NoteMsgView.h"
#import "NoteTableViewCell.h"
#import "ProjectBPViewCell.h"

#define ToolBarHeight 50.f
#define kOperateButtonHeight 35.f
#define kmarginLeft 15.f
#define kNotViewHeight 30.f

@interface ProjectPostDetailInfoViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (assign,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSArray *datasource;
@property (strong,nonatomic) IProjectDetailInfo *iProjectDetailInfo;

@end

@implementation ProjectPostDetailInfoViewController

- (NSString *)title
{
    return @"项目信息";
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
    
    //添加创建活动按钮
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建活动" style:UIBarButtonItemStyleDone target:self action:@selector(createActivity)];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f,ViewCtrlTopBarHeight,self.view.width,self.view.height - ViewCtrlTopBarHeight - ToolBarHeight - kNotViewHeight)];
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
    NoteMsgView *noteView = [[NoteMsgView alloc] initWithFrame:Rect(0, tableView.bottom, self.view.width, kNotViewHeight)];
    noteView.noteInfo = @"创业不易，每一次项目的投递，都是一次等待!";
    [self.view addSubview:noteView];
    
    //设置底部操作栏
    UIView *operateToolView = [[UIView alloc] initWithFrame:CGRectMake(0.f, noteView.bottom, self.view.width, ToolBarHeight)];
    operateToolView.backgroundColor = RGB(247.f, 247.f, 247.f);
    operateToolView.layer.borderColorFromUIColor = kNormalTextColor;
    operateToolView.layer.borderWidths = @"{0.6,0,0,0}";
    [self.view addSubview:operateToolView];
    [self.view bringSubviewToFront:operateToolView];
    
    //不感兴趣
    CGFloat btnWidth = (self.view.width - kmarginLeft * 3.f) / 2.f;
    UIButton *noLikeBtn = [UIView getBtnWithTitle:@"不感兴趣" image:nil];
    noLikeBtn.layer.borderColor = KBlueTextColor.CGColor;
    noLikeBtn.layer.borderWidth = .7f;
    noLikeBtn.size = CGSizeMake(btnWidth, kOperateButtonHeight);
    noLikeBtn.left = kmarginLeft;
    noLikeBtn.centerY = operateToolView.height / 2.f;
    [noLikeBtn setTitleColor:KBlueTextColor forState:UIControlStateNormal];
    [noLikeBtn addTarget:self action:@selector(noLikeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [operateToolView addSubview:noLikeBtn];
//    self.favorteBtn = favorteBtn;
    
    //立即约谈
    UIButton *talkNowBtn = [UIView getBtnWithTitle:@"立即约谈" image:nil];
    talkNowBtn.size = CGSizeMake(btnWidth, kOperateButtonHeight);
    talkNowBtn.right = operateToolView.width - kmarginLeft;
    talkNowBtn.centerY = operateToolView.height / 2.f;
    talkNowBtn.backgroundColor = KBlueTextColor;
    [talkNowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [talkNowBtn addTarget:self action:@selector(talkNowBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [operateToolView addSubview:talkNowBtn];
}

#pragma mark - Private
//不感兴趣
- (void)noLikeBtnClicked:(UIButton *)sender
{
    
}

//立即约谈
- (void)talkNowBtnClicked:(UIButton *)sender
{
    
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
