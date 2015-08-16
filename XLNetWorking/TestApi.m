//
//  TestApi.m
//  XLNetWorking
//
//  Created by chuxiaolong on 15/8/16.
//  Copyright (c) 2015年 chuxiaolong. All rights reserved.
//

#import "TestApi.h"

@implementation TestApi



-(NSString*)requestUrl
{
    return @"/user/showSlide";
}
- (XLRequestMethod)requestMethod {
    return XLRequestMethodPost;
}
@end
