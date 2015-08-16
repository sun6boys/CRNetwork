//
//  XLNetworkAgent.h
//  XLNetWorking
//
//  Created by chuxiaolong on 15/8/13.
//  Copyright (c) 2015年 chuxiaolong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLBaseRequest.h"
#import "AFNetworking.h"


@interface XLNetworkAgent : NSObject
+ (XLNetworkAgent *)sharedInstance;

- (void)addRequest:(XLBaseRequest *)request;

- (void)cancelRequest:(XLBaseRequest *)request;

- (void)cancelAllRequests;

/// 根据request和networkConfig构建url
- (NSString *)buildRequestUrl:(XLBaseRequest *)request;
@end
