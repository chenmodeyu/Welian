//
//  ActivityDetailInfoViewController.m
//  Welian
//
//  Created by weLian on 15/2/7.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ActivityDetailInfoViewController.h"
#import "ActivityOrderInfoViewController.h"
#import "ActivityMapViewController.h"
#import "ActivityUserListViewController.h"
#import "TOWebViewController.h"
#import "ShareFriendsController.h"
#import "NavViewController.h"
#import "PublishStatusController.h"
#import "ActivitySubInfoViewController.h"

#import "MessageKeyboardView.h"
#import "ActivityCustomViewCell.h"
#import "ActivityInfoViewCell.h"
#import "ActivityUserViewCell.h"
#import "ActivityTicketView.h"
#import "WLActivityView.h"
#import "CardAlertView.h"

#import "ShareEngine.h"
#import "SEImageCache.h"
#import "CardStatuModel.h"

#define kHeaderImageHeight 238.f
#define kTableViewHeaderHeight 45.f
#define kOperateButtonHeight 35.f
#define kmarginLeft 10.f

@interface ActivityDetailInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (assign,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSArray *datasource;

@property (assign,nonatomic) UIButton *favorteBtn;
@property (assign,nonatomic) UIButton *joinBtn;
@property (assign,nonatomic) ActivityTicketView *activityTicketView;
@property (strong,nonatomic) ActivityInfo *activityInfo;
@property (strong,nonatomic) NSNumber *activityId;

@end

@implementation ActivityDetailInfoViewController

- (void)dealloc
{
    _datasource = nil;
    _activityInfo = nil;
    [KNSNotification removeObserver:self];
}

- (NSString *)title
{
    return @"活动详情";
}

- (instancetype)initWithActivityInfo:(ActivityInfo *)activityInfo
{
    self = [super init];
    if (self) {
        self.showCustomNavHeader = YES;
        self.activityInfo = activityInfo;
        self.activityId = _activityInfo.activeid;
        [KNSNotification addObserver:self selector:@selector(updatePayJoined) name:kNeedReloadActivityUI object:nil];
    }
    return self;
}

- (instancetype)initWIthActivityId:(NSNumber *)activityId
{
    self = [super init];
    if (self) {
        self.showCustomNavHeader = YES;
        self.activityId = activityId;
        
        [KNSNotification addObserver:self selector:@selector(updatePayJoined) name:kNeedReloadActivityUI object:nil];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //代理置空，否则会闪退 设置手势滑动返回
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//    }
}

//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    //开启滑动手势
//    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        navigationController.interactivePopGestureRecognizer.enabled = YES;
//    }else{
//        navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollViewDidScroll:_tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //设置push到当前VC
    self.isJoindThisVC = YES;
    
    [self scrollViewDidScroll:_tableView];
    
    //开启iOS7的滑动返回效果
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        //只有在二级页面生效
//        if ([self.navigationController.viewControllers count] > 1) {
//            self.navigationController.interactivePopGestureRecognizer.delegate = self;
//        }
//    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    [super scrollViewDidScroll:scrollView];
//    [self.tableView shouldPositionParallaxHeader];
    
    CGFloat offsetY = scrollView.contentOffset.y;
    UIColor *color = kNavBgColor;
    if (offsetY > kHeaderViewHeight/2) {
        CGFloat alpha = 1 - ((kHeaderViewHeight/2 + 64 - offsetY) / 64);
        self.navHeaderView.backgroundColor = [color colorWithAlphaComponent:alpha];
        //        [self.navigationController.navigationBar useBackgroundColor:[color colorWithAlphaComponent:alpha]];
    } else {
        self.navHeaderView.backgroundColor = [color colorWithAlphaComponent:0];
        //        [self.navigationController.navigationBar useBackgroundColor:[color colorWithAlphaComponent:0]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //tableview头部距离问题
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //设置头部背景透明
//    [self.navigationController.navigationBar useBackgroundColor:[UIColor clearColor]];
    
    //设置左侧按钮
    [self.navHeaderView setLeftBtnTitle:nil LeftBtnImage:[UIImage imageNamed:@"activity_back"]];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:Rect(0.f,0.f,self.view.width,self.view.height - toolBarHeight)];
    tableView.dataSource = self;
    tableView.delegate = self;
    //隐藏表格分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    [self.view sendSubviewToBack:tableView];
    self.tableView = tableView;
//    [tableView registerNib:[UINib nibWithNibName:@"NoCommentCell" bundle:nil] forCellReuseIdentifier:noCommentCell];
    
    //设置底部操作栏
    UIView *operateToolView = [[UIView alloc] initWithFrame:CGRectMake(0.f, tableView.bottom, self.view.width, toolBarHeight)];
    operateToolView.backgroundColor = RGB(247.f, 247.f, 247.f);
    operateToolView.layer.borderColorFromUIColor = RGB(231.f, 231.f, 231.f);
    operateToolView.layer.borderWidths = @"{0.6,0,0,0}";
    [self.view addSubview:operateToolView];
    
    //收藏
    UIButton *favorteBtn = [UIView getBtnWithTitle:@"收藏" image:[UIImage imageNamed:@"me_mywriten_shoucang"]];
    favorteBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    favorteBtn.layer.borderWidth = .7f;
    favorteBtn.size = CGSizeMake(108.f, kOperateButtonHeight);
    favorteBtn.left = kmarginLeft;
    favorteBtn.centerY = operateToolView.height / 2.f;
    [favorteBtn addTarget:self action:@selector(favorteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [operateToolView addSubview:favorteBtn];
    self.favorteBtn = favorteBtn;
    
    //我要报名
    UIButton *joinBtn = [UIView getBtnWithTitle:@"我要购票" image:nil];
    joinBtn.size = CGSizeMake(self.view.width - favorteBtn.right - kmarginLeft * 2.f, kOperateButtonHeight);
    joinBtn.right = operateToolView.width - kmarginLeft;
    joinBtn.centerY = operateToolView.height / 2.f;
    joinBtn.backgroundColor = RGB(52.f, 115.f, 185.f);
    [joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [joinBtn addTarget:self action:@selector(joinBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [operateToolView addSubview:joinBtn];
    self.joinBtn = joinBtn;
    
    //购票页面
    ActivityTicketView *activityTicketView = [[ActivityTicketView alloc] initWithFrame:self.view.bounds];
    activityTicketView.hidden = YES;
    [[[UIApplication sharedApplication] keyWindow] addSubview:activityTicketView];
    self.activityTicketView = activityTicketView;
    
    if (_activityInfo) {
        [self initActivityUIInfo];
        
        //检测分享按钮是否显示
        [self checkShareBtn];
        
        [self checkFavorteStatus];
        [self checkOperateBtnStatus];
    }
    
    //获取详情信息
    [self initData];
    
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 400)];
//    view.backgroundColor = [UIColor blueColor];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((300-80)/2.f, (400-30)/2.f, 80, 30)];
//    label.font = [UIFont systemFontOfSize:14];
//    label.textColor = [UIColor whiteColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.text = @"第一页";
//    
//    [view addSubview:label];
//    [self.scrollView addSubview:self.view];
    //下拉刷新
//    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(initData)];
//    [self.tableView.header beginRefreshing];
}

#pragma mark - UITableView Datasource&Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (_activityInfo) {
            return _activityInfo.sponsor.length > 0 ? 5.f : 4.f;
        }else{
            return 0;
        }
    }else{
        return _datasource.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, self.view.width, kTableViewHeaderHeight)];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.layer.borderColorFromUIColor = RGB(231.f, 231.f, 231.f);
    headerView.layer.borderWidths = @"{0,0,0.6,0}";
    
    UIView *topBgView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, headerView.width, 15.f)];
    topBgView.backgroundColor = RGB(236.f, 238.f, 241.f);
    [headerView addSubview:topBgView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = kNormal14Font;
    titleLabel.textColor = RGB(125.f, 125.f, 125.f);
    titleLabel.text = @"嘉宾";
    [titleLabel sizeToFit];
    titleLabel.left = 15.f;
    titleLabel.centerY = (headerView.height - topBgView.height) / 2.f + topBgView.height;
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 0){
        //微信联系人
        if (indexPath.row < 4) {
            static NSString *cellIdentifier = @"Activity_Custom_View_Cell";
            ActivityCustomViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[ActivityCustomViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
            switch (indexPath.row) {
                case 0:
                {
                    cell.showCustomInfo = NO;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.imageView.image = [UIImage imageNamed:@"discovery_activity_detail_time"];
                    cell.textLabel.text = [_activityInfo displayStartTimeInfo];
                }
                    break;
                case 1:
                {
                    cell.showCustomInfo = NO;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.imageView.image = [UIImage imageNamed:@"discovery_activity_detail_place"];
                    cell.textLabel.text = _activityInfo.address.length == 0 ? _activityInfo.city : _activityInfo.address;
                }
                    break;
                case 2:
                {
                    cell.showCustomInfo = YES;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.imageView.image = [UIImage imageNamed:@"discovery_activity_detail_people"];
                    
                    NSString *info = [NSString stringWithFormat:@"已报名%@人",_activityInfo.joined];
                    cell.textLabel.text = info;
                    [cell.textLabel setAttributedText:[NSObject getAttributedInfoString:info searchStr:_activityInfo.joined.stringValue color:KBlueTextColor font:kNormal14Font]];
                    
                    NSString *detailInfo = [NSString stringWithFormat:@"/限额%@人",_activityInfo.limited];
                    cell.detailTextLabel.text = detailInfo;
                    //设置特殊颜色
                    [cell.detailTextLabel setAttributedText:[NSObject getAttributedInfoString:detailInfo searchStr:_activityInfo.limited.stringValue color:KBlueTextColor font:kNormal14Font]];
                    //收费和免费中未现在人数
                    if (_activityInfo.type.integerValue == 1 || (_activityInfo.type.integerValue == 0 && _activityInfo.limited.integerValue == 0)) {
                        cell.detailTextLabel.hidden = YES;
                    }else{
                        cell.detailTextLabel.hidden = NO;
                    }
                }
                    break;
                case 3:
                {
                    //如果活动主办方存在
                    if(_activityInfo.sponsor.length > 0){
                        //活动主办方
                        cell.showCustomInfo = NO;
                        cell.accessoryType = UITableViewCellSelectionStyleNone;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.imageView.image = [UIImage imageNamed:@"discovery_activity_detail_zhubanfang"];
                        cell.textLabel.text = [NSString stringWithFormat:@"主办方：%@",_activityInfo.sponsor];
                    }else{
                        //活动详情
                        static NSString *cellIdentifier = @"Activity_Detail_Info_View_Cell";
                        ActivityInfoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                        if (!cell) {
                            cell = [[ActivityInfoViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
                        }
                        cell.layer.borderColorFromUIColor = RGB(231.f, 231.f, 231.f);
                        cell.layer.borderWidths = @"{0.6,0,0,0}";
                        
                        cell.textLabel.text = @"";
                        cell.detailTextLabel.text = [_activityInfo displayActivityInfo];
                        WEAKSELF
                        [cell setBlock:^(void){
                            [weakSelf showActivityDetailInfo];
                        }];
                        return cell;
                    }
                }
                    break;
                default:
                    break;
            }
            return cell;
        }else if (indexPath.row == 4){
            static NSString *cellIdentifier = @"Activity_Detail_Info_View_Cell";
            ActivityInfoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[ActivityInfoViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            }
            cell.layer.borderColorFromUIColor = RGB(231.f, 231.f, 231.f);
            cell.layer.borderWidths = @"{0.6,0,0,0}";
            
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = [_activityInfo displayActivityInfo];
//            WEAKSELF
//            [cell setBlock:^(void){
//                [weakSelf showActivityDetailInfo];
//            }];
             return cell;
        }else{
            return nil;
        }
    }else{
        static NSString *cellIdentifier = @"Activity_User_View_Cell";
        ActivityUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ActivityUserViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.indexPath = indexPath;
        cell.baseUser = _datasource[indexPath.row];
        cell.hidOperateBtn = YES;
        cell.hidBottomLine = YES;//隐藏分割线
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.section == 0){
        switch (indexPath.row) {
            case 1:
            {
                //地图
                NSString *cityAddress = [NSString stringWithFormat:@"%@-%@",_activityInfo.city,_activityInfo.address];
                DLog(@"toMapVC ----->%@",cityAddress);
                ActivityMapViewController *mapVC = [[ActivityMapViewController alloc] initWithAddress:_activityInfo.address city:_activityInfo.city];
                [self.navigationController pushViewController:mapVC animated:YES];
            }
                break;
            case 2:
            {
                //报名列表
                ActivityUserListViewController *userListVC = [[ActivityUserListViewController alloc] initWithStyle:UITableViewStylePlain ActiveInfo:_activityInfo];
                [self.navigationController pushViewController:userListVC animated:YES];
            }
                break;
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.f;
    }else{
        if (_datasource.count > 0) {
            return kTableViewHeaderHeight;
        }else{
            return 0.f;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return [ActivityCustomViewCell configureWithMsg:[_activityInfo displayStartTimeInfo] hasArrowImage:NO];
                break;
            case 1:
                return [ActivityCustomViewCell configureWithMsg:_activityInfo.address.length == 0 ? _activityInfo.city : _activityInfo.address hasArrowImage:YES];
                break;
            case 2:
                return [ActivityCustomViewCell configureWithMsg:[NSString stringWithFormat:@"已报名%@人/限额%@人",_activityInfo.joined,_activityInfo.limited] hasArrowImage:YES];
                break;
            case 3:
                //如果活动主办方存在
                if(_activityInfo.sponsor.length > 0){
                    return [ActivityCustomViewCell configureWithMsg:[NSString stringWithFormat:@"主办方：%@",_activityInfo.sponsor] hasArrowImage:NO];
                }else{
                    //活动详情
                    return [ActivityInfoViewCell configureWithTitle:@"" Msg:[_activityInfo displayActivityInfo]];//_activityInfo.intro];
                }
                break;
            case 4:
                return [ActivityInfoViewCell configureWithTitle:@"" Msg:[_activityInfo displayActivityInfo]];//_activityInfo.intro];
                break;
            default:
                return 60.f;
                break;
        }
    }else if (indexPath.section == 1) {
        return 60.f;
    }else{
        return 100.f;
    }
}

#pragma mark - Private
- (void)rightBtnClicked:(UIButton *)sender
{
    //添加分享按钮 navbar_share
    if(_activityInfo.shareurl.length > 0){
        [self shareBtnClicked];
    }
}

//检测分享按钮是否显示
- (void)checkShareBtn
{
    //添加分享按钮 navbar_share
    if(_activityInfo.shareurl.length > 0){
        //设置右侧按钮
//        [self.navHeaderView setRightBtnTitle:nil RightBtnImage:[UIImage imageNamed:@"navbar_more"]];
        
        //设置右侧按钮
        [self.navHeaderView setRightBtnTitle:nil RightBtnImage:[UIImage imageNamed:@"activity_share"]];
        
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_more"] style:UIBarButtonItemStyleBordered target:self action:@selector(shareBtnClicked)];
    }
}

//分享
- (void)shareBtnClicked
{
    WLActivityView  *shareView = [[WLActivityView alloc] initWithOneSectionArray:@[@(ShareTypeWLFriend),@(ShareTypeWLCircle),@(ShareTypeWeixinFriend),@(ShareTypeWeixinCircle)] andTwoArray:nil];
    [shareView show];
    CardStatuModel *newCardM = [[CardStatuModel alloc] init];
    newCardM.cid = _activityId;
    newCardM.type = @(3);
    newCardM.url = _activityInfo.shareurl;
    newCardM.title = _activityInfo.name;
    newCardM.intro = [NSString stringWithFormat:@"%@ %@",_activityInfo.city,[[_activityInfo.startime dateFromNormalString] formattedDateWithFormat:@"yyyy-MM-dd"]];
//    NSString *info = [_activityInfo displayActivityInfo];
//    newCardM.intro = info.length > 50 ? [info substringToIndex:50] : info;
    //分享回调
    WEAKSELF
    [shareView setWlShareBlock:^(ShareType duration){
        switch (duration) {
            case ShareTypeWLFriend://微链好友
            {
                ShareFriendsController *shareFVC = [[ShareFriendsController alloc] init];
                shareFVC.cardM = newCardM;
                NavViewController *navShareFVC = [[NavViewController alloc] initWithRootViewController:shareFVC];
                [self presentViewController:navShareFVC animated:YES completion:nil];
                //回调发送成功
//                [shareFVC setShareSuccessBlock:^(void){
//                    [WLHUDView showSuccessHUD:@"分享成功！"];
//                }];
                WEAKSELF
                [shareFVC setSelectFriendBlock:^(MyFriendUser *friendUser){
                    [weakSelf shareToWeLianFriendWithCardStatuModel:newCardM friend:friendUser];
                }];
            }
                break;
            case ShareTypeWLCircle://微链创业圈
            {
                PublishStatusController *publishShareVC = [[PublishStatusController alloc] initWithType:PublishTypeForward];
                publishShareVC.statusCard = newCardM;
                
                NavViewController *navShareFVC = [[NavViewController alloc] initWithRootViewController:publishShareVC];
                [self presentViewController:navShareFVC animated:YES completion:nil];
                //回调发送成功
                [publishShareVC setPublishBlock:^(void){
                    [WLHUDView showSuccessHUD:@"分享成功！"];
                }];
            }
                break;
            case ShareTypeWeixinFriend://微信好友
                [weakSelf shareToWX:weChat];
                break;
            case ShareTypeWeixinCircle://微信朋友圈
                [weakSelf shareToWX:weChatFriend];
                break;
            default:
                break;
        }
    }];
}

//分享到微链好友
- (void)shareToWeLianFriendWithCardStatuModel:(CardStatuModel *)cardModel friend:(MyFriendUser *)friendUser
{
    CardAlertView *alertView = [[CardAlertView alloc] initWithCardModel:cardModel Friend:friendUser];
    [alertView show];
    //发送成功
    [alertView setSendSuccessBlock:^(void){
        [WLHUDView showSuccessHUD:@"分享成功！"];
    }];
}

//分享到微信和微信朋友圈
- (void)shareToWX:(WeiboType)type
{
    NSString *desc = [_activityInfo displayShareToWx];
//    NSURL *imgUrl = [NSURL URLWithString:_activityInfo.logo];
    NSString *link = _activityInfo.shareurl;
    NSString *title = _activityInfo.name;
    
    UIImage *shareImage = [UIImage imageNamed:@"home_repost_huodong"];
    [[ShareEngine sharedShareEngine] sendWeChatMessage:title andDescription:desc WithUrl:link andImage:shareImage WithScene:type];
//    [[SDWebImageManager sharedManager] downloadImageWithURL:imgUrl options:SDWebImageRetryFailed|SDWebImageLowPriority
//                                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                                                       DLog(@"shareFriendImage---->>>%.2f",(float)receivedSize);
//                                                   } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                                                       DLog(@"shareFriendImage---->>>%@",image);
//                                                       
//                                                   }];
}

//收藏
- (void)favorteBtnClicked:(UIButton *)sender
{
    if (_activityInfo.isfavorite.boolValue) {
        //取消收藏
        [WLHUDView showHUDWithStr:@"取消收藏中..." dim:NO];
        [WeLianClient deleteActiveFavoriteWithID:_activityInfo.activeid
                                         Success:^(id resultInfo) {
                                             [WLHUDView hiddenHud];
                                             
                                             self.activityInfo = [_activityInfo updateFavorite:@(0)];
                                             [self checkFavorteStatus];
                                             //通知刷新我的活动中的数据
                                             [KNSNotification postNotificationName:kMyActivityInfoChanged object:nil];
                                         } Failed:^(NSError *error) {
                                             if (error) {
                                                 [WLHUDView showErrorHUD:error.localizedDescription];
                                             }else{
                                                 [WLHUDView showErrorHUD:@"取消收藏失败，请重试！"];
                                             }
                                         }];
//        [WLHttpTool deleteFavoriteActiveParameterDic:@{@"activeid":_activityInfo.activeid}
//                                             success:^(id JSON) {
////                                                 _iProjectDetailInfo.isfavorite = @(0);
//                                                 self.activityInfo = [_activityInfo updateFavorite:@(0)];
//                                                 [self checkFavorteStatus];
//                                                 //通知刷新我的活动中的数据
//                                                 [KNSNotification postNotificationName:kMyActivityInfoChanged object:nil];
//                                             } fail:^(NSError *error) {
//                                                 [UIAlertView showWithTitle:nil message:@"取消收藏失败，请重试！"];
//                                             }];
        
    }else{
        //收藏项目
        [WLHUDView showHUDWithStr:@"收藏中..." dim:NO];
        [WeLianClient favoriteActiveWithID:_activityInfo.activeid
                                   Success:^(id resultInfo) {
                                       [WLHUDView hiddenHud];
                                       
                                       self.activityInfo = [_activityInfo updateFavorite:@(1)];
                                       [self checkFavorteStatus];
                                       //通知刷新我的活动中的数据
                                       [KNSNotification postNotificationName:kMyActivityInfoChanged object:nil];
                                   } Failed:^(NSError *error) {
                                       if (error) {
                                           [WLHUDView showErrorHUD:error.localizedDescription];
                                       }else{
                                           [WLHUDView showErrorHUD:@"取消收藏失败，请重试！"];
                                       }
                                   }];
        
//        [WLHttpTool favoriteActiveParameterDic:@{@"activeid":_activityInfo.activeid}
//                                       success:^(id JSON) {
////                                           _iProjectDetailInfo.isfavorite = @(1);
//                                           self.activityInfo = [_activityInfo updateFavorite:@(1)];
//                                           [self checkFavorteStatus];
//                                           //通知刷新我的活动中的数据
//                                           [KNSNotification postNotificationName:kMyActivityInfoChanged object:nil];
//                                        } fail:^(NSError *error) {
//                                            [UIAlertView showWithTitle:nil message:@"收藏活动失败，请重试！"];
//                                        }];
    }
}

//我要报名
- (void)joinBtnClicked:(UIButton *)sender
{    
    //我要购票
//    [self loadActivityTickets];
    
    //0 还没开始，1进行中。2结束
    switch (_activityInfo.status.integerValue) {
        case 1:
            //活动进行中
            if (_activityInfo.isjoined.boolValue && _activityInfo.type.integerValue == 1) {
                //查看我的门票
                [self lookMyTicketsInfo];
            }
            break;
        case 2:
            //活动已结束
            if (_activityInfo.isjoined.boolValue && _activityInfo.type.integerValue == 1) {
                //查看我的门票
                [self lookMyTicketsInfo];
            }
            break;
        default:
        {
            //还没开始
            //1.已报名
            if(_activityInfo.isjoined.boolValue){
                //1收费，0免费
                if (_activityInfo.type.integerValue == 0) {
                    //取消报名
                    [UIAlertView bk_showAlertViewWithTitle:@""
                                                   message:@"是否取消当前活动的报名？"
                                         cancelButtonTitle:@"否"
                                         otherButtonTitles:@[@"是"]
                                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                       if (buttonIndex == 0) {
                                                           return;
                                                       }else{
                                                           [self cancelActivityJoined];
                                                       }
                                                   }];
                }else{
                    //查看我的门票
                    [self lookMyTicketsInfo];
                }
            }else{
                //名额未满 //1收费，0免费
                if(_activityInfo.type.integerValue == 0){
                    //免费活动
                    if(_activityInfo.limited.integerValue == 0){
                        //不限人数，可以报名
                        [self noPayToJoin];
                    }else{
                        if(_activityInfo.limited.integerValue > _activityInfo.joined.integerValue){
                            //不限人数，可以报名
                            [self noPayToJoin];
                        }else{
                            
                        }
                    }
                }else{
                    //收费活动
                    if(_activityInfo.limited.integerValue > 0){
                        //我要购票
                        [self loadActivityTickets];
                    }else{
                        
                    }
                }
                
                
//                //名额未满
//                if (_activityInfo.limited.integerValue == 0 && _activityInfo.type.integerValue == 0) {
//                    //不限人数，可以报名
//                    [self noPayToJoin];
//                }else{
//                    //名额未满
//                    if(_activityInfo.limited.integerValue > _activityInfo.joined.integerValue){
//                        //1收费，0免费
//                        if (_activityInfo.type.integerValue == 0) {
//                            //我要报名
//                            [self noPayToJoin];
//                        }else{
//                            //我要购票
//                            [self loadActivityTickets];
//                        }
//                    }else{
//                        //名额已满
//                        
//                    }
//                }
            }
        }
            break;
    }
}

//免费报名
- (void)noPayToJoin
{
    [UIAlertView bk_showAlertViewWithTitle:@""
                                   message:@"报名参加当前活动？"
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@[@"报名"]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if (buttonIndex == 0) {
                                           return ;
                                       }else{
                                           [self createActivityOrderWithType:0 Tickets:nil];
                                       }
                                   }];
}

//创建订单进入购票页面
- (void)buyTicketToOrderInfo:(NSArray *)tickets
{
    [self createActivityOrderWithType:1 Tickets:tickets];
}

//进入活动详情页面
- (void)showActivityDetailInfo
{
    // 观点  虎嗅网
    if (_activityInfo.url.length > 0) {
        TOWebViewController *webVC = [[TOWebViewController alloc] initWithURLString:_activityInfo.url];
        webVC.navigationButtonsHidden = YES;//隐藏底部操作栏目
        webVC.showRightShareBtn = YES;//现实右上角分享按钮
        [self.navigationController pushViewController:webVC animated:YES];
    }else{
        [UIAlertView showWithMessage:@"暂无活动详情"];
    }
}

//检测是否收藏当前项目
- (void)checkFavorteStatus
{
    if (_activityInfo.isfavorite.boolValue) {
        [_favorteBtn setTitle:@"已收藏" forState:UIControlStateNormal];
        [_favorteBtn setImage:[UIImage imageNamed:@"me_mywriten_shoucang_pre"] forState:UIControlStateNormal];
    }else{
        [_favorteBtn setTitle:@"收藏" forState:UIControlStateNormal];
        [_favorteBtn setImage:[UIImage imageNamed:@"me_mywriten_shoucang"] forState:UIControlStateNormal];
    }
}

//检测操作按钮状态
- (void)checkOperateBtnStatus
{
    //0 还没开始，1进行中。2结束
    _joinBtn.backgroundColor = [UIColor lightGrayColor];
    switch (_activityInfo.status.integerValue) {
        case 1:
            //进行中
            if (_activityInfo.isjoined.boolValue && _activityInfo.type.integerValue == 1) {
                //如果是收费活动
                [_joinBtn setTitle:@"查看我的门票" forState:UIControlStateNormal];
            }else{
                [_joinBtn setTitle:@"正在进行" forState:UIControlStateNormal];
            }
            break;
        case 2:
            //获取已结束
            if (_activityInfo.isjoined.boolValue && _activityInfo.type.integerValue == 1) {
                //如果是收费活动
                [_joinBtn setTitle:@"查看我的门票" forState:UIControlStateNormal];
            }else{
                [_joinBtn setTitle:@"已结束" forState:UIControlStateNormal];
            }
            break;
        default:
        {
            //还没开始
            //1.已报名
            if(_activityInfo.isjoined.boolValue){
                //1收费，0免费
                if (_activityInfo.type.integerValue == 0) {
                    [_joinBtn setTitle:@"取消报名" forState:UIControlStateNormal];
                }else{
                    [_joinBtn setTitle:@"查看我的门票" forState:UIControlStateNormal];
                }
            }else{
                //名额未满 //1收费，0免费
                if(_activityInfo.type.integerValue == 0){
                    //免费活动
                    if(_activityInfo.limited.integerValue == 0){
                        //不限人数，可以报名
                        _joinBtn.backgroundColor = RGB(52.f, 115.f, 185.f);
                        [_joinBtn setTitle:@"我要报名" forState:UIControlStateNormal];
                    }else{
                        if(_activityInfo.limited.integerValue > _activityInfo.joined.integerValue){
                            _joinBtn.backgroundColor = RGB(52.f, 115.f, 185.f);
                            [_joinBtn setTitle:@"我要报名" forState:UIControlStateNormal];
                        }else{
                            [_joinBtn setTitle:@"名额已满" forState:UIControlStateNormal];
                        }
                    }
                }else{
                    //收费活动
                    if(_activityInfo.limited.integerValue > 0){
                        _joinBtn.backgroundColor = RGB(52.f, 115.f, 185.f);
                        [_joinBtn setTitle:@"我要报名" forState:UIControlStateNormal];
                    }else{
                        [_joinBtn setTitle:@"已售罄" forState:UIControlStateNormal];
                    }
                }
                
//                if (_activityInfo.limited.integerValue == 0 && _activityInfo.type.integerValue == 0) {
//                    //不限人数，可以报名
//                    _joinBtn.backgroundColor = RGB(52.f, 115.f, 185.f);
//                    [_joinBtn setTitle:@"我要报名" forState:UIControlStateNormal];
//                }else{
//                    //收费活动
//                    if(_activityInfo.limited.integerValue > _activityInfo.joined.integerValue){
//                        //1收费，0免费
//                        if (_activityInfo.type.integerValue == 0) {
//                            _joinBtn.backgroundColor = RGB(52.f, 115.f, 185.f);
//                            [_joinBtn setTitle:@"我要报名" forState:UIControlStateNormal];
//                        }else{
//                            
//                        }
//                    }else{
//                        [_joinBtn setTitle:@"名额已满" forState:UIControlStateNormal];
//                    }
//                }
            }
        }
            break;
    }
}

//获取票务信息
- (void)loadActivityTickets
{
    //1038   946  收费活动
    [WLHUDView showHUDWithStr:@"获取票务信息.." dim:NO];
    [WeLianClient getActiveTicketsWithID:_activityInfo.activeid
                                 Success:^(id resultInfo) {
                                     [WLHUDView hiddenHud];
                                     
                                     if ([resultInfo count] > 0) {
                                         if (_activityTicketView.hidden) {
                                             WEAKSELF
                                             [_activityTicketView setBuyTicketBlock:^(NSArray *ticekets){
                                                 [weakSelf buyTicketToOrderInfo:ticekets];
                                             }];
                                             _activityTicketView.isBuyTicket = YES;
                                             _activityTicketView.tickets = resultInfo;
                                             [_activityTicketView showInView];
                                         }else{
                                             [_activityTicketView dismiss];
                                         }
                                     }
                                 } Failed:^(NSError *error) {
                                     if (error) {
                                         [WLHUDView showErrorHUD:error.localizedDescription];
                                     }else{
                                         [WLHUDView showErrorHUD:@"获取票务信息失败，请重试！"];
                                     }
                                     DLog(@"getActiveTickets error:%@",error.description);
                                 }];
    
//    [WLHttpTool getActivityTicketParameterDic:@{@"activeid":_activityInfo.activeid}
//                                      success:^(id JSON) {
//                                          
//                                          if (JSON) {
//                                              NSArray *tickets = [IActivityTicket objectsWithInfo:JSON];
//                                              if (_activityTicketView.hidden) {
//                                                  WEAKSELF
//                                                  [_activityTicketView setBuyTicketBlock:^(NSArray *ticekets){
//                                                      [weakSelf buyTicketToOrderInfo:ticekets];
//                                                  }];
//                                                  _activityTicketView.isBuyTicket = YES;
//                                                  _activityTicketView.tickets = tickets;
//                                                  [_activityTicketView showInView];
//                                              }else{
//                                                  [_activityTicketView dismiss];
//                                              }
//                                          }
//                                      } fail:^(NSError *error) {
//                                          DLog(@"getActivityTicketParameterDic error:%@",error.description);
//                                      }];
}

//查看我购买的票务信息
- (void)lookMyTicketsInfo
{
    [WLHUDView showHUDWithStr:@"获取票务信息.." dim:NO];
    [WeLianClient getActiveBuyedTicketsWithID:_activityInfo.activeid
                                      Success:^(id resultInfo) {
                                          [WLHUDView hiddenHud];
                                          
                                          if ([resultInfo count] > 0) {
                                              if (_activityTicketView.hidden) {
                                                  _activityTicketView.isBuyTicket = NO;
                                                  _activityTicketView.tickets = resultInfo;
                                                  [_activityTicketView showInView];
                                              }else{
                                                  [_activityTicketView dismiss];
                                              }
                                          }
                                      } Failed:^(NSError *error) {
                                          if (error) {
                                              [WLHUDView showErrorHUD:error.localizedDescription];
                                          }else{
                                              [WLHUDView showErrorHUD:@"获取票务信息失败，请重试！"];
                                          }
                                          DLog(@"getActiveBuyedTickets error:%@",error.description);
                                      }];
//    [WLHttpTool getBuyedActiveTicketsParameterDic:@{@"activeid":_activityInfo.activeid}
//                                          success:^(id JSON) {
//                                              if (JSON) {
//                                                  NSArray *tickets = [IActivityTicket objectsWithInfo:JSON];
//                                                  if (_activityTicketView.hidden) {
//                                                      _activityTicketView.isBuyTicket = NO;
//                                                      _activityTicketView.tickets = tickets;
//                                                      [_activityTicketView showInView];
//                                                  }else{
//                                                      [_activityTicketView dismiss];
//                                                  }
//                                              }
//                                          } fail:^(NSError *error) {
//                                              DLog(@"getActivityTicketParameterDic error:%@",error.description);
//                                          }];
}

//更新页面信息
- (void)updateUI
{
    [_tableView reloadData];
    [self checkFavorteStatus];
    [self checkOperateBtnStatus];
}

//更新页面展示数据信息
- (void)initActivityUIInfo
{
    CGSize titleSize = [_activityInfo.name calculateSize:CGSizeMake(self.view.width - 30.f, FLT_MAX) font:kNormalBlod16Font];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kHeaderImageHeight + titleSize.height + 20.f)];
    headerView.layer.borderColorFromUIColor = RGB(231.f, 231.f, 231.f);
    headerView.layer.borderWidths = @"{0,0,0.6,0}";
    
    //图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kHeaderImageHeight)];
    imageView.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:imageView];
    [imageView sd_setImageWithURL:[NSURL URLWithString:_activityInfo.logo] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageLowPriority];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = kTitleNormalTextColor;
    titleLabel.font = kNormalBlod16Font;
    titleLabel.text = _activityInfo.name;
    titleLabel.width = headerView.width - 30.f;
    titleLabel.numberOfLines = 0;
    [titleLabel sizeToFit];
    titleLabel.top = imageView.bottom + 10.f;
    titleLabel.left = 15.f;
    [headerView addSubview:titleLabel];
    
    [_tableView setTableHeaderView:headerView];
