//
//  DALabeledCircularProgressView.h
//  DACircularProgressExample
//
//  Created by Josh Sklar on 4/8/14.
//  Copyright (c) 2014 Shout Messenger. All rights reserved.
//

#import "DACircularProgressView.h"

/**
 @class DALabeledCircularProgressView
 
 @brief Subclass of DACircularProgressView that adds a UILabel.
 */
@interface DALabeledCircularProgressView : DACircularProgressView

/**
 UILabel placed right on the DACircularProgressView.
 */
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIColor *titlColor;
@property (strong, nonatomic) UILabel *progressLabel;
@property (nonatomic, strong) UIColor *progresColor;

@end
