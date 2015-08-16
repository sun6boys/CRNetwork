//
//  XLNetReachability.m
//  XLNetWorking
//
//  Created by chuxiaolong on 15/8/16.
//  Copyright (c) 2015年 chuxiaolong. All rights reserved.
//

#import "XLNetReachability.h"
#import "AFNetworkReachabilityManager.h"
@interface XLNetReachability()
@property (nonatomic, strong) AFNetworkReachabilityManager * manager;
@end

@implementation XLNetReachability
+ (XLNetReachability *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (id)init {
    self = [super init];
    if (self) {
        self.manager = [AFNetworkReachabilityManager sharedManager];
        [self.manager startMonitoring];
    }
    return self;
}
- (BOOL)isNetWorkConnect
{
    return  self.manager.networkReachabilityStatus ==AFNetworkReachabilityStatusNotReachable ? NO : YES;

}
@end
