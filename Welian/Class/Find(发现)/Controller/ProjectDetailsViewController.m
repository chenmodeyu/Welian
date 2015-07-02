//
//  ProjectDetailsViewController.m
//  Welian
//
//  Created by weLian on 15/2/2.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectDetailsViewController.h"
#import "ProjectUserListViewController.h"
#import "CreateProjectController.h"
#import "MemberProjectController.h"
#import "TOWebViewController.h"
#import "FinancingProjectController.h"
#import "UserInfoViewController.h"
#import "FinancingInfoViewController.h"
#import "ProjectPostDetailInfoViewController.h"

#import "ProjectInfoView.h"
#import "ProjectDetailView.h"
#import "WLSegmentedControl.h"
#import "CommentCell.h"
#import "NoCommentCell.h"
#import "ProjectFavorteViewCell.h"
#import "ProjectDetailInfoView.h"
#import "MessageKeyboardView.h"
#import "MJRefresh.h"
//分享
#import "WLActivityView.h"
#import "ShareEngine.h"
#import "SEImageCache.h"
#import "ShareFriendsController.h"
#import "NavViewController.h"
#import "PublishStatusController.h"
#import "CardStatuModel.h"
#import "CardAlertView.h"

//图片展示
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

// 投资人
#import "InvestCerVC.h"

#define kHeaderHeight 133.f
#define kHeaderHeight2 93.f
#define kSegementedControlHeight 50.f
#define kTableViewHeaderHeight 40.f

static NSString *noCommentCell = @"NoCommentCell";

@interface ProjectDetailsViewController ()<WLSegmentedControlDelegate,UITableViewDelegate,UITableViewDataSource>
{
    BOOL _isFinish;
}
@property (assign,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *datasource;//用于存储评论数组
@property (strong,nonatomic) NSNumber *projectPid;
@property (strong,nonatomic) IProjectInfo *iProjectInfo;
@property (strong,nonatomic) ProjectInfo *projectInfo;
@property (assign,nonatomic) ProjectDetailInfoView *projectDetailInfoView;

@property (strong,nonatomic) IProjectDetailInfo *iProjectDetailInfo;
@property (strong,nonatomic) ProjectDetailInfo *projectDetailInfo;
@property (strong,nonatomic) CommentCellFrame *selecCommFrame;

@property (assign,nonatomic) UIButton *favorteBtn;
@property (assign,nonatomic) UIButton *zanBtn;
@property (strong,nonatomic) NSIndexPath *selectIndex;
@property (strong,nonatomic) UITapGestureRecognizer *tapGesture;

@property (strong,nonatomic) MessageKeyboardView *messageView;//下方的键盘输入栏目
@property (assign,nonatomic) UIToolbar *operateToolBar;//下方的操作栏

@property (assign,nonatomic) NSInteger pageIndex;
@property (assign,nonatomic) NSInteger pageSize;
@property (assign,nonatomic) BOOL isFromCreate;//判断是否是从创建活动进入

@end

@implementation ProjectDetailsViewController

- (void)dealloc
{
    _projectPid = nil;
    _datasource = nil;
    _projectInfo = nil;
    _iProjectInfo = nil;
    _iProjectDetailInfo = nil;
    _projectDetailInfo = nil;
    _selecCommFrame = nil;
    _messageView = nil;
    _selectIndex = nil;
    _tapGesture = nil;
    [KNSNotification removeObserver:self name:nil object:nil];
}

- (NSString *)title
{
    return @"项目详情";
}

- (UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture) {
        //添加屏幕点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            //隐藏键盘
            [self hideKeyBoard];
        }];
        self.tapGesture = tap;
    }
    return _tapGesture;
}

//通过I模型展示
- (instancetype)initWithIProjectInfo:(IProjectInfo *)iProjectInfo
{
    self = [super init];
    if (self) {
        self.iProjectInfo = iProjectInfo;
        self.pageIndex = 1;
        self.pageSize = 10;
        self.projectPid = _iProjectInfo.pid;
        
        //初始化页面数据
        [self initUI];
    }
    return self;
}

- (instancetype)initWithProjectInfo:(ProjectInfo *)projectInfo
{
    self = [super init];
    if (self) {
        self.projectInfo = projectInfo;
        self.pageIndex = 1;
        self.pageSize = 10;
        self.projectPid = _projectInfo.pid;
        
        //初始化页面数据
        [self initUI];
    }
    return self;
}

- (instancetype)initWithProjectPid:(NSNumber *)projectPid
{
    self = [super init];
    if (self) {
        self.projectPid = projectPid;
        self.pageIndex = 1;
        self.pageSize = 10;
    }
    return self;
}

