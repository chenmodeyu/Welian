//
//  LoginPhoneVC.m
//  weLian
//
//  Created by dong on 14/10/29.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "LoginPhoneVC.h"
#import "NSString+val.h"
#import "MainViewController.h"
#import "UITextField+LeftRightView.h"
#import "ForgetPhoneController.h"
#import "LogInUser.h"
#import "UIImage+ImageEffects.h"
#import "AppDelegate.h"

@interface LoginPhoneVC ()<UITextFieldDelegate>

@property (strong, nonatomic)  UITextField *phoneTextField;
@property (strong, nonatomic)  UITextField *pwdTextField;

@end

@implementation LoginPhoneVC

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.phoneTextField) {
        if (range.location>=11) return NO;
    }else if (textField == self.pwdTextField){
        if (range.location>=18) return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==self.phoneTextField) {
        [self.pwdTextField becomeFirstResponder];
    }else if (textField == self.pwdTextField){
        [self loginPhonePWD:nil];
    }
    
    return YES;
}

- (void)setPhoneString:(NSString *)phoneString
{
    _phoneString = phoneString;
    
    //设置手机号码
    _phoneTextField.text = _phoneString;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载页面数据
    [self loadUIView];
    UITapGestureRecognizer *tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [[self.view findFirstResponder] resignFirstResponder];
    }];
    [self.view addGestureRecognizer:tap];
}

- (void)loadUIView
{
    [self setTitle:@"登录"];
    //设置背景色
    [self.view setBackgroundColor:WLLineColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(cancellVC)];
    
    //手机号码
    UITextField *phoneTF = [UITextField textFieldWitFrame:Rect(25, ViewCtrlTopBarHeight + kFirstMarginTop, SuperSize.width-50, TextFieldHeight) placeholder:@"手机号码" leftViewImageName:@"login_phone" andRightViewImageName:nil];
    [phoneTF setClearButtonMode:UITextFieldViewModeWhileEditing];
    phoneTF.text = GetLastLoginMobile;
    phoneTF.returnKeyType = UIReturnKeyNext;
    phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    phoneTF.delegate = self;
    [self.view addSubview:phoneTF];
    self.phoneTextField = phoneTF;
    
    //密码
    UITextField *pwdTF = [UITextField textFieldWitFrame:Rect(25, phoneTF.bottom + 10, SuperSize.width-50, TextFieldHeight) placeholder:@"密码" leftViewImageName:@"login_password" andRightViewImageName:nil];
    pwdTF.secureTextEntry = YES;
    pwdTF.returnKeyType = UIReturnKeyGo;
    [pwdTF setClearButtonMode:UITextFieldViewModeWhileEditing];
    pwdTF.keyboardType = UIKeyboardTypeDefault;
    pwdTF.delegate = self; 
    [self.view addSubview:pwdTF];
    self.pwdTextField = pwdTF;
    
    CGFloat butW = 75;
    UIButton *forgetBut = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - butW - 20, pwdTF.bottom + 15, butW, 30)];
    [forgetBut.titleLabel setFont:kNormal15Font];
    [forgetBut setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [forgetBut setTitle:@"忘记密码?" forState:UIControlStateNormal];
    [forgetBut addTarget:self action:@selector(forgetPwd:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgetBut];
    
    UIButton *loginBut = [[UIButton alloc] initWithFrame:CGRectMake(25, forgetBut.bottom+25, SuperSize.width-50, TextFieldHeight)];
    [loginBut setTitle:@"进入微链" forState:UIControlStateNormal];
    [loginBut setBackgroundImage:[UIImage resizedImage:@"login_my_button"] forState:UIControlStateNormal];
    [loginBut setBackgroundImage:[UIImage resizedImage:@"login_my_button_pre"] forState:UIControlStateHighlighted];
    [loginBut.titleLabel setFont:WLFONTBLOD(18)];
    [loginBut addTarget:self action:@selector(loginPhonePWD:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBut];
    
}

- (void)cancellVC
{
    [self.view.findFirstResponder resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)forgetPwd:(UIButton *)sender {
    ForgetPhoneController *forgetVC = [[ForgetPhoneController alloc] init];
    [self.navigationController pushViewController:forgetVC animated:YES];
}

- (void)loginPhonePWD:(UIButton *)sender {
    [[self.view findFirstResponder] resignFirstResponder];
    
    if (![self.phoneTextField.text phoneValidate]) {
        [WLHUDView showErrorHUD:@"手机号码有误！"];
        return;
    }
    if (![NSString passwordValidate:self.pwdTextField.text]) {
        [WLHUDView showErrorHUD:@"密码有误！"];
        return;
    }
    NSMutableDictionary *reqstDic = [NSMutableDictionary dictionary];
    [reqstDic setObject:self.phoneTextField.text forKey:@"mobile"];
    [reqstDic setObject:[self.pwdTextField.text MD5String] forKey:@"password"];

    [WLHUDView showHUDWithStr:@"登录中..." dim:YES];
    [WeLianClient loginWithParameterDic:reqstDic Success:^(id resultInfo) {
        [WLHUDView hiddenHud];
        ILoginUserModel *loginUserM = resultInfo;
        [LogInUser createLogInUserModel:loginUserM];
        //登陆融云服务器  // 快速集成第二步，连接融云服务器
        [WLHUDView showHUDWithStr:@"连接融云服务器中..." dim:YES];
        [[RCIM sharedRCIM] connectWithToken:loginUserM.token success:^(NSString *userId) {
            //设置当前的用户信息
            RCUserInfo *_currentUserInfo = [[RCUserInfo alloc]initWithUserId:userId
                                                                        name:loginUserM.name
                                                                    portrait:nil];
            [RCIMClient sharedRCIMClient].currentUserInfo = _currentUserInfo;
            
            //融云同步群组信息
//            hud.labelText = @"同步群信息";
//            [RCDDataSource syncGroups];
            
            dispatch_async(dispatch_get_main_queue(), ^{

                MainViewController *mainVC = [[MainViewController alloc] init];
                [[UIApplication sharedApplication].keyWindow setRootViewController:mainVC];
                
            });
            
        } error:^(RCConnectErrorCode status) {
            NSLog(@"RCConnectErrorCode is %ld",(long)status);
        } tokenIncorrect:^{
            NSLog(@"IncorrectToken");
        }];
        
    } Failed:^(NSError *error) {
        [WLHUDView showErrorHUD:error.localizedDescription];
    }];
}

@end
