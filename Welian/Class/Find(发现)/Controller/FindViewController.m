//
//  FindViewController.m
//  Welian
//
//  Created by dong on 14-9-10.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "FindViewController.h"
#import "UserCardController.h"
#import "TOWebViewController.h"
#import "MainViewController.h"
#import "ProjectListViewController.h"
#import "ProjectMainViewController.h"
#import "InvestorsListController.h"
#import "ActivityListViewController.h"
#import "NewsListViewController.h"

#import "BadgeBaseCell.h"
#import "HYBLoopScrollView.h"
#import "BannerModel.h"
#import "ProjectDetailsViewController.h"
#import "ActivityDetailInfoViewController.h"
#import "ProjcetClassViewController.h"

#define kBannerHeight 135.f

@interface FindViewController () <UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_data;
}
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) HYBLoopScrollView *loopView;

@end

static NSString *CellIdentifier = @"BadgeBaseCellid";
@implementation FindViewController

- (HYBLoopScrollView *)loopView
{
    if (_loopView == nil) {
        _loopView = [[HYBLoopScrollView alloc] initWithFrame:CGRectMake(0, 0, SuperSize.width, SuperSize.width*270/640)];
        _loopView.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.9 alpha:0.7];
        _loopView.pageControl.currentPageIndicatorTintColor = KBasesColor;
        _loopView.timeInterval = 5.0;
    }
    return _loopView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[MainViewController sharedMainViewController] loadNewStustupdata];
    if (self.tableView) {
        [self.tableView reloadData];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [KNSNotification addObserver:self selector:@selector(reloadNewactivit) name:KNewactivitNotif object:nil];
    [KNSNotification addObserver:self selector:@selector(reloadProject) name:KProjectstateNotif object:nil];
    // 加载页面
    [self loadUIview];
    // 加载数据
    [self loadLoopViewData];
    [self loadDatalist];
}


// 刷新活动角标
- (void)reloadNewactivit
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}
//刷新项目的角标
- (void)reloadProject
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)reloadToutiao
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)reloadInvestor
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self.tableView shouldPositionParallaxHeader];
//}

// 加载发现头部
- (void)loadLoopViewData
{
  YTKKeyValueItem *item = [[WLDataDBTool sharedService] getYTKKeyValueItemById:KBannerDataTableName fromTable:KBannerDataTableName];
    NSArray *bannerArray = item.itemObject;
    [self showBannerViewWith:bannerArray];
    WEAKSELF
    [WeLianClient adBannerWithSuccess:^(id resultInfo) {
        DLog(@"%@",resultInfo);
        [[WLDataDBTool sharedService] putObject:resultInfo withId:KBannerDataTableName intoTable:KBannerDataTableName];
        [weakSelf showBannerViewWith:resultInfo];
        
    } Failed:^(NSError *error) {
        
    }];
}

- (void)showBannerViewWith:(NSArray *)bArray
{
    NSMutableArray *bannerArray = [NSMutableArray array];
    NSMutableArray *images = [NSMutableArray array];
    for (NSDictionary *bannerDic in bArray) {
        BannerModel *bModel = [BannerModel objectWithDict:bannerDic];
        [bannerArray addObject:bModel];
        [images addObject:bModel.photo];
    }
    if (bannerArray.count) {
        [self.loopView setImageUrls:images];
        [self.tableView setTableHeaderView:self.loopView];
        WEAKSELF
        self.loopView.didSelectItemBlock = ^(NSInteger atIndex, HYBLoadImageView *sender) {
            BannerModel *baModel = bannerArray[atIndex];
            [weakSelf pushBannerControllerWithBanner:baModel];
        };
    }else{
        
    }
}


