//
//  ActivityNoPayConfirmViewController.m
//  Welian
//
//  Created by weLian on 15/6/10.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ActivityNoPayConfirmViewController.h"

#import "ActivityQuestionView.h"

#define kMarginLeft 15.f

@interface ActivityNoPayConfirmViewController ()

@property (strong,nonatomic) IActivityInfo *iActivityInfo;
@property (strong,nonatomic) NSArray *questInfos;
@property (assign,nonatomic) UIButton *confirmBtn;

@end

@implementation ActivityNoPayConfirmViewController

- (void)dealloc
{
    _questInfos = nil;
    _iActivityInfo = nil;
}

- (NSString *)title
{
    return @"确认信息";
}

- (instancetype)initWithIActivityInfo:(IActivityInfo *)iActivityInfo
{
    self = [super init];
    if (self) {
        self.iActivityInfo = iActivityInfo;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //注册键盘
    [DaiDodgeKeyboard addRegisterTheViewNeedDodgeKeyboard:self.view];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //移除監控
    [DaiDodgeKeyboard removeRegisterTheViewNeedDodgeKeyboard];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //tableview头部距离问题
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
//    IAskInfoMdoel *askInfo1 = [[IAskInfoMdoel alloc] init];
//    askInfo1.confid = @(1);
//    askInfo1.title = @"邮箱";
//    askInfo1.field = @"field1";
//    
//    IAskInfoMdoel *askInfo2 = [[IAskInfoMdoel alloc] init];
//    askInfo2.confid = @(2);
//    askInfo2.title = @"为什么要参加这个活动？";
//    askInfo2.field = @"field2";
//    
//    IAskInfoMdoel *askInfo3 = [[IAskInfoMdoel alloc] init];
//    askInfo3.confid = @(1);
//    askInfo3.title = @"为什么要参加这个活动？";
//    askInfo3.field = @"field3";
//    NSArray *datasources = @[askInfo1,askInfo2,askInfo3];
    
    self.view.backgroundColor = KBgLightGrayColor;
    
    UIScrollView *mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f, ViewCtrlTopBarHeight, self.view.width, self.view.height - ViewCtrlTopBarHeight)];
    mainView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainView];
    mainView.contentSize = mainView.bounds.size;
//    [mainView setDebug:YES];
    
    ActivityQuestionView *questionView = [[ActivityQuestionView alloc] initWithQuestions:_iActivityInfo.confs];
    questionView.frame = CGRectMake(0.f, 20.f, mainView.width, [ActivityQuestionView configureQuestionViewHeight:_iActivityInfo.confs]);
    [mainView addSubview:questionView];
//    [questionView setDebug:YES];
    WEAKSELF
    [questionView setCheckBlock:^(BOOL canJoin,NSArray *questInfos){
        [weakSelf checkInfoWith:canJoin QuestInfos:questInfos];
    }];
    
    UIButton *confirmBtn = [UIButton getBtnWithTitle:@"确认报名" image:nil];
    confirmBtn.frame = CGRectMake(kMarginLeft, questionView.bottom + 40.f, mainView.width - kMarginLeft * 2.f, 45.f);
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [confirmBtn addTarget:self action:@selector(confirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:confirmBtn];
    self.confirmBtn = confirmBtn;
    
    UITapGestureRecognizer *tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [[self.view findFirstResponder] resignFirstResponder];
    }];
    [self.view addGestureRecognizer:tap];
    
    //默认不能点击
    [self checkConfirmBtnEnable:NO];
}


- (void)checkInfoWith:(BOOL)canJoin QuestInfos:(NSArray *)questInfos
{
    self.questInfos = questInfos;
    [self checkConfirmBtnEnable:canJoin];
}

- (void)checkConfirmBtnEnable:(BOOL)enable
{
    _confirmBtn.enabled = enable;
    
    _confirmBtn.backgroundColor = _confirmBtn.enabled == NO ? KBgGrayColor : KBlueTextColor;
    _confirmBtn.layer.borderColor = _confirmBtn.enabled == NO ? KBgGrayColor.CGColor : KBlueTextColor.CGColor;
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

//报名
- (void)confirmBtnClicked:(UIButton *)sender
{
    if (_questInfos.count == _iActivityInfo.confs.count){
        [WLHUDView showHUDWithStr:@"报名中..." dim:NO];
        [WeLianClient orderActiveWithID:_iActivityInfo.activeid
                                Tickets:[NSArray array]
                                  Confs:_questInfos
                                Success:^(id resultInfo) {
                                    [WLHUDView hiddenHud];
                                    [self joinSuccess];
                                    //免费
//                                    [WLHUDView showSuccessHUD:@"恭喜您，报名成功！"];
                                } Failed:^(NSError *error) {
                                    if (error) {
                                        [WLHUDView showErrorHUD:error.localizedDescription];
                                    }else{
                                        [WLHUDView showErrorHUD:@"报名失败，请重新尝试！"];
                                    }
                                }];
    }
}

- (void)joinSuccess
{
    //更新报名成功
    [KNSNotification postNotificationName:kNeedReloadActivityUI object:nil];
    [UIAlertView bk_showAlertViewWithTitle:@""
                                   message:@"恭喜您，活动报名成功！"
                         cancelButtonTitle:@"知道了"
                         otherButtonTitles:nil
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       [self.navigationController popViewControllerAnimated:YES];
                                   }];
}

@end
