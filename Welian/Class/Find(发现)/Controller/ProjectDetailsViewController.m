//
//  ProjectDetailsViewController.m
//  Welian
//
//  Created by weLian on 15/2/2.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectDetailsViewController.h"
#import "ProjectInfoView.h"
#import "ProjectDetailView.h"
#import "WLSegmentedControl.h"
#import "CommentCell.h"
#import "NoCommentCell.h"
#import "ProjectFavorteViewCell.h"
#import "ShareEngine.h"
#import "LXActivity.h"
#import "ProjectDetailInfoView.h"
#import "UserInfoBasicVC.h"
#import "ProjectUserListViewController.h"
#import "TOWebViewController.h"
#import "MessageKeyboardView.h"
#import "MJRefresh.h"

//#import "WLPhotoView.h"
//#import "WLPhoto.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"

#define kHeaderHeight 133.f
#define kHeaderHeight2 93.f
#define kSegementedControlHeight 40.f
#define kTableViewHeaderHeight 30.f

static NSString *noCommentCell = @"NoCommentCell";

@interface ProjectDetailsViewController ()<WLSegmentedControlDelegate,UITableViewDelegate,UITableViewDataSource,LXActivityDelegate>

@property (assign,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *datasource;
@property (strong,nonatomic) IProjectInfo *projectInfo;
@property (assign,nonatomic) ProjectDetailInfoView *projectDetailInfoView;

@property (strong,nonatomic) IProjectDetailInfo *detailInfo;
@property (strong,nonatomic) CommentCellFrame *selecCommFrame;

@property (assign,nonatomic) UIButton *favorteBtn;
@property (assign,nonatomic) UIButton *zanBtn;
@property (strong,nonatomic) NSIndexPath *selectIndex;
@property (strong,nonatomic) UITapGestureRecognizer *tapGesture;

@property (strong,nonatomic) MessageKeyboardView *messageView;

@property (assign,nonatomic) NSInteger pageIndex;
@property (assign,nonatomic) NSInteger pageSize;

@end

@implementation ProjectDetailsViewController

- (void)dealloc
{
    _datasource = nil;
    _projectInfo = nil;
    _detailInfo = nil;
    _selecCommFrame = nil;
    _messageView = nil;
    _selectIndex = nil;
    _tapGesture = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}

- (NSString *)title
{
    return @"详情";
}

- (UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture) {
        //添加屏幕点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            //隐藏键盘
            [self.messageView dismissKeyBoard];
            [self.messageView startCompile:nil];
        }];
        self.tapGesture = tap;
    }
    return _tapGesture;
}

