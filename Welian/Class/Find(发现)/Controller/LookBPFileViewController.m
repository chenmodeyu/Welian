//
//  LookBPFileViewController.m
//  Welian
//
//  Created by weLian on 15/5/26.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "LookBPFileViewController.h"

@interface LookBPFileViewController ()

@property (strong,nonatomic) NSString *bpPath;

@end

@implementation LookBPFileViewController

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
    [self downloadBPAndLook];
}

#pragma mark - Private
- (void)downloadBPAndLook
{
    //下载照片
    NSString *fileName = [_bpPath lastPathComponent];
    NSString *toFolderPath = @"ChatDocument/ProjectBP/";
    
    NSString *folder = [[ResManager userResourcePath] stringByAppendingPathComponent:toFolderPath];
    [folder stringByAppendingPathComponent:fileName];
    if ([ResManager fileExistByPath:folder]) {
        //本地存在的话，直接查看
        
    }else{
        //下载图片
        NSMutableDictionary *Files = [NSMutableDictionary dictionary];
        //设置下载图片信息
        [Files setObject:_bpPath forKey:fileName];
        [WeLianClient downLoadImageWithMemberId:Files
                                       ToFolder:toFolderPath
                                        success:^(id result) {
                                            DLog(@"BP文件下载成功");
                                            //                                            NSString *folder = [[ResManager userResourcePath] stringByAppendingPathComponent:toFolderPath];
                                            //本地的图片路径
                                            NSString *path = [toFolderPath stringByAppendingPathComponent:fileName];
                                            
                                        } failed:^(NSError *error) {
                                            DLog(@"聊天图片下载失败");
                                            return ;
                                        }];
    }
}

@end
