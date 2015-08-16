//
//  XLRequest.m
//  XLNetWorking
//
//  Created by chuxiaolong on 15/8/16.
//  Copyright (c) 2015年 chuxiaolong. All rights reserved.
//

#import "XLRequest.h"


NSString * const RequestStateSuccess = @"RequestDidSuccess";
NSString * const RequestStateFailed = @"RequestDidFailed";
NSString * const RequestStateSending = @"RequestDidSending";
NSString * const RequestStateError = @"RequestDidError";
NSString * const RequestStateCancle = @"RequestDidCancle";

@implementation XLRequest



- (BOOL)succeed{
    if (![self responseJSONObject]) {
        return NO;
    }
    return RequestStateSuccess == _state ? YES : NO;
}

- (BOOL)failed{
    return RequestStateFailed == _state || RequestStateError == _state ? YES : NO;
}


- (void)requestCompleteFilterAndCode:(NSInteger)code message:(NSString*)message{
    [super requestCompleteFilterAndCode:code message:message];
    self.code = code;
    self.message = message;
    self.state = RequestStateSuccess;
}
- (void)requestFailedFilterAndCode:(NSInteger)code message:(NSString*)message{
    [super requestCompleteFilterAndCode:code message:message];
    self.code = code;
    self.message = message;
    self.state = RequestStateFailed;
}
@end
