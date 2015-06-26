//
//  BindingPhoneController.m
//  Welian
//
//  Created by dong on 15/1/7.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "BindingPhoneController.h"
#import "UIImage+ImageEffects.h"
#import "MJExtension.h"
#import "MainViewController.h"
#import "BSearchFriendsController.h"
#import "NSString+val.h"
#import "NavViewController.h"
#import "AppDelegate.h"

@interface BindingPhoneController () <UITextFieldDelegate>
{
    UITextField *_phoneTF;
    UITextField *_pwdTF;
}
@end

@implementation BindingPhoneController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:WLRGB(231, 234, 238)];
    [self setTitle:@"绑定"];
    UITextField *phoneTF = [self addPerfectInfoTextfWithFrameY:30+64 Placeholder:@"手机号" leftImageName:@"login_phone"];
    [phoneTF setText:self.phoneStr];
    [phoneTF setReturnKeyType:UIReturnKeyNext];
    phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTF = phoneTF;
    [self.view addSubview:phoneTF];
    
    UITextField *pwdTF = [self addPerfectInfoTextfWithFrameY:CGRectGetMaxY(phoneTF.frame)+15 Placeholder:@"密码" leftImageName:@"login_password"];
    [pwdTF setReturnKeyType:UIReturnKeyDone];
    _pwdTF = pwdTF;
    [pwdTF setSecureTextEntry:YES];
    [self.view addSubview:pwdTF];
    
    UIButton *bindingBut = [[UIButton alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(pwdTF.frame)+30, SuperSize.width-50, 44)];
    [bindingBut setBackgroundImage:[UIImage resizedImage:@"login_my_button"] forState:UIControlStateNormal];
    [bindingBut setBackgroundImage:[UIImage resizedImage:@"login_my_button_pre"] forState:UIControlStateHighlighted];
    [bindingBut addTarget:self action:@selector(bindingButClick) forControlEvents:UIControlEventTouchUpInside];
    [bindingBut.titleLabel setFont:WLFONTBLOD(18)];
    [bindingBut setTitle:@"绑定" forState:UIControlStateNormal];
    [self.view addSubview:bindingBut];
    
}

- (void)bindingButClick
{
    [[self.view findFirstResponder] resignFirstResponder];
    
    if (!_phoneTF.text.length) {
        [WLHUDView showErrorHUD:@"请填写手机号码"];
        return;
    }
    if (_phoneTF.text.length != 11) {
        [WLHUDView showErrorHUD:@"手机号码有误！"];
        return;
    }
    if (![NSString passwordValidate:_pwdTF.text]) {
        [WLHUDView showErrorHUD:@"密码有误！"];
        return;
    }
    if (![self.userInfoDic objectForKey:@"openid"]) {
        return;
    }
    if (![self.userInfoDic objectForKey:@"unionid"]) {
        return;
    }
    NSMutableDictionary *requstDic = [NSMutableDictionary dictionary];
    [requstDic setObject:[self.userInfoDic objectForKey:@"unionid"] forKey:@"unionid"];

    [requstDic setObject:_phoneTF.text forKey:@"mobile"];
    [requstDic setObject:[_pwdTF.text MD5String] forKey:@"password"];

    [WLHUDView showHUDWithStr:@"绑定中..." dim:YES];
    [WeLianClient loginWithParameterDic:requstDic Success:^(id resultInfo) {
//        [WLHUDView hiddenHud];
        ILoginUserModel *loginUserM = resultInfo;
        
        [[AppDelegate sharedAppDelegate] initRongInfo:loginUserM];
        
//        [[RCIM sharedRCIM] connectWithToken:loginUserM.token success:^(NSString *userId) {
//            //设置当前的用户信息
//            RCUserInfo *_currentUserInfo = [[RCUserInfo alloc]initWithUserId:userId
//                                                                        name:loginUserM.name
//                                                                    portrait:loginUserM.avatar];
//            [[RCIM sharedRCIM] setCurrentUserInfo:_currentUserInfo];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [WLHUDView hiddenHud];
//                [LogInUser createLogInUserModel:loginUserM];
//                // 进入主页面
//                MainViewController *mainVC = [[MainViewController alloc] init];
//                [[UIApplication sharedApplication].keyWindow setRootViewController:mainVC];
//            });
//        }error:^(RCConnectErrorCode status) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [WLHUDView showErrorHUD:@"登陆失败，请重新登陆"];
//            });
//            NSLog(@"RCConnectErrorCode is %ld",(long)status);
//        } tokenIncorrect:^{
//            dispatch_async(dispatch_get_main_queue(), ^{
////                [WLHUDView showErrorHUD:@"token过期"];
//            });
//        }];
//        [LogInUser createLogInUserModel:loginUserM];
//        //进入主页面
//        MainViewController *mainVC = [[MainViewController alloc] init];
//        [[UIApplication sharedApplication].keyWindow setRootViewController:mainVC];
        
    } Failed:^(NSError *error) {
        [WLHUDView showErrorHUD:error.localizedDescription];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_phoneTF resignFirstResponder];
    [_pwdTF resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _phoneTF) {
        if (range.location>=11) return NO;
    }else if (textField == _pwdTF){
        if (range.location>=18) return NO;
    }
    return YES;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _phoneTF) {
        [_pwdTF becomeFirstResponder];
    }else if (textField == _pwdTF){
        [_pwdTF resignFirstResponder];
    }
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITextField *)addPerfectInfoTextfWithFrameY:(CGFloat)Y Placeholder:(NSString *)placeholder leftImageName:(NSString *)imagename
{
    UITextField *textf = [[UITextField alloc] initWithFrame:CGRectMake(25, Y, SuperSize.width-50, 40)];
    [textf setPlaceholder:placeholder];
    [textf setDelegate:self];
    [textf setLeftViewMode:UITextFieldViewModeAlways];
    [textf setRightViewMode:UITextFieldViewModeAlways];
    [textf setBackgroundColor:[UIColor whiteColor]];
    [textf setClearButtonMode:UITextFieldViewModeWhileEditing];
    UIButton *nameleftV = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 16)];
    [nameleftV setUserInteractionEnabled:NO];
    [nameleftV setImage:[UIImage imageNamed:imagename] forState:UIControlStateNormal];
    [textf setLeftView:nameleftV];
    [textf.layer setCornerRadius:4];
    [textf.layer setMasksToBounds:YES];
    return textf;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
