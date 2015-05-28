//
//  XZPageViewController.m
//  XZPageViewController
//
//  Created by xiazer on 15/4/9.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import "XZPageViewController.h"
#define navHeight 50

@interface XZPageViewController () <UIPageViewControllerDataSource,UIPageViewControllerDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger navCount;
@property (nonatomic, assign) NSInteger currentVCIndex;
@property (nonatomic, assign) BOOL isPageChangeWithAnimation;

@end

@implementation XZPageViewController

//- (HMSegmentedControl *)segmentedControl
//{
//    if (_segmentedControl == nil) {
//        _segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, navHeight)];
//        _segmentedControl.selectedTextColor = KBasesColor;
//        _segmentedControl.textColor = WLRGB(51.0, 51.0, 51.0);
//        _segmentedControl.selectionIndicatorColor = KBasesColor;
//        _segmentedControl.selectionIndicatorHeight = 2;
//        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
//        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
//        UIView *lieView = [[UIView alloc] initWithFrame:CGRectMake(0, navHeight-1, ScreenWidth, 0.5)];
//        [lieView setBackgroundColor:[UIColor lightGrayColor]];
//        [_segmentedControl addSubview:lieView];
//    }
//    return _segmentedControl;
//}

- (WLCustomSegmentedControl *)segmentedControl
{
    if (!_segmentedControl) {
        _segmentedControl = [[WLCustomSegmentedControl alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, navHeight)];
//        _wlSegmentedControl.frame = CGRectMake(0, kTableViewHeaderViewHeight - 38.f, self.view.width, 38.f);
        _segmentedControl.selectedTextColor = kTitleNormalTextColor;
        _segmentedControl.textColor = kTitleNormalTextColor;
        _segmentedControl.detailTextColor = KBlueTextColor;
        _segmentedControl.selectionIndicatorHeight = 4;//设置底部滑块的高度
        _segmentedControl.selectionIndicatorColor = KBlueTextColor;
        _segmentedControl.showBottomLine = YES;
        _segmentedControl.showLine = NO;//显示分割线
        //        _wlSegmentedControl.isShowVertical = YES;//纵向显示
        _segmentedControl.isAllowTouchEveryTime = YES;//允许重复点击
        _segmentedControl.detailLabelFont = kNormalBlod14Font;
        _segmentedControl.font = kNormal14Font;
        //设置边线
        _segmentedControl.layer.borderColorFromUIColor = WLLineColor;
        _segmentedControl.layer.borderWidths = @"{0,0,0.8,0}";
        _segmentedControl.layer.masksToBounds = YES;
    }
    return _segmentedControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self loadNavScrollView];
    [self loadPageViewController];
    [self transitionToViewControllerAtIndex:0];
}

#pragma mark - method
- (void)initData {
    self.currentVCIndex = 0;
    self.viewControllerArr = [NSMutableArray array];
    self.navCount = self.navTitlesArr.count;
    self.isPageChangeWithAnimation = YES;
}

- (void)loadNavScrollView {
//    [self.view addSubview:self.segmentedControl];
//    self.segmentedControl.sectionTitles = self.navTitlesArr;
    [self.view addSubview:self.segmentedControl];
    _segmentedControl.sectionTitles = self.navTitlesArr;
    _segmentedControl.sectionImages = self.navTitleImagesArr;
}

- (void)loadPageViewController {
    for (NSInteger i = 0; i < self.navCount; i++) {
        UIViewController *vc = [self.dataSource viewPageController:self contentViewControllerForNavAtIndex:i];
        [self.viewControllerArr addObject:vc];
    }

    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [self addChildViewController:self.pageViewController];

//    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    CGFloat navH = CGRectGetMaxY(self.segmentedControl.frame);
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, navH, self.view.bounds.size.width, self.view.bounds.size.height-navH)];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.pageViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.pageViewController.view];
    [self.view addSubview:self.contentView];
}

- (void)setSlidePage:(BOOL)slidePage
{
    _slidePage = slidePage;
    if (slidePage) {
        self.pageViewController.dataSource = self;
    }else{
        self.pageViewController.dataSource = nil;
    }
}


- (void)transitionToViewControllerAtIndex:(NSInteger)index {
    UIViewController *viewController = [self viewControllerAtIndex:index];
    
    UIPageViewControllerNavigationDirection direction = index > self.currentVCIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    [self.pageViewController setViewControllers:@[viewController]
                                      direction:direction
                                       animated:self.isPageChangeWithAnimation
                                     completion:NULL];
    self.currentVCIndex = index;
    [self.delegate viewPageController:self pageViewControllerChangedAtIndex:index];
}

- (NSInteger)indexOfViewController:(UIViewController *)viewController {
    NSInteger index = [self.viewControllerArr indexOfObject:viewController];
    return index;
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index {
    UIViewController *vc = [self.viewControllerArr objectAtIndex:index];
    return vc;
}


#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self indexOfViewController:viewController];
    if (index == 0) {
        return nil;
    } else {
        index--;
    }
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self indexOfViewController:viewController];
    if (index == self.navCount - 1) {
        return nil;
    } else {
        index++;
    }
    return [self viewControllerAtIndex:index];
}


#pragma mark - UIPageViewControllerDelegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
//    UIViewController *viewController = self.pageViewController.viewControllers[0];
//    NSUInteger index = [self indexOfViewController:viewController];
    NSLog(@"pageViewController willTransitionToViewControllers");
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    UIViewController *viewController = self.pageViewController.viewControllers[0];
    NSUInteger index = [self indexOfViewController:viewController];
    self.currentVCIndex = index;
    [self.delegate viewPageController:self pageViewControllerChangedAtIndex:index];
//    [self.segmentedControl setSelectedSegmentIndex:index animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
