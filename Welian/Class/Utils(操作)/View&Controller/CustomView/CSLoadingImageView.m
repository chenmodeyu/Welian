//
//  CSLoadingImageView.m
//  XingLv
//
//  Created by yangxh on 12-10-24.
//  Copyright (c) 2012年 yangxh. All rights reserved.
//

#import "CSLoadingImageView.h"

#import <objc/message.h>

@interface CSLoadingImageView()
@property (strong, nonatomic) UIActivityIndicatorView *activity;
@end

@implementation CSLoadingImageView

- (void)dealloc
{
    _activity = nil;
}

- (void)setImage:(UIImage *)image
{
    [super setImage:image];
    
    if (!image) {
        [_activity stopAnimating];
        [_activity removeFromSuperview];
        
        self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activity sizeToFit];
        [self addSubview:_activity];
        [_activity startAnimating];
    } else {
        
        //implement crossfade transition without needing to import QuartzCore
        /*
        id animation = objc_msgSend(NSClassFromString(@"CATransition"), @selector(animation));
        objc_msgSend(animation, @selector(setType:), @"kCATransitionFade");
        objc_msgSend(animation, @selector(setDuration:), .4f);
        objc_msgSend(self.layer, @selector(addAnimation:forKey:), animation, @"transition");
         */
        
        [_activity stopAnimating];
        [_activity removeFromSuperview];
        self.activity = nil;
        
        /*
        self.alpha = .0f;
        [UIView animateWithDuration:.25f animations:^{
            self.alpha = 1.f;
        } completion:^(BOOL finished) {
            
        }];
        */
       
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _activity.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

@end
