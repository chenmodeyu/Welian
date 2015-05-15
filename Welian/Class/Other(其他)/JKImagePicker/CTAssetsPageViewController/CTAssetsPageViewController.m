/*
 CTAssetsPageViewController.m
 
 The MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "CTAssetsPageViewController.h"
#import "CTAssetItemViewController.h"
#import "CTAssetScrollView.h"





@interface CTAssetsPageViewController ()
<UIPageViewControllerDataSource, UIPageViewControllerDelegate, CTAssetItemViewControllerDataSource>
{
    NSInteger _currently;
    PicDataBlock _picBlcok;
}
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, assign, getter = isStatusBarHidden) BOOL statusBarHidden;

@end

@implementation CTAssetsPageViewController

- (id)initWithAssets:(NSMutableArray *)assets picDatablock:(PicDataBlock)picArrayBlck
{
    
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                  options:@{UIPageViewControllerOptionInterPageSpacingKey:@30.f}];
    if (self)
    {
        _picBlcok = picArrayBlck;
        self.assets                 = assets;
        self.dataSource             = self;
        self.delegate               = self;
        self.view.backgroundColor   = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addNotificationObserver];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePick)];
//    [self loadAssetsGroups];
}

- (void)deletePick
{
    WEAKSELF
    [UIAlertView bk_showAlertViewWithTitle:@"确定删除吗？" message:@"" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex==1) {
            NSMutableArray *mutAssets = [NSMutableArray arrayWithArray:self.assets];
            [mutAssets removeObjectAtIndex:_currently-1];
            weakSelf.assets = mutAssets;
            if (_currently==1) {
                if (weakSelf.assets.count==0) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                    _picBlcok([NSMutableArray arrayWithArray:weakSelf.assets]);
                    return;
                }
                [weakSelf setPageIndex:0];
            }else {
                
                [weakSelf setPageIndex:_currently-2];
            }
            _picBlcok([NSMutableArray arrayWithArray:weakSelf.assets]);

        }
    }];
}


- (void)dealloc
{
    [self removeNotificationObserver];
}

- (BOOL)prefersStatusBarHidden
{
    return self.isStatusBarHidden;
}


#pragma mark - Update Title

- (void)setTitleIndex:(NSInteger)index
{
    _currently = index;
    NSInteger count = self.assets.count;
    self.title = [NSString stringWithFormat:NSLocalizedString(@"%ld / %ld", nil), index, count];
}


#pragma mark - Page Index

- (NSInteger)pageIndex
{
    return ((CTAssetItemViewController *)self.viewControllers[0]).pageIndex;
}

- (void)setPageIndex:(NSInteger)pageIndex
{
    NSInteger count = self.assets.count;
    
    if (pageIndex >= 0 && pageIndex < count)
    {
        CTAssetItemViewController *page = [CTAssetItemViewController assetItemViewControllerForPageIndex:pageIndex];
        page.dataSource = self;
        
        [self setViewControllers:@[page]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
        
        [self setTitleIndex:pageIndex + 1];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    [self fadeNavigationBarAway];
}


#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = ((CTAssetItemViewController *)viewController).pageIndex;

    if (index > 0)
    {
        CTAssetItemViewController *page = [CTAssetItemViewController assetItemViewControllerForPageIndex:(index - 1)];
        page.dataSource = self;
        
        return page;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger count = self.assets.count;
    NSInteger index = ((CTAssetItemViewController *)viewController).pageIndex;
    if (index < count - 1)
    {
        CTAssetItemViewController *page = [CTAssetItemViewController assetItemViewControllerForPageIndex:(index + 1)];
        page.dataSource = self;
        
        return page;
    }
    
    return nil;
}


#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed)
    {
        CTAssetItemViewController *vc   = (CTAssetItemViewController *)pageViewController.viewControllers[0];
        NSInteger index = vc.pageIndex + 1;
        
        [self setTitleIndex:index];
    }
}


#pragma mark - Notification Observer

- (void)addNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(scrollViewTapped:)
                   name:CTAssetScrollViewTappedNotification
                 object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTAssetScrollViewTappedNotification object:nil];
}


#pragma mark - Tap Gesture

- (void)scrollViewTapped:(NSNotification *)notification
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)notification.object;
    
    if (gesture.numberOfTapsRequired == 1)
        [self toogleNavigationBar:gesture];
}


#pragma mark - Fade in / away navigation bar

- (void)toogleNavigationBar:(id)sender
{
	if (self.isStatusBarHidden)
		[self fadeNavigationBarIn];
    else
		[self fadeNavigationBarAway];
}

- (void)fadeNavigationBarAway
{
    self.statusBarHidden = YES;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self setNeedsStatusBarAppearanceUpdate];
                         [self.navigationController.navigationBar setAlpha:0.0f];
                         self.view.backgroundColor = [UIColor blackColor];
                     }
                     completion:^(BOOL finished){
                          [self.navigationController setNavigationBarHidden:YES];
                     }];
}

- (void)fadeNavigationBarIn
{
    self.statusBarHidden = NO;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self setNeedsStatusBarAppearanceUpdate];
                         [self.navigationController.navigationBar setAlpha:1.0f];
                     } completion:^(BOOL finished) {
                         [self.navigationController setNavigationBarHidden:NO];
                     }];
}



#pragma mark - CTAssetItemViewControllerDataSource
- (JKAssets *)assetAtIndex:(NSUInteger)index;
{
    return [self.assets objectAtIndex:index];
}

@end