//    [self.view addSubview:tableView];
//    [self.view sendSubviewToBack:_tableView];
    
    self.scrollView.contentSize = CGSizeMake(_tableView.width, _tableView.height - ViewCtrlTopBarHeight);
    [self.scrollView addSubview:_tableView];
    [self.scrollView addSubview:self.navHeaderView];
    [self.scrollView bringSubviewToFront:self.navHeaderView];
//    [_tableView setParallaxHeaderView:headerView
//                                 mode:VGParallaxHeaderModeFill
//                               height:kHeaderImageHeight + titleSize.height + 20.f];
}

//更新报名人数信息
- (void)updateJoinedInfo:(BOOL)isJoin
{
    //通知刷新我的活动中的数据
    [KNSNotification postNotificationName:kMyActivityInfoChanged object:nil];
    //更新列表的报名状态
    [KNSNotification postNotificationName:kUpdateJoinedUI object:nil];
    
    //更新报名状态
    self.activityInfo = [_activityInfo updateIsjoined:@(isJoin)];
    //更新报名人数
    self.activityInfo = [_activityInfo updateJoined:@(isJoin ? 1 : -1)];
    //更页面
    [self updateUI];
}

//更新支付报名
- (void)updatePayJoined
{
    [self updateJoinedInfo:YES];
}

