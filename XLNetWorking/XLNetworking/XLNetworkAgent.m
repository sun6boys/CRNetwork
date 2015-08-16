//
//  XLNetworkAgent.m
//  XLNetWorking
//
//  Created by chuxiaolong on 15/8/13.
//  Copyright (c) 2015年 chuxiaolong. All rights reserved.
//

#import "XLNetworkAgent.h"
#import "XLNetworkConfig.h"
#import "XLNetworkPrivate.h"
#import "XLNetReachability.h"
void XLLog(NSString *format, ...) {
#ifdef DEBUG
    va_list argptr;
    va_start(argptr, format);
    NSLogv(format, argptr);
    va_end(argptr);
#endif
}



@implementation XLNetworkAgent{
    AFHTTPRequestOperationManager *_manager;
    XLNetworkConfig *_config;
    NSMutableDictionary *_requestsRecord;
}

+ (XLNetworkAgent *)sharedInstance {
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
        _config = [XLNetworkConfig sharedInstance];
        _manager = [AFHTTPRequestOperationManager manager];
        _requestsRecord = [NSMutableDictionary dictionary];
        //设置最大并发数是4个。
        _manager.operationQueue.maxConcurrentOperationCount = 4;
    }
    return self;
}
- (NSString *)buildRequestUrl:(XLBaseRequest *)request {
    NSString *detailUrl = [request requestUrl];
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    // filter url
 
    NSString *baseUrl;
    if ([request useCDN]) {
        if ([request cdnUrl].length > 0) {
            baseUrl = [request cdnUrl];
        } else {
            baseUrl = [_config cdnUrl];
        }
    } else {
        if ([request baseUrl].length > 0) {
            baseUrl = [request baseUrl];
        } else {
            baseUrl = [_config baseUrl];
        }
    }
    return [NSString stringWithFormat:@"%@%@",baseUrl,detailUrl];
}

- (void)addRequest:(XLBaseRequest *)request {

    if (![[XLNetReachability sharedInstance] isNetWorkConnect]) {
        [request requestFailedFilterAndCode:1999999 message:NET_STATS_NONE];
        if (request.failureCompletionBlock) {
            request.failureCompletionBlock(request);
        }
        return;
    }
    XLRequestMethod method = [request requestMethod];
    NSString *url = [self buildRequestUrl:request];
    id param = [XLNetworkConfig getBaseParametersWithRequest:request];
    XLLog(@"param = %@",param);
    AFConstructingBlock constructingBlock = [request constructingBodyBlock];
    
    if (request.requestSerializerType == YTKRequestSerializerTypeHTTP) {
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == YTKRequestSerializerTypeJSON) {
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    _manager.requestSerializer.timeoutInterval = [request requestTimeoutInterval];
        if (method == XLRequestMethodGet) {
                request.requestOperation = [_manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [self handleRequestResult:operation];
                }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self handleRequestResult:operation];
                }];
        } else if (method == XLRequestMethodPost) {
            if (constructingBlock != nil) {
                request.requestOperation = [_manager POST:url parameters:param constructingBodyWithBlock:constructingBlock
                                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                      [self handleRequestResult:operation];
                                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                      [self handleRequestResult:operation];
                                                  }];
            } else {
                request.requestOperation = [_manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [self handleRequestResult:operation];
                }                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self handleRequestResult:operation];
                }];
            }
        } else if (method == XLRequestMethodPut) {
            request.requestOperation = [_manager PUT:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self handleRequestResult:operation];
            }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self handleRequestResult:operation];
            }];
        } else {
            XLLog(@"Error, unsupport method type");
            return;
        }
    
    XLLog(@"Add request: %@", NSStringFromClass([request class]));
    [self addOperation:request];
}

- (void)handleRequestResult:(AFHTTPRequestOperation *)operation {
    
    NSString *key = [self requestHashKey:operation];
    XLBaseRequest *request = _requestsRecord[key];
    XLLog(@"Finished Request: %@", NSStringFromClass([request class]));
    if (request) {
        BOOL succeed = [self checkResult:request];
        if (succeed) {
            if ([request successCodeCheck]) {
                NSString*code =  [XLNetworkPrivate objectAtPath:[XLNetworkConfig sharedInstance].CODE_KEY_PATH by:[request responseJSONObject]];
                NSString*message = [XLNetworkPrivate objectAtPath:[XLNetworkConfig sharedInstance].MSG_KEY_PATH by:[request responseJSONObject]];
                if (code&&([code integerValue] == [XLNetworkConfig sharedInstance].SUCCESS_CODE)) {
                    [request requestCompleteFilterAndCode:[code integerValue] message:message];
                    if (request.successCompletionBlock) {
                        request.successCompletionBlock(request);
                    }
                }else{
                    if ([request overDueCodeCheck]&&[XLNetworkConfig sharedInstance].OVERDUE_CODES) {
                        BOOL isOverDue = NO;
                        for (NSNumber * returnCode in [XLNetworkConfig sharedInstance].OVERDUE_CODES) {
                            if ([returnCode integerValue] == [code integerValue]) {
                                isOverDue = YES;
                                break;
                            }
                        }
                        if (isOverDue) {
                            message = message?message:NET_STATS_OVERDUE;
                            [request requestFailedFilterAndCode:[code integerValue] message:message];
                            if (request.failureCompletionBlock) {
                                request.failureCompletionBlock(request);
                            }
                            //此处要发送通知告知验证过期
                            
                        }else{
                            message = message?message:NET_STATS_ERROR;
                             [request requestFailedFilterAndCode:[code integerValue] message:message];
                            if (request.failureCompletionBlock) {
                                request.failureCompletionBlock(request);
                            }
                        }
                    }else{
                        message = message?message:NET_STATS_ERROR;
                        [request requestFailedFilterAndCode:[code integerValue] message:message];
                        if (request.failureCompletionBlock) {
                            request.failureCompletionBlock(request);
                        }
                    }
                }
            }
            
        } else {
            XLLog(@"Request %@ failed, status code = %ld",
                   NSStringFromClass([request class]), (long)request.responseStatusCode);
            [request requestFailedFilterAndCode:199999999 message:NET_STATS_ERROR];
            if (request.failureCompletionBlock) {
                request.failureCompletionBlock(request);
            }
        }
    }
    [self removeOperation:operation];
    [request clearCompletionBlock];
    
    
    
}
- (NSString *)requestHashKey:(AFHTTPRequestOperation *)operation {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[operation hash]];
    return key;
}

- (void)addOperation:(XLBaseRequest *)request {
    if (request.requestOperation != nil) {
        NSString *key = [self requestHashKey:request.requestOperation];
        @synchronized(self) {
            _requestsRecord[key] = request;
        }
    }
}

- (void)removeOperation:(AFHTTPRequestOperation *)operation {
    NSString *key = [self requestHashKey:operation];
    @synchronized(self) {
        [_requestsRecord removeObjectForKey:key];
    }
    XLLog(@"Request queue size = %lu", (unsigned long)[_requestsRecord count]);
}
- (void)cancelRequest:(XLBaseRequest *)request {
    [request.requestOperation cancel];
    [self removeOperation:request.requestOperation];
    [request clearCompletionBlock];
}

- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        XLBaseRequest *request = copyRecord[key];
        [request stop];
    }
}

- (BOOL)checkResult:(XLBaseRequest *)request {
    BOOL result = [request statusCodeValidator];
    if (!result) {
        return result;
    }
    id validator = [request jsonValidator];
    if (validator != nil) {
        id json = [request responseJSONObject];
        result = [XLNetworkPrivate checkJson:json withValidator:validator];
    }
    return result;
}

@end