// 通过广告位跳转到指定页
- (void)pushBannerControllerWithBanner:(BannerModel *)bannerM
{
    // 广告类型：0 网页，1 项目，2 活动，3 项目集合
    NSInteger type = bannerM.type.integerValue;
    switch (type) {
        case 0:
        {
            TOWebViewController *webVC = [[TOWebViewController alloc] initWithURLString:bannerM.url];
            webVC.navigationButtonsHidden = NO;//隐藏底部操作栏目
            webVC.showRightShareBtn = YES;//现实右上角分享按钮
            [self.navigationController pushViewController:webVC animated:YES];
        }
            break;
        case 1:
        {
            ProjectDetailsViewController *projectVc = [[ProjectDetailsViewController alloc] initWithProjectPid:bannerM.bid];
            [self.navigationController pushViewController:projectVc animated:YES];
        }
            break;
        case 2:
        {
            ActivityDetailInfoViewController *activityInfoVC = [[ActivityDetailInfoViewController alloc] initWIthActivityId:bannerM.bid];
            [self.navigationController pushViewController:activityInfoVC animated:YES];
        }
            break;
        case 3:
        {
            //项目集
            ProjectClassInfo *projectInfo = [ProjectClassInfo createProjectClassInfoWith:bannerM.classification];
            ProjcetClassViewController *projcetClassVC = [[ProjcetClassViewController alloc] initWithProjectClassInfo:projectInfo];
            [self.navigationController pushViewController:projcetClassVC animated:YES];
        }
            break;
        default:
            break;
    }
}



#pragma mark - 加载数据
- (void)loadDatalist
{
    // 1.获得路径
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Findplist" withExtension:@"plist"];
    // 2.读取数据
    _data = [NSArray arrayWithContentsOfURL:url];
}

