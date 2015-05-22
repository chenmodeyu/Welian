//
//  XZPageViewController.h
//  XZPageViewController
//
//  Created by xiazer on 15/4/9.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import "BasicViewController.h"
#import "HMSegmentedControl.h"

@protocol XZPageViewControllerDataSource;
@protocol XZPageViewControllerDelegate;

@interface XZPageViewController : BasicViewController
@property (nonatomic, strong) NSMutableArray *viewControllerArr;
@property (nonatomic, strong) NSArray *navTitlesArr;

@property (nonatomic, weak) id<XZPageViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<XZPageViewControllerDelegate> delegate;

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;

- (void)transitionToViewControllerAtIndex:(NSInteger)index;

@end

@protocol XZPageViewControllerDataSource <NSObject>

// pageViewController
- (UIViewController *)viewPageController:(XZPageViewController *)pageViewController contentViewControllerForNavAtIndex:(NSInteger)index;
@end

@protocol XZPageViewControllerDelegate <NSObject>
@optional
- (void)viewPageController:(XZPageViewController *)pageViewController pageViewControllerChangedAtIndex:(NSInteger)index;
@end