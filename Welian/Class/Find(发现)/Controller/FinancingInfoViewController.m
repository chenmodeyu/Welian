//
//  FinancingInfoViewController.m
//  Welian
//
//  Created by weLian on 15/5/20.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "FinancingInfoViewController.h"
#import "LookBPFileViewController.h"
#import "WebViewLookBPViewController.h"

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
        self.datasource = _iProjectDetailInfo.bp.bpid != nil ? @[_iProjectDetailInfo.bp] : nil;
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

#pragma mark - Private
//请求查看BP
- (void)getBPBtnClicked:(NSIndexPath *)indexPath
{
    [UIAlertView bk_showAlertViewWithTitle:@""
                                   message:@"确定查看该项目的BP？"
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@[@"发送请求"]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if (buttonIndex == 0) {
                                           return;
                                       }else{
                                           [self getBPInfo:indexPath];
                                       }
                                   }];
}

//向创业者索要BP
- (void)getBPInfo:(NSIndexPath *)indexPath
{
    //向创业者索要BP
    [WLHUDView showHUDWithStr:@"请求发送中..." dim:NO];
    [WeLianClient investorRequiredWithPid:_iProjectDetailInfo.pid
                                  Success:^(id resultInfo) {
                                      [WLHUDView hiddenHud];
                                      //发送成功
                                      [UIAlertView bk_showAlertViewWithTitle:@""
                                                                     message:@"查看BP请求发送成功，请等待回复！"
                                                           cancelButtonTitle:@"知道了"
                                                           otherButtonTitles:nil
                                                                     handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                         
                                                                     }];
                                  } Failed:^(NSError *error) {
                                      if (error) {
                                          [WLHUDView showErrorHUD:error.localizedDescription];
                                      }else{
                                          [WLHUDView showErrorHUD:@"发送请求失败，请重试！"];
                                      }
                                  }];
}

- (void)downloadBPAndLook:(NSString *)url
{
    //下载照片
    NSString *fileName = [url lastPathComponent];
    NSString *folder = [[ResManager userResourcePath] stringByAppendingPathComponent:@"ChatDocument/ProjectBP/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder]) {
        DLog(@"创建home cover 目录!");
        [[NSFileManager defaultManager] createDirectoryAtPath:folder
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    folder = [folder stringByAppendingPathComponent:fileName];
    
    //删除文件
    if ([ResManager fileExistByPath:folder]) {
        //本地存在的话，直接查看
        LookBPFileViewController *lookBPFileVC = [[LookBPFileViewController alloc] initWithBpPath:url];
        [self.navigationController pushViewController:lookBPFileVC animated:YES];
    }else{
        WebViewLookBPViewController *webLookVC = [[WebViewLookBPViewController alloc] initWithBpPath:url];
        [self.navigationController pushViewController:webLookVC animated:YES];
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
        static NSString *cellIdentifier = @"FinancingInfo_List_View_Cell";
        ProjectBPViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ProjectBPViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        IProjectBPModel *bpModel = _datasource[indexPath.row];
        cell.fineName = bpModel.bpname;// @"微链商业计划书.pdf";
        if (_iProjectDetailInfo.user.uid.integerValue == [LogInUser getCurrentLoginUser].uid.integerValue) {
            //自己的项目
            cell.showGetBPBtn = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            cell.showGetBPBtn = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            WEAKSELF
            [cell setBlock:^(void){
                //请求查看BP
                [weakSelf getBPBtnClicked:indexPath];
            }];
        }
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
    if (_iProjectDetailInfo.user.uid.integerValue == [LogInUser getCurrentLoginUser].uid.integerValue) {
        //自己的项目
        if (_datasource.count > 0) {
            IProjectBPModel *bpModel = _datasource[indexPath.row];
            [WeLianClient investorDownloadWithPid:bpModel.bpid
                                          Success:^(id resultInfo) {
                                              //BP地址url
                                              NSString *url = resultInfo[@"url"];
                                              [self downloadBPAndLook:url];
                                          } Failed:^(NSError *error) {
                                              if (error) {
                                                  [WLHUDView showErrorHUD:error.localizedDescription];
                                              }else{
                                                  [WLHUDView showErrorHUD:@"网络连接失败，请重试！"];
                                              }
                                          }];
        }
    }
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
