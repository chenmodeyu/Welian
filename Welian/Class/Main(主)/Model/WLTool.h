//
//  WLTool.h
//  Welian
//
//  Created by dong on 14-9-17.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FriendsAddressBook.h"

typedef void(^WLToolBlock)(NSArray *friendsAddress);
@interface WLTool : NSObject

+ (void)getAddressBookArray:(WLToolBlock)friendsAddressBlock;

@end