//
- (instancetype)initWithProjectDetailInfo:(IProjectDetailInfo *)detailInfo isFromCreate:(BOOL)isFromCreate
{
    self = [super init];
    if (self) {
        self.iProjectDetailInfo = detailInfo;
        self.projectPid = _iProjectDetailInfo.pid;
        _isFinish = YES;
        self.isFromCreate = isFromCreate;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //删除键盘监听
    [KNSNotification removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [KNSNotification removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
//    if (!_isFromCreate) {
//        //代理置空，否则会闪退 设置手势滑动返回
//        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//        }
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //键盘监听
    [KNSNotification addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [KNSNotification addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_isFromCreate){
        //设置是否禁用可以滑动返回pop
        self.fd_interactivePopDisabled = YES;
    }
//    if (!_isFromCreate) {
//        //开启iOS7的滑动返回效果
//        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//            //只有在二级页面生效
//            if ([self.navigationController.viewControllers count] > 1) {
//                self.navigationController.interactivePopGestureRecognizer.delegate = self;
//            }
//        }
//    }
}

//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    //开启滑动手势
//    if (!_isFromCreate) {
//        if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//            navigationController.interactivePopGestureRecognizer.enabled = YES;
//        }
//    }else{
//        navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
//}

// 返回
- (void)backItem
{
    if (_isFinish) {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //返回按钮
    UIButton *backBut = [[UIButton alloc] init];
    [backBut setTitle:@"返回" forState:UIControlStateNormal];
    [backBut setImage:[UIImage imageNamed:@"backItem"] forState:UIControlStateNormal];
    [backBut setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
    [backBut addTarget:self action:@selector(backItem) forControlEvents:UIControlEventTouchUpInside];
    [backBut setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBut];
    [backBut sizeToFit];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:Rect(0.f,0.f,self.view.width,self.view.height - toolBarHeight)];
    tableView.dataSource = self;
    tableView.delegate = self;
    //隐藏表格分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView registerNib:[UINib nibWithNibName:@"NoCommentCell" bundle:nil] forCellReuseIdentifier:noCommentCell];
    
    //回复输入栏
    self.messageView = [[MessageKeyboardView alloc] initWithFrame:CGRectMake(0, tableView.bottom, self.view.width, toolBarHeight) andSuperView:self.view withMessageBlock:^(NSString *comment) {
        
        //评论,
        NSDictionary *params = [NSDictionary dictionary];
        //回复某个人的评论
        CommentMode *commentM = [[CommentMode alloc] init];
        commentM.comment = comment;
        commentM.created = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
        if (_selecCommFrame) {
            params = @{@"pid":_projectPid,@"touid":_selecCommFrame.commentM.user.uid,@"comment":comment};
            
            commentM.touser = _selecCommFrame.commentM.user;
        }else{
            params = @{@"pid":_projectPid,@"comment":comment};
        }
        IBaseUserM *user = [IBaseUserM getLoginUserBaseInfo];
        commentM.user = user;
        
        //评论
        [WLHUDView showHUDWithStr:@"评论中..." dim:NO];
        [WeLianClient commentProjectWithParameterDic:params
                                             Success:^(id resultInfo) {
                                                 [WLHUDView hiddenHud];
                                                 
                                                 commentM.cid = resultInfo[@"cid"];
                                                 
                                                 CommentCellFrame *commentFrame = [[CommentCellFrame alloc] init];
                                                 [commentFrame setCommentM:commentM];
//                                                 [_datasource insertObject:commentFrame atIndex:0];
                                                 [_datasource addObject:commentFrame];
                                                 
                                                 _iProjectDetailInfo.commentcount = @(_iProjectDetailInfo.commentcount.integerValue + 1);
                                                 
                                                 //刷新
                                                 if (_iProjectDetailInfo.zancount.integerValue < 1) {
                                                     //如果之前没有刷新整个table
                                                     [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                                                     //设置滚动到最下面的评论
                                                     [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_datasource.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom  animated:YES];
                                                 }else{
                                                     [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                                                     //设置滚动到最下面的评论
                                                     [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_datasource.count - 1) inSection:1] atScrollPosition:UITableViewScrollPositionBottom  animated:YES];
                                                 }
                                                 
                                                 //隐藏键盘
                                                 [self hideKeyBoard];
                                             } Failed:^(NSError *error) {
                                                 if (error) {
                                                     [WLHUDView showErrorHUD:error.localizedDescription];
                                                 }else{
                                                     [WLHUDView showErrorHUD:@"评论发表失败，请重试！"];
                                                 }
                                             }];
        
    }];
    [self.view addSubview:self.messageView];
    
    //设置底部操作栏
    UIToolbar *operateToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, tableView.bottom, self.view.width, toolBarHeight)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //点赞
    UIButton *zanBtn = [self getBtnWithTitle:@"点赞" image:[UIImage imageNamed:@"me_mywriten_good"]];
    [zanBtn addTarget:self action:@selector(zanBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *zanBarItem = [[UIBarButtonItem alloc] initWithCustomView:zanBtn];
    self.zanBtn = zanBtn;
    
    //空白 评论 me_mywriten_comment@2x
    UIButton *commentBtn = [self getBtnWithTitle:@"评论" image:[UIImage imageNamed:@"me_mywriten_comment"]];
    [commentBtn addTarget:self action:@selector(commentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *commentBarItem = [[UIBarButtonItem alloc] initWithCustomView:commentBtn];
//    UIBarButtonItem *zhongBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                                                                                  target:self action:nil];
    //收藏
    UIButton *favorteBtn = [self getBtnWithTitle:@"收藏" image:[UIImage imageNamed:@"me_mywriten_shoucang"]];
    [favorteBtn addTarget:self action:@selector(favorteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *favorteBarItem = [[UIBarButtonItem alloc] initWithCustomView:favorteBtn];
    self.favorteBtn = favorteBtn;
    
    operateToolBar.items = @[zanBarItem,spacer,commentBarItem,spacer,favorteBarItem];
    [self.view addSubview:operateToolBar];
    self.operateToolBar = operateToolBar;
    
    //项目详细信息
    ProjectDetailInfoView *projectDetailInfoView = [[ProjectDetailInfoView alloc] initWithFrame:self.view.bounds];
    projectDetailInfoView.hidden = YES;
    [[[UIApplication sharedApplication] keyWindow] addSubview:projectDetailInfoView];
    self.projectDetailInfoView = projectDetailInfoView;
    WEAKSELF;
    [projectDetailInfoView setCloseBlock:^(){
        [weakSelf closeProjectDetailInfoView];
    }];
    
    //下拉刷新
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(initData)];
    
    //上提加载更多
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreCommentData)];
    self.tableView.footer.hidden = YES;
//    [self.tableView addFooterWithTarget:self action:@selector(loadMoreCommentData)];
    
    if (_projectDetailInfo) {
        [self.tableView reloadData];
        [self updateUI];
    }else{
        //获取数据
//        [self initData];
        [self.tableView.header beginRefreshing];
    }
}

//获取按钮对象
- (UIButton *)getBtnWithTitle:(NSString *)title image:(UIImage *)image{
    UIButton *favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    favoriteBtn.backgroundColor = [UIColor clearColor];
    favoriteBtn.titleLabel.font = kNormal14Font;
    [favoriteBtn setTitle:title forState:UIControlStateNormal];
    [favoriteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [favoriteBtn setImage:image forState:UIControlStateNormal];
    favoriteBtn.imageEdgeInsets = UIEdgeInsetsMake(0.f, -10.f, 0.f, 0.f);
//    favoriteBtn.frame = CGRectMake(0.f, 0.f, self.view.width / 3.f, toolBarHeight);
    favoriteBtn.frame = CGRectMake(0.f, 0.f, (self.view.width - 20 * 2) / 3.f, toolBarHeight);
    return favoriteBtn;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //隐藏键盘
    [self hideKeyBoard];
}

#pragma mark - UITableView Datasource&Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return _iProjectDetailInfo.zancount.integerValue < 1 ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_iProjectDetailInfo.zancount.integerValue < 1) {
        //没有点赞的好友
        return _datasource.count ? : 1;
    }else{
        if (section == 0) {
            return 1;
        }else{
            if (_datasource.count == 0) {
                return 1;
            }else{
                return _datasource.count ? : 1;
            }
        }

    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:Rect(.0f, .0f, self.view.width, kTableViewHeaderHeight)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = kNormalBlod16Font;
    titleLabel.text = section == 0 && _iProjectDetailInfo.zancount.integerValue > 0 ? @"赞过的人" : [NSString stringWithFormat:@"评论（%d）",_iProjectDetailInfo.commentcount.intValue];
    [titleLabel sizeToFit];
    titleLabel.left = 15.f;
    titleLabel.centerY = headerView.height / 2.f;
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_iProjectDetailInfo.zancount.intValue > 0) {
        if(indexPath.section == 0){
            //赞过的人
            static NSString *cellIdentifier = @"Project_Favorte_View_Cell";
            ProjectFavorteViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[ProjectFavorteViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.projectInfo = _iProjectDetailInfo;
            WEAKSELF;
            [cell setBlock:^(IBaseUserM *user,BOOL showList){
                [weakSelf selectZanUserWithUser:user showList:showList];
            }];
            return cell;
        }else{
            //评论列表
            if (_datasource.count > 0) {
                CommentCell *cell = [CommentCell cellWithTableView:tableView];
                cell.showBottomLine = YES;
                // 传递的模型：文字数据 + 子控件frame数据
                cell.commentCellFrame = _datasource[indexPath.row];
                cell.commentVC = self;
                return cell;
            }else{
                NoCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:noCommentCell];
                [cell.msgLabel setFont:WLFONT(14)];
                cell.msgLabel.text = @"还没有评论哦,赶快抢占沙发吧~";
                cell.layer.borderColorFromUIColor = [UIColor clearColor];
                return cell;
            }
        }
    }else{
        //评论列表
        if (_datasource.count > 0) {
            CommentCell *cell = [CommentCell cellWithTableView:tableView];
            cell.showBottomLine = YES;
            // 传递的模型：文字数据 + 子控件frame数据
            cell.commentCellFrame = _datasource[indexPath.row];
            cell.commentVC = self;
            return cell;
        }else{
            NoCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:noCommentCell];
            [cell.msgLabel setFont:WLFONT(14)];
            cell.msgLabel.text = @"还没有评论哦,赶快抢占沙发吧~";
            cell.layer.borderColorFromUIColor = [UIColor clearColor];
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.selectIndex = indexPath;
    
    CommentCellFrame *selecCommFrame = _datasource[indexPath.row];
    
    if (selecCommFrame.commentM.user.uid.integerValue == [LogInUser getCurrentLoginUser].uid.integerValue) {
        UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:nil];
        [sheet bk_setDestructiveButtonWithTitle:@"删除" handler:^{
            //删除评论
            [WLHUDView showHUDWithStr:@"评论删除中..." dim:NO];
            [WeLianClient deleteProjectCommentWithCid:selecCommFrame.commentM.cid
                                              Success:^(id resultInfo) {
                                                  [WLHUDView hiddenHud];
                                                  
                                                  //删除当前对象
                                                  [_datasource removeObject:selecCommFrame];
                                                  
                                                  //刷新列表
                                                  _iProjectDetailInfo.commentcount = @(_iProjectDetailInfo.commentcount.integerValue - 1);
                                                  
                                                  //刷新
                                                  [_tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                                              } Failed:^(NSError *error) {
                                                  if (error) {
                                                      [WLHUDView showErrorHUD:error.localizedDescription];
                                                  }else{
                                                      [WLHUDView showErrorHUD:@"删除评论失败，请重试！"];
                                                  }
                                              }];
        }];
        [sheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [sheet showInView:self.view];
    }else{
        //回复别人的，直接回复
        self.selecCommFrame = selecCommFrame;
        [self.messageView startCompile:_selecCommFrame.commentM.user];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if (_iProjectDetailInfo.zancount.intValue > 0) {
            return kTableViewHeaderHeight;
        }else{
            if (_iProjectDetailInfo.commentcount.integerValue > 0) {
                return kTableViewHeaderHeight;
            }else{
                return 0;
            }
        }
    }else if(section == 1){
        if (_iProjectDetailInfo.commentcount.integerValue > 0) {
            return kTableViewHeaderHeight;
        }else{
            return 0;
        }
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_iProjectDetailInfo.zancount.intValue > 0) {
        if (indexPath.section == 0) {
            return 40.f;
        }
        if (_datasource.count > 0) {
            return [_datasource[indexPath.row] cellHeight];
        }else{
            return 60.f;
        }
    }else{
        if (_datasource.count > 0) {
            return [_datasource[indexPath.row] cellHeight];
        }else{
            return 60.f;
        }
    }
}

#pragma mark - WLSegmentedControlDelegate
- (void)wlSegmentedControlSelectAtIndex:(NSInteger)index
{
    DLog(@"选择的栏目：%d",(int)index);
    switch (index) {
        case 0:
        {
            //项目网站
            if (_projectDetailInfo.website.length > 0) {
                TOWebViewController *webVC = [[TOWebViewController alloc] initWithURLString:_projectDetailInfo.website];
                webVC.navigationButtonsHidden = YES;//隐藏底部操作栏目
                webVC.showRightShareBtn = YES;//现实右上角分享按钮
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }
            break;
        case 1:
        {
            //项目成员
            if (_projectDetailInfo.membercount.integerValue > 0) {
                ProjectUserListViewController *projectUserListVC = [[ProjectUserListViewController alloc] init];
                projectUserListVC.infoType = UserInfoTypeProjectGroup;
                projectUserListVC.projectDetailInfo = _iProjectDetailInfo;
                [self.navigationController pushViewController:projectUserListVC animated:YES];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Private
/**
 *  分享
 */
- (void)shareBtnClicked
{
    NSArray *buttons = nil;
    if ([LogInUser getCurrentLoginUser].uid.integerValue == _iProjectDetailInfo.user.uid.integerValue) {
        buttons = @[@(ShareTypeProjectInfo),@(ShareTypeProjectMember),@(ShareTypeProjectFinancing)];
    }
    CardStatuModel *newCardM = [[CardStatuModel alloc] init];
    newCardM.cid = _projectDetailInfo.pid;
    newCardM.type = @(10);
    newCardM.title = _projectDetailInfo.name;
    newCardM.intro = _projectDetailInfo.intro.length > 50 ? [_projectDetailInfo.intro substringToIndex:50] : _projectDetailInfo.intro;
    newCardM.url = _projectDetailInfo.shareurl;
    
    WEAKSELF
    WLActivityView *wlActivity = [[WLActivityView alloc] initWithOneSectionArray:buttons andTwoArray:@[@(ShareTypeWLFriend),@(ShareTypeWLCircle),@(ShareTypeWeixinFriend),@(ShareTypeWeixinCircle)]];
    wlActivity.wlShareBlock = ^(ShareType type){
        switch (type) {
            case ShareTypeWLFriend:
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
            case ShareTypeWLCircle:
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
            case ShareTypeWeixinFriend:
            {
                NSString *desc = [NSString stringWithFormat:@"%@\n%@",_projectDetailInfo.name,_projectDetailInfo.intro];
                UIImage *shareImage = [UIImage imageNamed:@"home_repost_xiangmu"];
                NSString *link = _projectDetailInfo.shareurl.length == 0 ? @"http://www.welian.com/" : _projectDetailInfo.shareurl;
                
                [[ShareEngine sharedShareEngine] sendWeChatMessage:@"推荐一个好项目" andDescription:desc WithUrl:link andImage:shareImage WithScene:weChat];
            }
                break;
            case ShareTypeWeixinCircle:
            {
                NSString *desc = [NSString stringWithFormat:@"%@\n%@",_projectDetailInfo.name,_projectDetailInfo.intro];
                UIImage *shareImage = [UIImage imageNamed:@"home_repost_xiangmu"];
                NSString *link = _projectDetailInfo.shareurl.length == 0 ? @"http://www.welian.com/" : _projectDetailInfo.shareurl;
                NSString *title = [NSString stringWithFormat:@"%@ | %@",_projectDetailInfo.name,_projectDetailInfo.intro];
                [[ShareEngine sharedShareEngine] sendWeChatMessage:title andDescription:desc WithUrl:link andImage:shareImage WithScene:weChatFriend];
            }
                break;
            case ShareTypeProjectInfo:
            {
                CreateProjectController *createProjcetVC = [[CreateProjectController alloc] initIsEdit:YES withData:_iProjectDetailInfo];
                createProjcetVC.projectDataBlock = ^(ProjectDetailInfo *projectModel){
                    weakSelf.projectDetailInfo = projectModel;
                    [weakSelf updateUI];
                };
                [weakSelf.navigationController pushViewController:createProjcetVC animated:YES];
            }
                break;
            case ShareTypeProjectMember:
            {
                MemberProjectController *memberProjectVC = [[MemberProjectController alloc] initIsEdit:YES withData:_iProjectDetailInfo];
                memberProjectVC.projectDataBlock = ^(ProjectDetailInfo *projectModel){
                    weakSelf.projectDetailInfo = projectModel;
                    [weakSelf updateUI];
                };
                [weakSelf.navigationController pushViewController:memberProjectVC animated:YES];
            }
                break;
            case ShareTypeProjectFinancing:
            {
                FinancingProjectController *financingProjectVC = [[FinancingProjectController alloc] initIsEdit:YES withData:_iProjectDetailInfo];
                financingProjectVC.projectDataBlock = ^(ProjectDetailInfo *projectModel){
                    weakSelf.projectDetailInfo = projectModel;
                    [weakSelf updateUI];
                };
                [weakSelf.navigationController pushViewController:financingProjectVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    };
    [wlActivity show];
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

/**
 *  点赞
 *
 *  @param sender 触发的按钮
 */
- (void)zanBtnClicked:(UIButton *)sender
{
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    
    NSMutableArray *zanUsers = [NSMutableArray arrayWithArray:_iProjectDetailInfo.zanusers];
    [WLHUDView showHUDWithStr:@"" dim:NO];
    if (!_iProjectDetailInfo.iszan.boolValue) {
        //赞
        [WeLianClient zanProjectWithPid:_projectPid
                                Success:^(id resultInfo) {
                                    [WLHUDView hiddenHud];
                                    
                                    _iProjectDetailInfo.iszan = @(1);
                                    _iProjectDetailInfo.zancount = @(_iProjectDetailInfo.zancount.integerValue + 1);
                                    [_projectDetailInfo updateZancount:_iProjectDetailInfo.zancount];
                                    
                                    if (_projectInfo) {
                                        //更新点赞状态和数量
                                        [_projectInfo updateIsZanAndZanCount:YES];
                                    }
                                    
                                    IBaseUserM *zanUser = [[IBaseUserM alloc] init];
                                    zanUser.avatar = loginUser.avatar;
                                    zanUser.name = loginUser.name;
                                    zanUser.uid = loginUser.uid;
                                    zanUser.position = loginUser.position;
                                    zanUser.company = loginUser.company;
                                    zanUser.investorauth = loginUser.investorauth;
                                    //插入
                                    [zanUsers insertObject:zanUser atIndex:0];
                                    _iProjectDetailInfo.zanusers = [NSArray arrayWithArray:zanUsers];
                                    
                                    //刷新
                                    if (_iProjectDetailInfo.zancount.integerValue <= 1) {
                                        //如果之前没有刷新整个table
                                        [_tableView reloadData];
                                    }else{
                                        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                                    }
                                    
                                    [self checkZanStatus];
                                    
                                    [self updateUI];
                                } Failed:^(NSError *error) {
                                    if (error) {
                                        [WLHUDView showErrorHUD:error.localizedDescription];
                                    }else{
                                        [WLHUDView showErrorHUD:@"点赞失败，请重试！"];
                                    }
                                }];
    }else{
        //取消赞
        [WeLianClient deleteProjectZanWithPid:_projectPid
                                      Success:^(id resultInfo) {
                                          [WLHUDView hiddenHud];
                                          
                                          _iProjectDetailInfo.iszan = @(0);
                                          _iProjectDetailInfo.zancount = @(_iProjectDetailInfo.zancount.integerValue - 1);
                                          [_projectDetailInfo updateZancount:_iProjectDetailInfo.zancount];
                                          
                                          if (_projectInfo) {
                                              //更新点赞状态和数量
                                              [_projectInfo updateIsZanAndZanCount:NO];
                                          }
                                          
                                          IBaseUserM *zanUser = [zanUsers bk_match:^BOOL(id obj) {
                                              return [obj uid].integerValue == loginUser.uid.integerValue;
                                          }];
                                          if (zanUser) {
                                              [zanUsers removeObject:zanUser];
                                              
                                              _iProjectDetailInfo.zanusers = [NSArray arrayWithArray:zanUsers];
                                              
                                              //刷新
                                              if (_iProjectDetailInfo.zancount.integerValue <= 1) {
                                                  //如果之前没有刷新整个table
                                                  [_tableView reloadData];
                                              }else{
                                                  [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                                              }
                                          }
                                          
                                          [self checkZanStatus];
                                          
                                          [self updateUI];
                                      } Failed:^(NSError *error) {
                                          if (error) {
                                              [WLHUDView showErrorHUD:error.localizedDescription];
                                          }else{
                                              [WLHUDView showErrorHUD:@"取消赞失败，请重试！"];
                                          }
                                      }];
    }
    
}

/**
 *  评论项目
 *
 *  @param sender 触发的按钮
 */
- (void)commentBtnClicked:(UIButton *)sender
{
    _selecCommFrame = nil;
    _selectIndex = nil;
    [self.messageView.commentTextView becomeFirstResponder];
}

/**
 *  收藏
 *
 *  @param sender 触发的按钮
 */
- (void)favorteBtnClicked:(UIButton *)sender
{
    if (_iProjectDetailInfo.isfavorite.boolValue) {
        //取消收藏
        [WLHUDView showHUDWithStr:@"取消收藏中..." dim:NO];
        [WeLianClient deleteProjectFavoriteWithPid:_projectPid
                                           Success:^(id resultInfo) {
                                               [WLHUDView hiddenHud];
                                               
                                               _iProjectDetailInfo.isfavorite = @(0);
                                               [self checkFavorteStatus];
                                               if (self.favoriteBlock) {
                                                   self.favoriteBlock();
                                               }
                                           } Failed:^(NSError *error) {
                                               if (error) {
                                                   [WLHUDView showErrorHUD:error.localizedDescription];
                                               }else{
                                                   [WLHUDView showErrorHUD:@"取消收藏失败，请重试！"];
                                               }
                                           }];
    }else{
        //收藏项目
        [WLHUDView showHUDWithStr:@"收藏中..." dim:NO];
        [WeLianClient favoriteProjectWithPid:_projectPid
                                     Success:^(id resultInfo) {
                                         [WLHUDView hiddenHud];
                                         
                                         _iProjectDetailInfo.isfavorite = @(1);
                                         [self checkFavorteStatus];
                                     } Failed:^(NSError *error) {
                                         if (error) {
                                             [WLHUDView showErrorHUD:error.localizedDescription];
                                         }else{
                                             [WLHUDView showErrorHUD:@"收藏项目失败，请重试！"];
                                         }
                                     }];
    }
    
}

//检测是否点赞
- (void)checkZanStatus
{
    if (_iProjectDetailInfo.iszan.boolValue) {
        [_zanBtn setTitle:@"已赞" forState:UIControlStateNormal];
        [_zanBtn setImage:[UIImage imageNamed:@"me_mywriten_good_pre"] forState:UIControlStateNormal];
    }else{
        [_zanBtn setTitle:@"点赞" forState:UIControlStateNormal];
        [_zanBtn setImage:[UIImage imageNamed:@"me_mywriten_good"] forState:UIControlStateNormal];
    }
}

//检测是否收藏当前项目
- (void)checkFavorteStatus
{
    if (_iProjectDetailInfo.isfavorite.boolValue) {
        [_favorteBtn setTitle:@"已收藏" forState:UIControlStateNormal];
        [_favorteBtn setImage:[UIImage imageNamed:@"me_mywriten_shoucang_pre"] forState:UIControlStateNormal];
    }else{
        [_favorteBtn setTitle:@"收藏" forState:UIControlStateNormal];
        [_favorteBtn setImage:[UIImage imageNamed:@"me_mywriten_shoucang"] forState:UIControlStateNormal];
    }
}

/**
 *  现实项目信息
 */
- (void)showProjectInfo
{
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    
    //认证投资人或者自己创建的项目可以查看融资信息  /**  投资者认证  0 默认状态  1  认证成功  -2 正在审核  -1 认证失败 */
    if (loginUser.investorauth.integerValue == 1 || loginUser.uid.integerValue == _projectDetailInfo.rsProjectUser.uid.integerValue || loginUser.uid.integerValue == _iProjectDetailInfo.user.uid.integerValue || loginUser.uid.integerValue == _projectInfo.rsProjectUser.uid.integerValue) {
//        [self openProjectDetailInfoView];
        [self lookProjectFinancingInfo];
    }else{
        [UIAlertView bk_showAlertViewWithTitle:@""
                                       message:@"您不是认证投资人，无法查看融资信息"
                             cancelButtonTitle:@"取消"
                             otherButtonTitles:@[@"去认证"]
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           if (buttonIndex == 0) {
                                               return ;
                                           }else{
                                               InvestCerVC *investVC = [[InvestCerVC alloc] initWithStyle:UITableViewStyleGrouped];
                                               [self.navigationController pushViewController:investVC animated:YES];
                                           }
                                       }];
    }
}

//查看项目融资信息
- (void)lookProjectFinancingInfo
{
    FinancingInfoViewController *financingInfoVC = [[FinancingInfoViewController alloc] initWithProjectInfo:_iProjectDetailInfo];
    [self.navigationController pushViewController:financingInfoVC animated:YES];
}

//关闭项目详情
- (void)closeProjectDetailInfoView
{
    _projectDetailInfoView.hidden = YES;
}

- (void)openProjectDetailInfoView
{
    _projectDetailInfoView.projectDetailInfo = _iProjectDetailInfo;
    _projectDetailInfoView.hidden = NO;
}

//获取详情信息
- (void)initData{
    
    if (!_projectPid.integerValue) {
        UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:@"" message:@"该项目已经被删除！"];
        [alert bk_addButtonWithTitle:@"确定" handler:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert show];
        return;
    }

    [WeLianClient getProjectDetailInfoWithID:_projectPid
                                     Success:^(id resultInfo) {
                                         //隐藏
                                         [self.tableView.header endRefreshing];
                                         
                                        
                                         
                                         IProjectDetailInfo *detailInfo = resultInfo;
                                         self.iProjectDetailInfo = resultInfo;
                                         //存入本地数据库
                                         self.projectInfo = [ProjectInfo createProjectInfosWith:detailInfo withType:@(0)];
                                         self.projectDetailInfo = [ProjectDetailInfo createWithIProjectDetailInfo:detailInfo];
                                         
                                         //添加分享按钮
                                         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_more"] style:UIBarButtonItemStyleBordered target:self action:@selector(shareBtnClicked)];
                                         
                                         NSMutableArray *dataAM = [NSMutableArray arrayWithCapacity:detailInfo.comments.count];
                                         for (CommentMode *commentInfo in detailInfo.comments) {
                                             
//                                             CommentMode *commentM = [[CommentMode alloc] init];
//                                             commentM.cid = commentInfo.cid;
//                                             commentM.comment = commentInfo.comment;
//                                             commentM.created = commentInfo.created;
//                                             if (commentInfo.user.uid) {
//                                                 commentM.user = commentInfo.user;
//                                             }
//                                             if (commentInfo.touser.uid) {
//                                                 commentM.touser = commentInfo.touser;
//                                             }
                                             
                                             CommentCellFrame *commentFrame = [[CommentCellFrame alloc] init];
                                             [commentFrame setCommentM:commentInfo];
                                             
                                             [dataAM addObject:commentFrame];
                                         }
                                         self.datasource = dataAM;
                                         if (dataAM.count >= detailInfo.commentcount.integerValue) {
                                             [self.tableView.footer setHidden:YES];
                                         }else{
                                             [self.tableView.footer setHidden:NO];
                                         }
                                         [_tableView reloadData];
                                         
                                         [self updateUI];
                                     } Failed:^(NSError *error) {
                                         //隐藏
                                         [self.tableView.header endRefreshing];
                                         if (error) {
                                             [WLHUDView showErrorHUD:error.localizedDescription];
                                         }else{
                                             [WLHUDView showErrorHUD:@"获取详情失败，请刷新重试！"];
                                         }
                                     }];
}

//初始化页面展示
- (void)initUI
{
    //设置头部内容
    CGFloat detailHeight = _projectInfo ? [ProjectDetailView configureWithInfo:_projectInfo.des Images:nil] : [ProjectDetailView configureWithInfo:_iProjectInfo.des Images:nil];
    CGFloat projectInfoViewHeight =  _projectInfo ? [ProjectInfoView configureWithProjectInfo:_projectInfo] : [ProjectInfoView configureWithIProjectInfo:_iProjectInfo];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, self.view.width,projectInfoViewHeight + detailHeight)];
    ProjectInfoView *projectInfoView = [[ProjectInfoView alloc] initWithFrame:Rect(0, 0, self.view.width,projectInfoViewHeight)];
    if (_projectInfo) {
        projectInfoView.projectInfo = _projectInfo;
    }
    if (_iProjectInfo) {
        projectInfoView.iProjectInfo = _iProjectInfo;
    }
    //设置底部边框线
    projectInfoView.layer.borderColorFromUIColor = RGB(229.f, 229.f, 229.f);//RGB(173.f, 173.f, 173.f);
    projectInfoView.layer.borderWidths = @"{0,0,0.5,0}";
    
    //项目详情
    ProjectDetailView *projectDetailView = [[ProjectDetailView alloc] initWithFrame:Rect(0, projectInfoViewHeight, self.view.width, detailHeight)];
    if (_projectInfo) {
        projectDetailView.projectInfo = _projectInfo;
    }
    if (_iProjectInfo) {
        projectDetailView.iProjectInfo = _iProjectInfo;
    }
    
    [headView addSubview:projectInfoView];
    [headView addSubview:projectDetailView];
    [_tableView setTableHeaderView:headView];
}
//更新也没展示
- (void)updateUI{
    //设置头部内容
    CGFloat detailHeight = [ProjectDetailView configureWithInfo:_projectDetailInfo.des Images:_projectDetailInfo.rsPhotoInfos.allObjects];
    CGFloat projectInfoViewHeight = [ProjectInfoView configureWithInfo:_projectDetailInfo];//_projectInfo.status.boolValue ? kHeaderHeight : kHeaderHeight2;
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, self.view.width,projectInfoViewHeight + detailHeight + kSegementedControlHeight)];
    ProjectInfoView *projectInfoView = [[ProjectInfoView alloc] initWithFrame:Rect(0, 0, self.view.width,projectInfoViewHeight)];
    projectInfoView.projectDetailInfo = _projectDetailInfo;
    if (_projectDetailInfo.des.length > 0 || _projectDetailInfo.rsPhotoInfos.count > 0) {
        //设置底部边框线
        projectInfoView.layer.borderColorFromUIColor = RGB(229.f, 229.f, 229.f);//RGB(173.f, 173.f, 173.f);
        projectInfoView.layer.borderWidths = @"{0,0,0.5,0}";
    }
    WEAKSELF;
    [projectInfoView setInfoBlock:^(void){
        [weakSelf showProjectInfo];
    }];
    [projectInfoView setUserShowBlock:^(void){
        [weakSelf showProjectUserInfo];
    }];
    
    //项目详情
    ProjectDetailView *projectDetailView = [[ProjectDetailView alloc] initWithFrame:Rect(0, projectInfoView.bottom, self.view.width, detailHeight)];
    projectDetailView.projectDetailInfo = _projectDetailInfo;
    [projectDetailView setImageClickedBlock:^(NSIndexPath *indexPath,NSArray *photos){
        [weakSelf showDetailImagesWithIndex:indexPath Photos:photos];
    }];
    
    //操作栏
    NSString *linkImage = _projectDetailInfo.website.length > 0 ? @"discovery_xiangmu_detail_link" : @"discovery_xiangmu_detail_nolink";
    NSString *memeberImage = _projectDetailInfo.membercount.integerValue > 0 ? @"discovery_xiangmu_detail_member" : @"discovery_xiangmu_detail_nomember";
    WLSegmentedControl *segementedControl = [[WLSegmentedControl alloc] initWithFrame:Rect(0,projectDetailView.bottom,self.view.width,kSegementedControlHeight) Titles:@[@"项目网址",[NSString stringWithFormat:@"团队成员(%d)",[_projectDetailInfo.membercount intValue]]] Images:@[[UIImage imageNamed:linkImage],[UIImage imageNamed:memeberImage]] Bridges:nil isHorizontal:YES];
    segementedControl.delegate = self;
    //设置底部边框线
    segementedControl.layer.borderColorFromUIColor = RGB(229.f, 229.f, 229.f);
    segementedControl.layer.borderWidths = @"{0.5,0,0.5,0}";
    
    [headView addSubview:projectInfoView];
    [headView addSubview:projectDetailView];
    [headView addSubview:segementedControl];
    [_tableView setTableHeaderView:headView];
    
    //判断赞按钮状态
    [self checkZanStatus];
    //判断收藏状态
    [self checkFavorteStatus];
}

//显示项目创建人的信息
- (void)showProjectUserInfo
{
    //系统联系人
//    UserInfoBasicVC *userInfoVC = [[UserInfoBasicVC alloc] initWithStyle:UITableViewStyleGrouped andUsermode:_iProjectDetailInfo.user isAsk:NO];
//    [self.navigationController pushViewController:userInfoVC animated:YES];
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] initWithBaseUserM:_iProjectDetailInfo.user OperateType:nil HidRightBtn:NO];
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

//展示项目图片
- (void)showDetailImagesWithIndex:(NSIndexPath *)indexPath Photos:(NSArray *)photos{
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

//选择点赞的列表
- (void)selectZanUserWithUser:(IBaseUserM *)user showList:(BOOL)showList
{
    if (showList) {
        if (_projectDetailInfo.zancount.integerValue > 0) {
            //进入赞列表
            ProjectUserListViewController *projectUserListVC = [[ProjectUserListViewController alloc] init];
            projectUserListVC.infoType = UserInfoTypeProjectZan;
            projectUserListVC.projectDetailInfo = _iProjectDetailInfo;
            [self.navigationController pushViewController:projectUserListVC animated:YES];
        }
    }else{
        //系统联系人
//        UserInfoBasicVC *userInfoVC = [[UserInfoBasicVC alloc] initWithStyle:UITableViewStyleGrouped andUsermode:user isAsk:NO];
        UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] initWithBaseUserM:user OperateType:nil HidRightBtn:NO];
        [self.navigationController pushViewController:userInfoVC animated:YES];
    }
}

//加载更多评论
- (void)loadMoreCommentData
{
//    if (_datasource.count < _iProjectDetailInfo.commentcount.integerValue) {
    _pageIndex++;
    [WeLianClient getProjectCommentListWithPid:_projectPid
                                          Page:@(_pageIndex)
                                          Size:@(_pageSize)
                                       Success:^(id resultInfo) {
                                           //隐藏加载更多动画
                                           [self.tableView.footer endRefreshing];
                                           
                                           if ([resultInfo count] > 0) {
                                               for (CommentMode *commentInfo in resultInfo) {
//                                                   CommentMode *commentM = [[CommentMode alloc] init];
//                                                   commentM.cid = commentInfo.cid;
//                                                   commentM.comment = commentInfo.comment;
//                                                   commentM.created = commentInfo.created;
//                                                   if (commentInfo.user.uid) {
//                                                       commentM.user = commentInfo.user;
//                                                   }
//                                                   if (commentInfo.touser.uid) {
//                                                       commentM.touser = commentInfo.touser;
//                                                   }
                                                   
                                                   CommentCellFrame *commentFrame = [[CommentCellFrame alloc] init];
                                                   [commentFrame setCommentM:commentInfo];
                                                   
                                                   [_datasource addObject:commentFrame];
                                               }
                                               
                                               if (_datasource.count >= _iProjectDetailInfo.commentcount.integerValue) {
                                                   [self.tableView.footer setHidden:YES];
                                               }else{
                                                   [self.tableView.footer setHidden:NO];
                                               }
                                               //刷新列表
                                               [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                                           }
                                       } Failed:^(NSError *error) {
                                           //隐藏加载更多动画
                                           [self.tableView.footer endRefreshing];
                                       }];
}

//隐藏键盘
- (void)hideKeyBoard
{
    //处理
    _selectIndex = nil;
    //清空输入框内容
    _messageView.commentTextView.internalTextView.text = @"";
    
    //取消手势
    [_tableView removeGestureRecognizer:self.tapGesture];
    
    //显示下方的操作栏
    _operateToolBar.hidden = NO;
    
    [self.messageView dismissKeyBoard];
    [self.messageView startCompile:nil];
}

//键盘监听 改变
- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y - toolBarHeight;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    _tableView.frame = newTextViewFrame;
//    [_tableView setDebug:YES];
    [UIView commitAnimations];
    
    //设置
    if (_selectIndex) {
        [_tableView scrollToRowAtIndexPath:_selectIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }else{
        if (_iProjectDetailInfo.zancount.integerValue < 1) {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_datasource.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }else{
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_datasource.count - 1) inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
    //添加手势
    [_tableView addGestureRecognizer:self.tapGesture];
    //隐藏下方的操作栏
    _operateToolBar.hidden = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    //    textView.frame = self.view.bounds;
    _tableView.frame = Rect(0.f,0.f,self.view.width,self.view.height - toolBarHeight);
    [UIView commitAnimations];
}

@end