#pragma mark - 加载页面
- (void)loadUIview
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSectionFooterHeight:0.0];
    [self.tableView  setSectionHeaderHeight:15.0];
    [self.tableView registerNib:[UINib nibWithNibName:@"BadgeBaseCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    [self.view addSubview:self.tableView];
}

#pragma mark - tableView 代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_data[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KTableRowH;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BadgeBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // 1.取出这行对应的字典数据
    NSDictionary *dict = _data[indexPath.section][indexPath.row];
    // 2.设置文字
    cell.titLabel.text = dict[@"name"];
    [cell.iconImage setImage:[UIImage imageNamed:dict[@"icon"]]];
    LogInUser *meinfo = [LogInUser getCurrentLoginUser];
    
    cell.deputLabel.text = @"";
    cell.deputLabel.hidden = YES;
    if (indexPath.section==0) {
        switch (indexPath.row) {
            case 0:
            {
                [cell.deputLabel setHidden:!meinfo.toutiaocount.integerValue];
                [cell.badgeImage setHidden:!meinfo.istoutiaobadge.boolValue];
                if (meinfo.toutiaocount.integerValue > 0) {
                    [cell.deputLabel setHidden:NO];
                    [cell.deputLabel setAttributedText:[NSObject getAttributedInfoString:[NSString stringWithFormat:@"您有%@篇文章未读",meinfo.toutiaocount.stringValue]
                                                                               searchStr:meinfo.toutiaocount.stringValue
                                                                                   color:KBlueTextColor
                                                                                    font:WLFONTBLOD(15)]];
                }
                [cell.badgeImage setHidden:!meinfo.istoutiaobadge.boolValue];
            }
                break;
            case 1:
            {
                if (meinfo.activecount.integerValue > 0) {
                    [cell.deputLabel setHidden:NO];
                    [cell.deputLabel setAttributedText:[NSObject getAttributedInfoString:[NSString stringWithFormat:@"有%@个活动可以参与",meinfo.activecount.stringValue]
                                                                           searchStr:meinfo.activecount.stringValue
                                                                    color:KBlueTextColor
                                                                                font:WLFONTBLOD(15)]];
                }
                [cell.badgeImage setHidden:!meinfo.isactivebadge.boolValue];
            }
                break;
            default:
            {
                [cell.deputLabel setHidden:YES];
                [cell.badgeImage setHidden:YES];
            }
                break;
        }
    }else if (indexPath.section==1){
        if (indexPath.row==0) {
            [cell.deputLabel setHidden:!meinfo.projectcount.integerValue];
            [cell.badgeImage setHidden:!meinfo.isprojectbadge.boolValue];
            if (meinfo.projectcount.integerValue) {
                [cell.deputLabel setAttributedText:[NSObject getAttributedInfoString:[NSString stringWithFormat:@"有%@个创业项目",meinfo.projectcount.stringValue]
                                        searchStr:meinfo.projectcount.stringValue
                                            color:KBlueTextColor
                                            font:WLFONTBLOD(15)]];
            }
        }else if (indexPath.row==1){
            [cell.deputLabel setHidden:!meinfo.investorcount.boolValue];
            [cell.badgeImage setHidden:!meinfo.isfindinvestorbadge.boolValue];
            if (meinfo.investorcount.integerValue) {
                [cell.deputLabel setAttributedText:[NSObject getAttributedInfoString:[NSString stringWithFormat:@"%@位已认证投资人",meinfo.investorcount.stringValue]
                                                                           searchStr:meinfo.investorcount.stringValue
                                                                               color:KBlueTextColor
                                                                                font:WLFONTBLOD(15)]];
            }
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    // 观点  虎嗅网
//                    TOWebViewController *webVC = [[TOWebViewController alloc] initWithURLString:@"http://m.huxiu.com/"];
//                    webVC.navigationButtonsHidden = NO;//隐藏底部操作栏目
//                    webVC.showRightShareBtn = YES;//现实右上角分享按钮
//                    [self.navigationController pushViewController:webVC animated:YES];
                    //创业头条
                    NewsListViewController *newListVC = [[NewsListViewController alloc] init];
                    [self.navigationController pushViewController:newListVC animated:YES];
                    
                    [LogInUser updateToutiaoBadge:NO];
                    [LogInUser updateToutiaoCount:@(0)];
                    [[MainViewController sharedMainViewController] loadNewStustupdata];
                    [self reloadToutiao];
                }
                    break;
                case 1:
                {
                    //活动列表
                    ActivityListViewController *activityListVC = [[ActivityListViewController alloc] init];
                    [self.navigationController pushViewController:activityListVC animated:YES];
                    
                    // 取消新活动角标
                    [LogInUser setUserIsactivebadge:NO];
                    [[MainViewController sharedMainViewController] loadNewStustupdata];
                    [self reloadNewactivit];
                }
                    break;
                case 2:
                {
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            if (indexPath.row==0) {
                //项目
//                ProjectListViewController *projectListVC = [[ProjectListViewController alloc] init];
//                [self.navigationController pushViewController:projectListVC animated:YES];
                ProjectMainViewController *projectMainVC = [[ProjectMainViewController alloc] init];
                [self.navigationController pushViewController:projectMainVC animated:YES];
                
                // 取消新活动角标
                [LogInUser setUserIsProjectBadge:NO];
                [[MainViewController sharedMainViewController] loadNewStustupdata];
                [self reloadProject];
            }else if (indexPath.row==1){
                InvestorsListController *investorListVC = [[InvestorsListController alloc] init];
                [investorListVC setTitle:@"投资人"];
                [self.navigationController pushViewController:investorListVC animated:YES];
                
                [LogInUser updateFindInvestorBadge:NO];
                [[MainViewController sharedMainViewController] loadNewStustupdata];
                [self reloadInvestor];
            }
        }
            break;
        case 2:
        {
            if (indexPath.row==0) {
                // 一起玩
                TOWebViewController *webVC = [[TOWebViewController alloc] initWithURLString:@"http://my.welian.com/play"];

                webVC.navigationButtonsHidden = NO;//隐藏底部操作栏目
                webVC.showRightShareBtn = YES;//现实右上角分享按钮
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }
            break;
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
