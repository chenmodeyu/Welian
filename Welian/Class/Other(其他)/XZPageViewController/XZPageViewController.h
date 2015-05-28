//
//  XZPageViewController.h
//  XZPageViewController
//
//  Created by xiazer on 15/4/9.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import "BasicViewController.h"
#import "HMSegmentedControl.h"
#import "WLCustomSegmentedControl.h"

@protocol XZPageViewControllerDataSource;
@protocol XZPageViewControllerDelegate;

@interface XZPageViewController : BasicViewController
@property (nonatomic, strong) NSMutableArray *viewControllerArr;
@property (nonatomic, strong) NSArray *navTitlesArr;
@property (nonatomic, strong) NSArray *navTitleImagesArr;
// 是否允许左右滑动 默认不允许
@property (nonatomic, assign) BOOL slidePage;

@property (nonatomic, weak) id<XZPageViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<XZPageViewControllerDelegate> delegate;

//@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (strong,nonatomic) WLCustomSegmentedControl *segmentedControl;

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