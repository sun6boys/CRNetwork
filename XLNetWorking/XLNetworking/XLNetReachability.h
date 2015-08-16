//
//  XLNetReachability.h
//  XLNetWorking
//
//  Created by chuxiaolong on 15/8/16.
//  Copyright (c) 2015年 chuxiaolong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLNetReachability : NSObject
+ (XLNetReachability *)sharedInstance;

- (BOOL)isNetWorkConnect;

@end
