//
//  DALabeledCircularProgressView.m
//  DACircularProgressExample
//
//  Created by Josh Sklar on 4/8/14.
//  Copyright (c) 2014 Shout Messenger. All rights reserved.
//

#import "DALabeledCircularProgressView.h"

@implementation DALabeledCircularProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeLabel];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeLabel];
    }
    return self;
}

- (void)setTitlColor:(UIColor *)titlColor
{
    _titlColor = titlColor;
    [self.titleLabel setTextColor:titlColor];
}

- (void)setProgresColor:(UIColor *)progresColor
{
    _progresColor = progresColor;
    [self.progressLabel setTextColor:progresColor];
}


#pragma mark - Internal methods

/**
 Creates and initializes
 -[DALabeledCircularProgressView progressLabel].
 */
- (void)initializeLabel
{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height*0.2, self.bounds.size.width, self.bounds.size.height*0.2)];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setFont:[UIFont systemFontOfSize:9]];
    [self addSubview:self.titleLabel];
    
    self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height*0.4, self.bounds.size.width, self.bounds.size.height*0.5)];
    [self.progressLabel setFont:[UIFont systemFontOfSize:18]];
    self.progressLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.progressLabel];
}

@end
