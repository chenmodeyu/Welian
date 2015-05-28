//
//  LookBPFileViewController.m
//  Welian
//
//  Created by weLian on 15/5/26.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "LookBPFileViewController.h"
#import <QuickLook/QuickLook.h>

@interface LookBPFileViewController ()<QLPreviewControllerDelegate,QLPreviewControllerDataSource>

@property (strong,nonatomic) NSString *bpPath;
@property (strong,nonatomic) QLPreviewController *previewController;
@property (strong,nonatomic) NSURL *bpUrl;

@end

@implementation LookBPFileViewController

- (void)dealloc
{
    _bpPath = nil;
    _previewController = nil;
    _bpUrl = nil;
}

- (NSString *)title
{
    return @"BP详情";
}

- (instancetype)initWithBpPath:(NSString *)bpPath
{
    self = [super init];
    if (self) {
        self.bpPath = bpPath;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    previewController.dataSource = self;
    previewController.delegate = self;
    previewController.view.frame = Rect(0, ViewCtrlTopBarHeight, self.view.width, self.view.height - ViewCtrlTopBarHeight);
    [self.view addSubview:previewController.view];
    self.previewController = previewController;
    
    [self downloadBPAndLook];
}

#pragma mark - Private
- (void)downloadBPAndLook
{
    //下载照片
    NSString *fileName = [_bpPath lastPathComponent];
    NSString *toFolderPath = @"ChatDocument/ProjectBP/";
    
    NSString *folder = [[ResManager userResourcePath] stringByAppendingPathComponent:toFolderPath];
    folder = [folder stringByAppendingPathComponent:fileName];
    if ([ResManager fileExistByPath:folder]) {
        //本地存在的话，直接查看
        self.bpUrl = [NSURL fileURLWithPath:folder];
        [_previewController reloadData];
    }
}

#pragma mark - QLPreviewControllerDataSource

// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    
    return 1;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    return _bpUrl;
}

@end