//更新详情展示页面
- (void)updateWebDetailInfo
{
    if (_activityInfo.url.length > 0) {
        ActivitySubInfoViewController *webVC = [[ActivitySubInfoViewController alloc] initWithUrl:_activityInfo.url];
        self.subViewController = webVC;
        self.subViewController.mainViewController = self;
    }
}

//获取详情信息
- (void)initData
{
    WEAKSELF
    if (!_activityId.boolValue) {
        UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:@"" message:@"该活动已经被删除！"];
        [alert bk_addButtonWithTitle:@"知道了" handler:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        [alert show];
        return;
    }
    
    [WLHUDView showHUDWithStr:@"获取详情中..." dim:NO];
    [WeLianClient getActiveDetailInfoWithID:_activityId
                                    Success:^(id resultInfo) {
                                        [WLHUDView hiddenHud];
                                        if (resultInfo) {
                                            IActivityInfo *iActivity = resultInfo;
                                            BOOL isFromList = _activityInfo != nil ? YES : NO;
                                            if (isFromList) {
                                                self.activityInfo = [ActivityInfo updateActivityInfoWith:iActivity withType:_activityInfo.activeType];
                                            }else{
                                                self.activityInfo = [ActivityInfo createActivityInfoWith:iActivity withType:0];
                                                //更新数据
                                                [self initActivityUIInfo];
                                            }
                                            self.datasource = iActivity.guests;
                                            
                                            //更新详情展示页面
                                            [self updateWebDetailInfo];
                                            //检测分享按钮
                                            [self checkShareBtn];
                                            //更页面
                                            [self updateUI];
                                        }else{
                                            [WLHUDView showErrorHUD:@"获取失败，该活动不存在！"];
                                        }
                                    } Failed:^(NSError *error) {
                                        if (error) {
                                            [WLHUDView showErrorHUD:error.localizedDescription];
                                        }else{
                                            [WLHUDView showErrorHUD:@"网络无法连接，请重试！"];
                                        }
                                        DLog(@"getActivityDetailParameterDic error:%@",error.localizedDescription);
                                    }];
    
//    [WLHttpTool getActivityDetailParameterDic:@{@"activeid":_activityId}
//                                      success:^(id JSON) {
//                                          //隐藏下拉刷新控件
////                                          [self.tableView.header endRefreshing];
//                                          if (JSON) {
//                                              if ([[JSON objectForKey:@"deleted"] boolValue]) {
//                                                  UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:@"" message:@"该活动已经被删除！"];
//                                                  [alert bk_addButtonWithTitle:@"确定" handler:^{
//                                                      [weakSelf.navigationController popViewControllerAnimated:YES];
//                                                  }];
//                                                  [alert show];
//                                                  return;
//                                              }
//                                              IActivityInfo *iActivity = [IActivityInfo objectWithDict:JSON];
//                                              BOOL isFromList = _activityInfo != nil ? YES : NO;
//                                              if (isFromList) {
//                                                  self.activityInfo = [ActivityInfo updateActivityInfoWith:iActivity withType:_activityInfo.activeType];
//                                              }else{
//                                                  self.activityInfo = [ActivityInfo createActivityInfoWith:iActivity withType:0];
//                                                  //更新数据
//                                                  [self initActivityUIInfo];
//                                              }
//                                              self.datasource = iActivity.guests;
//                                              
//                                              //检测分享按钮
//                                              [self checkShareBtn];
//                                              //更页面
//                                              [self updateUI];
//                                          }else{
//                                              [WLHUDView showSuccessHUD:@"获取失败，该活动不存在！"];
//                                          }
//                                      } fail:^(NSError *error) {
//                                          //隐藏下拉刷新控件
////                                          [self.tableView.header endRefreshing];
//                                          DLog(@"getActivityDetailParameterDic error:%@",error.description);
//                                      }];
}

