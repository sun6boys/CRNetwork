//
//  XLBaseRequest.m
//  XLNetWorking
//
//  Created by chuxiaolong on 15/8/13.
//  Copyright (c) 2015年 chuxiaolong. All rights reserved.
//

#import "XLBaseRequest.h"
#import "XLNetworkAgent.h"
@implementation XLBaseRequest
/// for subclasses to overwrite
- (void)requestCompleteFilterAndCode:(NSInteger)code message:(NSString*)message {
}

- (void)requestFailedFilterAndCode:(NSInteger)code message:(NSString*)message {
}

- (NSString *)requestUrl {
    return @"";
}

- (NSString *)cdnUrl {
    return @"";
}

- (NSString *)baseUrl {
    return @"";
}

- (NSTimeInterval)requestTimeoutInterval {
    return 60;
}

- (id)requestArgument {
    return nil;
}

- (id)cacheFileNameFilterForRequestArgument:(id)argument {
    return argument;
}

- (XLRequestMethod)requestMethod {
    return XLRequestMethodGet;
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeHTTP;
}



- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}


- (BOOL)useCDN {
    return NO;
}

- (id)jsonValidator {
    return nil;
}

- (BOOL)statusCodeValidator {
    NSInteger statusCode = [self responseStatusCode];
    if (statusCode >= 200 && statusCode <=299) {
        return YES;
    } else {
        return NO;
    }
}

- (AFConstructingBlock)constructingBodyBlock {
    return nil;
}

- (BOOL)needToken
{
    return YES;
}

- (BOOL)successCodeCheck{
    return YES;
}

- (BOOL)overDueCodeCheck{
    return YES;
}


/// append self to request queue
- (void)start {
    [[XLNetworkAgent sharedInstance] addRequest:self];
}

/// remove self from request queue
- (void)stop {
    [[XLNetworkAgent sharedInstance] cancelRequest:self];

}

- (BOOL)isExecuting {
    return self.requestOperation.isExecuting;
}

- (void)startWithCompletionBlockWithSuccess:(void (^)(XLBaseRequest *request))success
                                    failure:(void (^)(XLBaseRequest *request))failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(void (^)(XLBaseRequest *request))success
                              failure:(void (^)(XLBaseRequest *request))failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

- (id)responseJSONObject {
    return self.requestOperation.responseObject;
}

- (NSString *)responseString {
    return self.requestOperation.responseString;
}

- (NSInteger)responseStatusCode {
    return self.requestOperation.response.statusCode;
}

- (NSDictionary *)responseHeaders {
    return self.requestOperation.response.allHeaderFields;
}

@end
