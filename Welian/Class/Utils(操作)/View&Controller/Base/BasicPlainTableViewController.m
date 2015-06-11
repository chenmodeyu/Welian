//
//  BasicPlainTableViewController.m
//  Welian
//
//  Created by dong on 15/1/4.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "BasicPlainTableViewController.h"

@interface BasicPlainTableViewController ()

@end

@implementation BasicPlainTableViewController

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    //显示导航条
////    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    self.navigationController.navigationBarHidden = NO;
//    self.navigationController.navigationBar.hidden = NO;
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    self.navigationController.navigationBarHidden = NO;
//    self.navigationController.navigationBar.hidden = NO;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置屏幕手势是否可以使用
    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = YES;
    //设置是否可以滑动返回pop
    self.fd_interactivePopDisabled = NO;
    //设置navbar是否隐藏
    self.fd_prefersNavigationBarHidden = NO;
    //设置pop的最大
    self.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge = 200.f;
    
    [self.tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // 清除内存中的图片缓存
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    [mgr cancelAll];
    [mgr.imageCache clearMemory];
    DLog(@"%@ ------  didReceiveMemoryWarning",[self class]);
}

- (void)dealloc
{
    DLog(@"%@ ------  dealloc",[self class]);
    if (!self.needlessCancel) {
        [WLHUDView hiddenHud];
//        [WLHttpTool cancelAllRequestHttpTool];
        [WeLianClient cancelAllRequestHttpTool];
        DLog(@"--------------------------------------取消请求-------取消请求");
    }
}



@end
