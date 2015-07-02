//
//  NavViewController.m
//  Welian
//
//  Created by dong on 14-9-10.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "NavViewController.h"

@interface NavViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@end

@implementation NavViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    __weak NavViewController *weakSelf = self;
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.interactivePopGestureRecognizer.delegate = weakSelf;
//        self.delegate = weakSelf;
//    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    if ( [self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES )
//    {
//        self.interactivePopGestureRecognizer.enabled = YES;
//    }
//    
    if (self.viewControllers.count) {
        [viewController setHidesBottomBarWhenPushed:YES];
    }
    [super pushViewController:viewController animated:animated];
}


- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [WLHUDView hiddenHud];
    return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [WLHUDView hiddenHud];
//    if( [self respondsToSelector:@selector(interactivePopGestureRecognizer)] )
//    {
//        self.interactivePopGestureRecognizer.enabled = NO;
//    }
    return [super popToViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    [WLHUDView hiddenHud];
//    if ( [self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES )
//    {
//        self.interactivePopGestureRecognizer.enabled = NO;
//    }
    return [super popToRootViewControllerAnimated:animated];
}

//- (void)navigationController:(UINavigationController *)navigationController
//       didShowViewController:(UIViewController *)viewController
//                    animated:(BOOL)animate
//{
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.interactivePopGestureRecognizer.enabled = YES;
//    }
//}

//-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    
//    if ( gestureRecognizer == self.interactivePopGestureRecognizer )
//    {
//        if ( self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0] )
//        {
//            return NO;
//        }
//    }
//    
//    return YES;
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
