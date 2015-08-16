//
//  XLNetworkPrivate.h
//  XLNetWorking
//
//  Created by chuxiaolong on 15/8/13.
//  Copyright (c) 2015年 chuxiaolong. All rights reserved.
//

#import <Foundation/Foundation.h>
FOUNDATION_EXPORT void XLLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);
@interface XLNetworkPrivate : NSObject
+ (BOOL)checkJson:(id)json withValidator:(id)validatorJson;
+ (void)addDoNotBackupAttribute:(NSString *)path;

+ (NSString *)md5StringFromString:(NSString *)string;

+ (NSString *)appVersionString;

+ (id)objectAtPath:(NSString*)path by:(NSDictionary*)dictonary;
@end
