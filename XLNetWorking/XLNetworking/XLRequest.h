//
//  XLRequest.h
//  XLNetWorking
//
//  Created by chuxiaolong on 15/8/16.
//  Copyright (c) 2015年 chuxiaolong. All rights reserved.
//

#import "XLCacheRequest.h"

extern NSString * const RequestStateSuccess;
extern NSString * const RequestStateFailed;
extern NSString * const RequestStateError;


@interface XLRequest : XLCacheRequest
//response消息
@property (nonatomic, copy) NSString     * message;

//状态码
@property (nonatomic)       NSInteger      code;

//当前请求的状态
@property (nonatomic, assign) NSString     * state;

//用于MVVM中响应的输入参数
@property (nonatomic)       BOOL           becomeActive;



- (BOOL)succeed;

- (BOOL)failed;
@end
