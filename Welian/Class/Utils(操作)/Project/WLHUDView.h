//
//  WLHUDView.h
//  Welian
//
//  Created by dong on 14-9-22.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MBProgressHUD;

@interface WLHUDView : NSObject

+(UIWindow*)window;
// 成功
+ (void)showSuccessHUD:(NSString *)labeltext;
// 失败
+ (void)showErrorHUD:(NSString *)labeltext;
// 警告
+ (void)showAttentionHUD:(NSString *)labelText;

+ (void)showCustomHUD:(NSString *)labeltext imageview:(NSString *)imageName;

+ (MBProgressHUD*)showHUDWithStr:(NSString*)title dim:(BOOL)dim;
// 
+ (void)hiddenHud;
@end