- (instancetype)initWithProjectInfo:(IProjectInfo *)projectInfo
{
    self = [super init];
    if (self) {
        self.projectInfo = projectInfo;
        self.pageIndex = 1;
        self.pageSize = 10;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //删除键盘监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //添加分享按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_more"] style:UIBarButtonItemStyleBordered target:self action:@selector(shareBtnClicked)];
    
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
            params = @{@"pid":_projectInfo.pid,@"touid":_selecCommFrame.commentM.user.uid,@"comment":comment};
            
            WLBasicTrends *touser = [[WLBasicTrends alloc] init];
            touser.avatar = _selecCommFrame.commentM.user.avatar;
            touser.company = _selecCommFrame.commentM.user.company;
            touser.investorauth = _selecCommFrame.commentM.user.investorauth;
            touser.name = _selecCommFrame.commentM.user.name;
            touser.position = _selecCommFrame.commentM.user.position;
            touser.uid = _selecCommFrame.commentM.user.uid;
            commentM.touser = touser;
        }else{
            params = @{@"pid":_projectInfo.pid,@"comment":comment};
        }
        
        LogInUser *loginUser = [LogInUser getCurrentLoginUser];
        WLBasicTrends *user = [[WLBasicTrends alloc] init];
        user.avatar = loginUser.avatar;
        user.company = loginUser.company;
        user.investorauth = loginUser.investorauth.intValue;
        user.name = loginUser.name;
        user.position = loginUser.position;
        user.uid = loginUser.uid;
        commentM.user = user;
        
        [WLHttpTool commentProjectParameterDic:params
                                       success:^(id JSON) {
                                           commentM.fcid = JSON[@"pcid"];
                                           
                                           CommentCellFrame *commentFrame = [[CommentCellFrame alloc] init];
                                           [commentFrame setCommentM:commentM];
                                           [_datasource insertObject:commentFrame atIndex:0];
                                           
                                           //刷新列表
                                           _detailInfo.commentcount = @(_detailInfo.commentcount.integerValue + 1);
                                           [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                                       } fail:^(NSError *error) {
                                           [UIAlertView showWithTitle:@"系统提示" message:@"评论失败，请重试！"];
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
    
    //项目详细信息
    ProjectDetailInfoView *projectDetailInfoView = [[ProjectDetailInfoView alloc] initWithFrame:self.navigationController.view.frame];
    projectDetailInfoView.hidden = YES;
    [self.navigationController.view addSubview:projectDetailInfoView];
    self.projectDetailInfoView = projectDetailInfoView;
    WEAKSELF;
    [projectDetailInfoView setCloseBlock:^(){
        [weakSelf closeProjectDetailInfoView];
    }];
    
    //获取数据
    [self initData];
    
    //上提加载更多
    [self.tableView addFooterWithTarget:self action:@selector(loadMoreCommentData)];
}

//获取按钮对象
- (UIButton *)getBtnWithTitle:(NSString *)title image:(UIImage *)image{
    UIButton *favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    favoriteBtn.backgroundColor = [UIColor clearColor];
    favoriteBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
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
    [self.messageView dismissKeyBoard];
    [self.messageView startCompile:nil];
}

#pragma mark - UITableView Datasource&Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else{
        if (_datasource.count == 0) {
            return 1;
        }else{
            return _datasource.count;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"赞过的人";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:Rect(.0f, .0f, self.view.width, kTableViewHeaderHeight)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    titleLabel.text = section == 0 ? @"赞过的人" : [NSString stringWithFormat:@"评论 (%d)",_detailInfo.commentcount.intValue];
    [titleLabel sizeToFit];
    titleLabel.left = 15.f;
    titleLabel.centerY = headerView.height / 2.f;
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (_detailInfo.zancount.intValue < 1) {
            //无
            NoCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:noCommentCell];
            cell.msgLabel.text = @"还没有点赞的人~";
            cell.layer.borderColorFromUIColor = RGB(231.f, 231.f, 231.f);
            cell.layer.borderWidths = @"{0,0,0.5,0}";
            return cell;
        }else{
            //赞过的人
            static NSString *cellIdentifier = @"Project_Favorte_View_Cell";
            ProjectFavorteViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[ProjectFavorteViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.projectInfo = _detailInfo;
            WEAKSELF;
            [cell setBlock:^(NSIndexPath *indexPath){
                [weakSelf selectZanUserWithIndex:indexPath];
            }];
            return cell;
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
            cell.msgLabel.text = @"还没有评论哦~";
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
    
    UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:nil];
    if (selecCommFrame.commentM.user.uid.integerValue == [LogInUser getCurrentLoginUser].uid.integerValue) {
        [sheet bk_setDestructiveButtonWithTitle:@"删除" handler:^{
            [WLHttpTool deleteProjectCommentParameterDic:@{@"pcid":selecCommFrame.commentM.fcid}
                                                 success:^(id JSON) {
                                                     //删除当前对象
                                                     [_datasource removeObject:selecCommFrame];
                                                     
                                                     //刷新列表
                                                     _detailInfo.commentcount = @(_detailInfo.commentcount.integerValue - 1);
                                                     [_tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                                                 } fail:^(NSError *error) {
                                                     [UIAlertView showWithTitle:@"系统提示" message:@"删除失败，请重试！"];
                                                 }];
        }];
    }else{
        [sheet bk_addButtonWithTitle:@"回复" handler:^{
            self.selecCommFrame = selecCommFrame;
            [self.messageView startCompile:_selecCommFrame.commentM.user];
        }];
    }
    [sheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [sheet showInView:self.view];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableViewHeaderHeight;
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
    if (indexPath.section == 0) {
        return 40.f;
    }
    if (_datasource.count > 0) {
        return [_datasource[indexPath.row] cellHeight];
    }else{
        return 60.f;
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
            if (_detailInfo.website.length > 0) {
                TOWebViewController *webVC = [[TOWebViewController alloc] initWithURLString:@"http://m.huxiu.com/"];
                webVC.navigationButtonsHidden = YES;//隐藏底部操作栏目
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }
            break;
        case 1:
        {
            //项目成员
            if (_detailInfo.membercount.integerValue > 0) {
                ProjectUserListViewController *projectUserListVC = [[ProjectUserListViewController alloc] init];
                projectUserListVC.infoType = UserInfoTypeProjectGroup;
                projectUserListVC.projectDetailInfo = _detailInfo;
                [self.navigationController pushViewController:projectUserListVC animated:YES];
            }
        }
            break;
        default:
            break;
    }
}

- (void)didClickOnImageIndex:(NSString *)imageIndex
{
    DLog(@"选择的项目：%@",imageIndex);
    if ([imageIndex isEqualToString:@"微信好友"]) {
        
    }
    if ([imageIndex isEqualToString:@"微信朋友圈"]) {
        
    }
    if ([imageIndex isEqualToString:@"设置融资信息"]) {
        
    }
    if ([imageIndex isEqualToString:@"设置团队成员"]) {
        
    }
    if ([imageIndex isEqualToString:@"编辑项目信息"]) {
        
    }
}

#pragma mark - Private
/**
 *  分享
 */
- (void)shareBtnClicked
{
    NSArray *buttons = [NSArray array];
    if ([LogInUser getCurrentLoginUser].uid.integerValue == _detailInfo.user.uid.integerValue) {
        buttons = @[@"编辑项目信息",@"设置团队成员",@"设置融资信息"];
    }
    LXActivity *lxActivity = [[LXActivity alloc] initWithDelegate:self WithTitle:@"分享到" otherButtonTitles:buttons ShareButtonTitles:@[@"微信好友",@"微信朋友圈"] withShareButtonImagesName:@[@"home_repost_wechat",@"home_repost_friendcirle"]];
    [lxActivity showInView:[UIApplication sharedApplication].keyWindow];
}

/**
 *  点赞
 *
 *  @param sender 触发的按钮
 */
- (void)zanBtnClicked:(UIButton *)sender
{
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    NSMutableArray *zanUsers = [NSMutableArray arrayWithArray:_detailInfo.zanusers];
    if (!_detailInfo.isZan.boolValue) {
        //赞
        [WLHttpTool zanProjectParameterDic:@{@"pid":_detailInfo.pid}
                                   success:^(id JSON) {
                                       _detailInfo.isZan = @(1);
                                       _detailInfo.zancount = @(_detailInfo.zancount.integerValue + 1);
                                       
                                       IBaseUserM *zanUser = [[IBaseUserM alloc] init];
                                       zanUser.avatar = loginUser.avatar;
                                       zanUser.name = loginUser.name;
                                       zanUser.uid = loginUser.uid;
                                       zanUser.position = loginUser.position;
                                       zanUser.company = loginUser.company;
                                       zanUser.investorauth = loginUser.investorauth;
                                       //插入
                                       [zanUsers insertObject:zanUser atIndex:0];
                                       _detailInfo.zanusers = [NSArray arrayWithArray:zanUsers];
                                       
                                       //刷新
                                       [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                                       
                                       [self checkZanStatus];
                                       
                                       [self updateUI];
                                   } fail:^(NSError *error) {
                                       [UIAlertView showWithTitle:@"系统提示" message:@"点赞失败，请重试！"];
                                   }];
    }else{
        //取消赞
        [WLHttpTool deleteProjectZanParameterDic:@{@"pid":_detailInfo.pid}
                                         success:^(id JSON) {
                                             _detailInfo.isZan = @(0);
                                             _detailInfo.zancount = @(_detailInfo.zancount.integerValue - 1);
                                             
                                             IBaseUserM *zanUser = [zanUsers bk_match:^BOOL(id obj) {
                                                 return [obj uid].integerValue == loginUser.uid.integerValue;
                                             }];
                                             if (zanUser) {
                                                 [zanUsers removeObject:zanUser];
                                                 
                                                 _detailInfo.zanusers = [NSArray arrayWithArray:zanUsers];
                                                 
                                                 //刷新
                                                 [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                                             }
                                             
                                             [self checkZanStatus];
                                             
                                             [self updateUI];
                                         } fail:^(NSError *error) {
                                             [UIAlertView showWithTitle:@"系统提示" message:@"取消赞失败，请重试！"];
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
    if (_detailInfo.isFavorite.boolValue) {
        //取消收藏
        [WLHttpTool deleteFavoriteProjectParameterDic:@{@"pid":_detailInfo.pid}
                                              success:^(id JSON) {
                                                  _detailInfo.isFavorite = @(0);
                                                  [self checkFavorteStatus];
                                              } fail:^(NSError *error) {
                                                  [UIAlertView showWithTitle:@"系统提示" message:@"取消收藏失败，请重试！"];
                                              }];
    }else{
        //收藏项目
        [WLHttpTool favoriteProjectParameterDic:@{@"pid":_detailInfo.pid}
                                        success:^(id JSON) {
                                            _detailInfo.isFavorite = @(1);
                                            [self checkFavorteStatus];
                                        } fail:^(NSError *error) {
                                            [UIAlertView showWithTitle:@"系统提示" message:@"收藏项目失败，请重试！"];
                                        }];
    }
    
}

//检测是否点赞
- (void)checkZanStatus
{
    if (_detailInfo.isZan.boolValue) {
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
    if (_detailInfo.isFavorite.boolValue) {
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
    //认证投资人
    if ([LogInUser getCurrentLoginUser].isinvestorbadge.boolValue) {
        [self openProjectDetailInfoView];
    }else{
        [UIAlertView bk_showAlertViewWithTitle:nil
                                       message:@"您还不是认证投资人，无法查看融资信息"
                             cancelButtonTitle:@"取消"
                             otherButtonTitles:@[@"去认证"]
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           if (buttonIndex == 0) {
                                               return ;
                                           }else{
                                               [self openProjectDetailInfoView];
                                           }
                                       }];
    }
}

//关闭项目详情
- (void)closeProjectDetailInfoView
{
    _projectDetailInfoView.hidden = YES;
}

- (void)openProjectDetailInfoView
{
    _projectDetailInfoView.projectInfo = _detailInfo;
    _projectDetailInfoView.hidden = NO;
}

- (void)initData{
    [WLHttpTool getProjectDetailParameterDic:@{@"pid":_projectInfo.pid}
                                     success:^(id JSON) {
                                         IProjectDetailInfo *detailInfo = [IProjectDetailInfo objectWithDict:JSON];
                                         self.detailInfo = detailInfo;
                                         
                                         NSMutableArray *dataAM = [NSMutableArray arrayWithCapacity:detailInfo.comments.count];
                                         for (ICommentInfo *commentInfo in detailInfo.comments) {
                                             
                                             CommentMode *commentM = [[CommentMode alloc] init];
                                             commentM.fcid = commentInfo.pcid;
                                             commentM.comment = commentInfo.comment;
                                             commentM.created = commentInfo.created;
                                             if (commentInfo.user.uid) {
                                                 WLBasicTrends *user = [[WLBasicTrends alloc] init];
                                                 user.avatar = commentInfo.user.avatar;
                                                 user.company = commentInfo.user.company;
                                                 user.investorauth = commentInfo.user.investorauth.intValue;
                                                 user.name = commentInfo.user.name;
                                                 user.position = commentInfo.user.position;
                                                 user.uid = commentInfo.user.uid;
                                                 commentM.user = user;
                                             }
                                             if (commentInfo.touser.uid) {
                                                 WLBasicTrends *touser = [[WLBasicTrends alloc] init];
                                                 touser.avatar = commentInfo.touser.avatar;
                                                 touser.company = commentInfo.touser.company;
                                                 touser.investorauth = commentInfo.touser.investorauth.intValue;
                                                 touser.name = commentInfo.touser.name;
                                                 touser.position = commentInfo.touser.position;
                                                 touser.uid = commentInfo.touser.uid;
                                                 commentM.touser = touser;
                                             }
                                             
                                             CommentCellFrame *commentFrame = [[CommentCellFrame alloc] init];
                                             [commentFrame setCommentM:commentM];
                                             
                                             [dataAM addObject:commentFrame];
                                         }
                                         self.datasource = dataAM;
                                         
                                         [self updateUI];
                                         [_tableView reloadData];
                                     } fail:^(NSError *error) {
                                         [UIAlertView showWithTitle:@"系统提示" message:@"获取详情失败，请重试！"];
                                     }];
}

- (void)updateUI{
//    NSMutableArray *photos = [NSMutableArray array];
//    for (int i = 0; i < 4; i++) {
//        IPhotoInfo *photoInfo = [[IPhotoInfo alloc] init];
//        photoInfo.photo = @"http://img.welian.com/1422523516797-200-92_x.jpg";
//        [photos addObject:photoInfo];
//    }
//    _detailInfo.photos = [NSArray arrayWithArray:photos];
//    _detailInfo.zancount = @(147100);
    //设置头部内容
    CGFloat detailHeight = [ProjectDetailView configureWithInfo:_detailInfo.des Images:_detailInfo.photos];
    CGFloat projectInfoViewHeight = _projectInfo.status.boolValue ? kHeaderHeight : kHeaderHeight2;
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, self.view.width,projectInfoViewHeight + detailHeight + kSegementedControlHeight)];
    ProjectInfoView *projectInfoView = [[ProjectInfoView alloc] initWithFrame:Rect(0, 0, self.view.width,projectInfoViewHeight)];
    projectInfoView.projectInfo = _detailInfo;
    //设置底部边框线
    projectInfoView.layer.borderColorFromUIColor = RGB(229.f, 229.f, 229.f);//RGB(173.f, 173.f, 173.f);
    projectInfoView.layer.borderWidths = @"{0,0,0.5,0}";
    WEAKSELF;
    [projectInfoView setInfoBlock:^(void){
        [weakSelf showProjectInfo];
    }];
    [projectInfoView setUserShowBlock:^(void){
        [weakSelf showProjectUserInfo];
    }];
    
    ProjectDetailView *projectDetailView = [[ProjectDetailView alloc] initWithFrame:Rect(0, projectInfoView.bottom, self.view.width, detailHeight)];
    projectDetailView.projectInfo = _detailInfo;
    [projectDetailView setImageClickedBlock:^(NSIndexPath *indexPath,WLPhotoView *imageView){
        [weakSelf showDetailImagesWithIndex:indexPath imageView:imageView];
    }];
    
    //操作栏
    NSString *linkImage = _detailInfo.website.length > 0 ? @"discovery_xiangmu_detail_link" : @"discovery_xiangmu_detail_nolink";
    NSString *memeberImage = _detailInfo.membercount.integerValue > 0 ? @"discovery_xiangmu_detail_member" : @"discovery_xiangmu_detail_nomember";
    WLSegmentedControl *segementedControl = [[WLSegmentedControl alloc] initWithFrame:Rect(0,projectDetailView.bottom,self.view.width,kSegementedControlHeight) Titles:@[@"项目网址",[NSString stringWithFormat:@"团队成员(%d)",[_detailInfo.membercount intValue]]] Images:@[[UIImage imageNamed:linkImage],[UIImage imageNamed:memeberImage]] Bridges:nil isHorizontal:YES];
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
    UserInfoBasicVC *userInfoVC = [[UserInfoBasicVC alloc] initWithStyle:UITableViewStyleGrouped andUsermode:_detailInfo.user isAsk:NO];
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

//展示项目图片
- (void)showDetailImagesWithIndex:(NSIndexPath *)indexPath imageView:(WLPhotoView *)photoView
{
    NSMutableArray *photos = [NSMutableArray array];
    for (int i = 0; i< _detailInfo.photos.count; i++) {
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:[_detailInfo.photos[i] photo]];
        photo.srcImageView = photoView; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

//选择点赞的列表
- (void)selectZanUserWithIndex:(NSIndexPath *)indexPath
{
    if (indexPath.row == _detailInfo.zanusers.count) {
        if (_detailInfo.zancount.integerValue > 0) {
            //进入赞列表
            ProjectUserListViewController *projectUserListVC = [[ProjectUserListViewController alloc] init];
            projectUserListVC.infoType = UserInfoTypeProjectZan;
            projectUserListVC.projectDetailInfo = _detailInfo;
            [self.navigationController pushViewController:projectUserListVC animated:YES];
        }
    }else{
        //点击点赞的人，进入
        IBaseUserM *user = _detailInfo.zanusers[indexPath.row];
        //系统联系人
        UserInfoBasicVC *userInfoVC = [[UserInfoBasicVC alloc] initWithStyle:UITableViewStyleGrouped andUsermode:user isAsk:NO];
        [self.navigationController pushViewController:userInfoVC animated:YES];
    }
}

//加载更多评论
- (void)loadMoreCommentData
{
    if (_datasource.count < _detailInfo.commentcount.integerValue) {
        _pageIndex++;
        [WLHttpTool getProjectCommentsParameterDic:@{@"pid":_detailInfo.pid,@"page":@(_pageIndex),@"size":@(_pageSize)}
                                           success:^(id JSON) {
                                               //隐藏加载更多动画
                                               [self.tableView footerEndRefreshing];
                                               
                                               if (JSON) {
                                                   NSArray *comments = [ICommentInfo objectsWithInfo:JSON];
                                                   
                                                   for (ICommentInfo *commentInfo in comments) {
                                                       CommentMode *commentM = [[CommentMode alloc] init];
                                                       commentM.fcid = commentInfo.pcid;
                                                       commentM.comment = commentInfo.comment;
                                                       commentM.created = commentInfo.created;
                                                       if (commentInfo.user.uid) {
                                                           WLBasicTrends *user = [[WLBasicTrends alloc] init];
                                                           user.avatar = commentInfo.user.avatar;
                                                           user.company = commentInfo.user.company;
                                                           user.investorauth = commentInfo.user.investorauth.intValue;
                                                           user.name = commentInfo.user.name;
                                                           user.position = commentInfo.user.position;
                                                           user.uid = commentInfo.user.uid;
                                                           commentM.user = user;
                                                       }
                                                       if (commentInfo.touser.uid) {
                                                           WLBasicTrends *touser = [[WLBasicTrends alloc] init];
                                                           touser.avatar = commentInfo.touser.avatar;
                                                           touser.company = commentInfo.touser.company;
                                                           touser.investorauth = commentInfo.touser.investorauth.intValue;
                                                           touser.name = commentInfo.touser.name;
                                                           touser.position = commentInfo.touser.position;
                                                           touser.uid = commentInfo.touser.uid;
                                                           commentM.touser = touser;
                                                       }
                                                       
                                                       CommentCellFrame *commentFrame = [[CommentCellFrame alloc] init];
                                                       [commentFrame setCommentM:commentM];
                                                       
                                                       [_datasource addObject:commentFrame];
                                                   }
                                                   //刷新列表
                                                   [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                                               }
                                           } fail:^(NSError *error) {
                                               
                                           }];
    }else{
        //隐藏加载更多动画
        [self.tableView footerEndRefreshing];
        [self.tableView setFooterHidden:YES];
    }
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
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    //添加手势
    [_tableView addGestureRecognizer:self.tapGesture];
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
    //处理
    _selectIndex = nil;
    [_tableView removeGestureRecognizer:self.tapGesture];
}

@end
