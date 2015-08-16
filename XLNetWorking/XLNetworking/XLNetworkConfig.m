//
//  XLNetworkConfig.m
//  XLNetWorking
//
//  Created by chuxiaolong on 15/8/13.
//  Copyright (c) 2015年 chuxiaolong. All rights reserved.
//

#import "XLNetworkConfig.h"

@implementation XLNetworkConfig

+ (XLNetworkConfig *)sharedInstance {
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
        
    }
    return self;
}

//设置初始信息
+ (void)SetInitialInformation
{
    [self setupRequestURL];
    [self setResponseResultCheckCode];
}
+ (void)setupRequestURL{
    XLNetworkConfig *config = [XLNetworkConfig sharedInstance];
    config.baseUrl = @"http://api.xxx.com";         //设置请求url
    config.cdnUrl = @"http://soa.app.j1.com";        //设置cdnurl ,比如图片上传地址等
}
+ (void)setResponseResultCheckCode{
    XLNetworkConfig *config = [XLNetworkConfig sharedInstance];
    //设置服务端返回成功的状态码
    config.SUCCESS_CODE = 1;
    NSDictionary * demoDict1 = @{@"result":@{},
                                 @"state":@{@"code":@"状态码",
                                            @"message":@"消息内容"}
                                 };
    NSDictionary * demoDict2 = @{@"result":@{},
                                 @"code":@"0",
                                 @"message":@"消息内容"
                                 };
    //如果服务器返回内容格式是demoDict1样式,CODE_KEY_PATH应该设置为@"state/code"或者@"state.code"
    //服务服务器返回内容格式是demoDict2样式,CODE_KEY_PATH应该设置为@"code"
    config.CODE_KEY_PATH = @"status/code";
    config.MSG_KEY_PATH = @"status/desp";
    //有时候账户在其他机器登陆过，服务器会生成新的token，原来的机子再打开，用保存下来的token请求服务器会告知失效，我们公司状态码是202时意思是token失效，但是有时候会有其他的情况比如验签失败此类，应当同token失效一样处理，（此时应当提醒用户重新登录），所以OVERDUE_CODES内传入一个数组
    config.OVERDUE_CODES = @[@202,@1000];
}
+ (NSDictionary*)getBaseParametersWithRequest:(XLBaseRequest*)request
{
    //示例代码见 + (NSDictionary*)DemoGetBaseParameters:(XLBaseRequest*)request
     NSMutableDictionary *ParametersDic = [[NSMutableDictionary alloc]init];
    [ParametersDic setObject:@"0" forKey:@"cityCode"];
    [ParametersDic setObject:@"2" forKey:@"osType"];
    [ParametersDic setObject:@"1.4" forKey:@"appVersion"];
    [ParametersDic setObject:@"10000" forKey:@"channelId"];
    [ParametersDic setObject:@"1.0" forKey:@"apiVersion"];
    NSString * string = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:ParametersDic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
   NSString* nonce = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    NSDictionary * dic = @{@"data":string,
                           @"nonce":nonce};
    
    return dic;
}

+ (NSDictionary*)DemoGetBaseParameters:(XLBaseRequest*)request{
    NSMutableDictionary *ParametersDic = [[NSMutableDictionary alloc]init];
    if ([request requestArgument]&&[[request requestArgument] isKindOfClass:[NSDictionary class]]) {
        [ParametersDic setValuesForKeysWithDictionary:[request requestArgument]];
    }
    
    //以下根据自己公司实际情况填写
    if ([request needToken]) {
        NSString * token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
        [ParametersDic setObject:token forKey:@"token"];
    }
    [ParametersDic setObject:@"1.0" forKey:@"apiVersion"];
    [ParametersDic setObject:@"2012-01-30 10:30" forKey:@"time"];
    [ParametersDic setObject:@"2" forKey:@"osType"];
    [ParametersDic setObject:@"1.4" forKey:@"appVersion"];
    [ParametersDic setObject:@"10000" forKey:@"channelId"];
    //    return ParametersDic;
    
    NSString * string = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:ParametersDic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    NSDictionary * dic = @{@"data":string};
    return dic;

}



@end
