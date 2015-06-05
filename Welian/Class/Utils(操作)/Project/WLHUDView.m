//
//  WLHUDView.m
//  Welian
//
//  Created by dong on 14-9-22.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "WLHUDView.h"
#import "MBProgressHUD.h"

#define Kerror     @"hud_error"
#define Ksuccess   @"hud_success"
#define KAttention @"hud_attention"

@interface WLHUDView ()
@end

@implementation WLHUDView

+(UIWindow*)window
{
    
    return [UIApplication sharedApplication].keyWindow;
}

MBProgressHUD *HUD;


+ (void)showAttentionHUD:(NSString *)labelText
{
    [self showCustomHUD:labelText imageview:KAttention];
}

+ (void)showSuccessHUD:(NSString *)labeltext
{
    [self showCustomHUD:labeltext imageview:Ksuccess];
}

+ (void)showErrorHUD:(NSString *)labeltext
{
    [self showCustomHUD:labeltext imageview:Kerror];
    
}

+ (void)showCustomHUD:(NSString *)labeltext imageview:(NSString *)imageName
{
    [self showHUDWithStr:labeltext dim:NO];
    if (imageName) {
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    }
    HUD.mode = MBProgressHUDModeCustomView;
    [HUD hide:YES afterDelay:1.2];
}


+ (MBProgressHUD*)showHUDWithStr:(NSString*)title dim:(BOOL)dim
{
//    [self hiddenHud];
    HUD = [MBProgressHUD showHUDAddedTo:[self window] animated:YES];
    [HUD setUserInteractionEnabled:dim];
    [HUD setLabelText:title];
    return HUD;
}

+ (void)hiddenHud
{
    [MBProgressHUD hideHUDForView:[self window] animated:NO];
}

@end