//取消报名
- (void)cancelActivityJoined
{
    [WLHUDView showHUDWithStr:@"取消中..." dim:NO];
    [WeLianClient deleteActiveRecordWithID:_activityId
                                   Success:^(id resultInfo) {
                                       [WLHUDView hiddenHud];
                                       //更页面
                                       [self updateJoinedInfo:NO];
                                   } Failed:^(NSError *error) {
                                       if (error) {
                                           [WLHUDView showErrorHUD:error.localizedDescription];
                                       }else{
                                           [WLHUDView showErrorHUD:@"取消报名失败，请重试！"];
                                       }
                                       DLog(@"deleteActiveRecorderParameterDic error:%@",error.localizedDescription);
                                   }];
//    [WLHttpTool deleteActiveRecorderParameterDic:@{@"activeid":_activityId}
//                                         success:^(id JSON) {
//                                             //更页面
//                                             [self updateJoinedInfo:NO];
//                                         } fail:^(NSError *error) {
//                                             DLog(@"deleteActiveRecorderParameterDic error:%@",error.description);
//                                         }];
}

//创建活动报名   type: 0:免费 1：收费
- (void)createActivityOrderWithType:(NSInteger)type Tickets:(NSArray *)tickets
{
    NSMutableArray *ticketsinfo = [NSMutableArray array];
    if (tickets.count > 0 && type == 1) {
        for (int i = 0; i < tickets.count; i++) {
            IActivityTicket *ticket = tickets[i];
            [ticketsinfo addObject:@{@"ticketid":ticket.ticketid,@"count":ticket.buyCount}];
        }
    }
    [WLHUDView showHUDWithStr:@"报名中..." dim:NO];
    [WeLianClient orderActiveWithID:_activityId
                            Tickets:ticketsinfo
                            Success:^(id resultInfo) {
                                [WLHUDView hiddenHud];
                                
                                if (type != 0) {
                                    //付费
                                    IActivityOrderResultModel *result = [IActivityOrderResultModel objectWithDict:resultInfo];
                                    //进入订单页面
                                    ActivityOrderInfoViewController *activityOrderInfoVC = [[ActivityOrderInfoViewController alloc] initWithActivityInfo:_activityInfo Tickets:tickets payInfo:result];
                                    [self.navigationController pushViewController:activityOrderInfoVC animated:YES];
                                }else{
                                    //免费
                                    [WLHUDView showSuccessHUD:@"恭喜您，报名成功！"];
                                    //更页面
                                    [self updateJoinedInfo:YES];
                                }
                            } Failed:^(NSError *error) {
                                if (error) {
                                    [WLHUDView showErrorHUD:error.localizedDescription];
                                }else{
                                    [WLHUDView showErrorHUD:@"报名失败，请重新尝试！"];
                                }
                            }];
    
//    NSDictionary *param = [NSDictionary dictionary];
//    if (type == 0) {
//        //免费活动
//        param = @{@"activeid":_activityId};
//    }else{
//        NSMutableArray *ticketsinfo = [NSMutableArray array];
//        for (int i = 0; i < tickets.count; i++) {
//            IActivityTicket *ticket = tickets[i];
//            [ticketsinfo addObject:@{@"ticketid":ticket.ticketid,@"count":ticket.buyCount}];
//        }
//        //需要支付的活动
//        param = @{@"activeid":_activityId,
//                  @"tickets":ticketsinfo};
//    }
    
//    [WLHttpTool createTicketOrderParameterDic:param
//                                      success:^(id JSON) {
//                                          if ([JSON isKindOfClass:[NSDictionary class]]) {
//                                              if ([JSON[@"state"] integerValue] == -1) {
//                                                  [WLHUDView showSuccessHUD:@"报名失败，请重新尝试！"];
//                                                  return;
//                                              }
//                                          }
//                                          if (type != 0) {
//                                              //进入订单页面
//                                              ActivityOrderInfoViewController *activityOrderInfoVC = [[ActivityOrderInfoViewController alloc] initWithActivityInfo:_activityInfo Tickets:tickets payInfo:JSON];
//                                              [self.navigationController pushViewController:activityOrderInfoVC animated:YES];
//                                          }else{
//                                              [WLHUDView showSuccessHUD:@"恭喜您，报名成功！"];
//                                              //更页面
//                                              [self updateJoinedInfo:YES];
//                                          }
//                                      } fail:^(NSError *error) {
//                                          [WLHUDView showSuccessHUD:@"报名失败，请重新尝试！"];
//                                      }];
}

@end
