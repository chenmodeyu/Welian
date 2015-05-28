//
//  WebViewLookBPViewController.m
//  Welian
//
//  Created by weLian on 15/5/26.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "WebViewLookBPViewController.h"

@interface WebViewLookBPViewController ()<UIWebViewDelegate>

@property (assign,nonatomic) BOOL hasPDF;
@property (strong,nonatomic) NSString *bpPath;
@property (strong,nonatomic) UIWebView *webView;
@property (strong,nonatomic) NSURL *bpUrl;

@end

@implementation WebViewLookBPViewController

- (void)dealloc
{
    _bpPath = nil;
    _webView = nil;
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
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
    [WLHUDView showHUDWithStr:@"加载中..." dim:NO];
    
    self.bpUrl = [NSURL URLWithString:_bpPath];
    //下载照片
    NSString *fileName = [_bpPath lastPathComponent];
    NSString *toFolderPath = @"ChatDocument/ProjectBP/";
    NSString *folder = [[ResManager userResourcePath] stringByAppendingPathComponent:toFolderPath];
    folder = [folder stringByAppendingPathComponent:fileName];
    self.hasPDF = [ResManager fileExistByPath:folder];
    if (_hasPDF) {
        //本地存在的话，直接查看
        self.bpUrl = [NSURL fileURLWithPath:folder];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_bpUrl];
    [_webView loadRequest:request];
//    NSData *pdfData = [[NSData alloc] initWithContentsOfURL:_bpUrl];
//    [_webView loadData:pdfData MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
    [_webView setScalesPageToFit:YES];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //if(navigationType == UIWebViewNavigationTypeLinkClicked) {
    NSURL *requestedURL = [request URL];
    // ...Check if the URL points to a file you're looking for...
    // Then load the file
    if (!_hasPDF) {
//        NSData *fileData = [[NSData alloc] initWithContentsOfURL:requestedURL];
////        // Get the path to the App's Documents directory
////        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
////        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
//        
//        // Get the path to the App's Documents directory
//        NSString *toFolderPath = @"ChatDocument/ProjectBP/";
//        NSString *folder = [[ResManager documentPath] stringByAppendingPathComponent:toFolderPath];
//        // Combine the filename and the path to the documents dir into the full path
//        NSString *pathToDownloadTo = [folder stringByAppendingPathComponent:[requestedURL lastPathComponent]];
//        [fileData writeToFile:pathToDownloadTo atomically:YES];
        [self saveFile:requestedURL];
    }
    
    //}
    return YES;
}
- (void)saveFile:(NSURL *)sender {
    // Get the URL of the loaded ressource
    NSURL *theRessourcesURL = sender;
    NSString *fileExtension = [theRessourcesURL pathExtension];
    
    if ([fileExtension isEqualToString:@"pdf"] || [fileExtension isEqualToString:@"jpg"]) {
        // Get the filename of the loaded ressource form the UIWebView's request URL
        NSString *filename = [theRessourcesURL lastPathComponent];
        
        // Get the path to the App's Documents directory
        NSString *toFolderPath = @"ChatDocument/ProjectBP/";
        NSString *folder = [[ResManager userResourcePath] stringByAppendingPathComponent:toFolderPath];
        // Combine the filename and the path to the documents dir into the full path
        NSString *pathToDownloadTo = [folder stringByAppendingPathComponent:filename];
        NSLog(@"pathToDownloadTo: %@", pathToDownloadTo);
        
        // Load the file from the remote server
        NSData *tmp = [NSData dataWithContentsOfURL:theRessourcesURL];
        // Save the loaded data if loaded successfully
        if (tmp != nil) {
            NSError *error = nil;
            // Write the contents of our tmp object into a file
            [tmp writeToFile:pathToDownloadTo options:NSDataWritingAtomic error:&error];
            if (error != nil) {
                NSLog(@"Failed to save the file: %@", [error description]);
            } else {
                // Display an UIAlertView that shows the users we saved the file :)
//                UIAlertView *filenameAlert = [[UIAlertView alloc] initWithTitle:@"File saved" message:[NSString stringWithFormat:@"The file %@ has been saved.", filename] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [filenameAlert show];
                NSLog(@"The file %@ has been saved.",filename);
            }
        } else {
            // File could notbe loaded -> handle errors
        }
    } else {
        // File type not supported
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [WLHUDView hiddenHud];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
//    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    self.title = title;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [WLHUDView hiddenHud];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [WLHUDView showHUDWithStr:@"加载中..." dim:NO];
}

@end
