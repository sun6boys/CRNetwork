//
//  XLNetworkConfig.h
//  XLNetWorking
//
//  Created by chuxiaolong on 15/8/13.
//  Copyright (c) 2015年 chuxiaolong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLBaseRequest.h"


#define NET_STATS_NONE   @"当前无网络连接,请检查网络"
#define NET_STATS_ERROR  @"当前网络异常, 请稍后重试"
#define NET_STATS_OVERDUE @"验证过期，请重新登录"
@interface XLNetworkConfig : NSObject




+ (XLNetworkConfig *)sharedInstance;

@property (strong, nonatomic) NSString *baseUrl;
@property (strong, nonatomic) NSString *cdnUrl;


@property (nonatomic, copy)   NSString     * CODE_KEY_PATH;      //比如result{ state: }
@property (nonatomic, assign) NSInteger      SUCCESS_CODE;       //请求成功的状态码，0是成功 255是请求失败等
@property (nonatomic, copy)   NSString     * MSG_KEY_PATH;       //返回消息的key比如state：{message：“请求成功”}
@property (nonatomic, copy)   NSArray      * OVERDUE_CODES;      //返回类似token过期的验证码（用于让用户重新登录）
//设置初始信息
+ (void)SetInitialInformation;
//构建自己的parameters
+ (NSDictionary*)getBaseParametersWithRequest:(XLBaseRequest*)request;
@end
