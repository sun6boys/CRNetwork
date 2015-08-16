//
//  XLBaseRequest.h
//  XLNetWorking
//
//  Created by chuxiaolong on 15/8/13.
//  Copyright (c) 2015年 chuxiaolong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
typedef NS_ENUM(NSInteger , XLRequestMethod) {
    XLRequestMethodGet = 0,
    XLRequestMethodPost,
    XLRequestMethodPut,
};

typedef NS_ENUM(NSInteger , YTKRequestSerializerType) {
    YTKRequestSerializerTypeHTTP = 0,
    YTKRequestSerializerTypeJSON,
};

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);


@interface XLBaseRequest : NSObject
/// Tag
@property (nonatomic) NSInteger tag;

/// User info
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;


@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;

@property (nonatomic, strong, readonly) NSString *responseString;

@property (nonatomic, strong, readonly) id responseJSONObject;

@property (nonatomic, readonly) NSInteger responseStatusCode;

@property (nonatomic, copy) void (^successCompletionBlock)(XLBaseRequest *);

@property (nonatomic, copy) void (^failureCompletionBlock)(XLBaseRequest *);


/// append self to request queue
- (void)start;

/// remove self from request queue
- (void)stop;

- (BOOL)isExecuting;

/// block回调
- (void)startWithCompletionBlockWithSuccess:(void (^)(XLBaseRequest *request))success
                                    failure:(void (^)(XLBaseRequest *request))failure;

- (void)setCompletionBlockWithSuccess:(void (^)(XLBaseRequest *request))success
                              failure:(void (^)(XLBaseRequest *request))failure;

/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;



/// 以下方法由子类继承来覆盖默认值

#warning 此处增加是否需要otherCode
#warning 增加一个是否需要验证的函数

/// 请求成功的回调
- (void)requestCompleteFilterAndCode:(NSInteger)code message:(NSString*)message;

/// 请求失败的回调
- (void)requestFailedFilterAndCode:(NSInteger)code message:(NSString*)message;

/// 请求的URL
- (NSString *)requestUrl;

/// 请求的CdnURL
- (NSString *)cdnUrl;

/// 请求的BaseURL
- (NSString *)baseUrl;

/// 请求的连接超时时间，默认为60秒
- (NSTimeInterval)requestTimeoutInterval;

/// 请求的参数列表
- (id)requestArgument;

/// 用于在cache结果，计算cache文件名时，忽略掉一些指定的参数
- (id)cacheFileNameFilterForRequestArgument:(id)argument;

/// Http请求的方法
- (XLRequestMethod)requestMethod;

/// 请求的SerializerType
- (YTKRequestSerializerType)requestSerializerType;


/// 在HTTP报头添加的自定义参数
- (NSDictionary *)requestHeaderFieldValueDictionary;

/// 是否使用CDN的host地址
- (BOOL)useCDN;

/// 用于检查JSON是否合法的对象
- (id)jsonValidator;

/// 用于检查Status Code是否正常的方法
- (BOOL)statusCodeValidator;

/// 当POST的内容带有文件等富文本时使用
- (AFConstructingBlock)constructingBodyBlock;

// 是否使用用户验证信息
- (BOOL)needToken;

// 是否过滤成功的状态码
- (BOOL)successCodeCheck;

// 是否过滤过期的状态码
- (BOOL)overDueCodeCheck;

@end
