//
//  XLRequest.m
//  XLNetWorking
//
//  Created by chuxiaolong on 15/8/13.
//  Copyright (c) 2015年 chuxiaolong. All rights reserved.
//

#import "XLCacheRequest.h"
#import "XLNetworkConfig.h"
#import "XLNetworkPrivate.h"
@interface XLCacheRequest()

@property (strong, nonatomic) id cacheJson;

@end
@implementation XLCacheRequest{
    BOOL _dataFromCache;
}
- (NSInteger)cacheTimeInSeconds {
    return -1;
}

- (long long)cacheVersion {
    return 0;
}

- (id)cacheSensitiveData {
    return nil;
}

- (void)checkDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

- (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        XLLog(@"create cache directory failed, error = %@", error);
    } else {
        [XLNetworkPrivate addDoNotBackupAttribute:path];
    }
}

- (NSString *)cacheBasePath {
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"LazyRequestCache"];    
    [self checkDirectory:path];
    return path;
}

- (NSString *)cacheFileName {
    NSString *requestUrl = [self requestUrl];
    NSString *baseUrl = [XLNetworkConfig sharedInstance].baseUrl;
    id argument = [self cacheFileNameFilterForRequestArgument:[self requestArgument]];
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%ld Host:%@ Url:%@ Argument:%@ AppVersion:%@ Sensitive:%@",
                             (long)[self requestMethod], baseUrl, requestUrl,
                             argument, [XLNetworkPrivate appVersionString], [self cacheSensitiveData]];
    NSString *cacheFileName = [XLNetworkPrivate md5StringFromString:requestInfo];
    return cacheFileName;
}

- (NSString *)cacheFilePath {
    NSString *cacheFileName = [self cacheFileName];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

- (NSString *)cacheVersionFilePath {
    NSString *cacheVersionFileName = [NSString stringWithFormat:@"%@.version", [self cacheFileName]];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheVersionFileName];
    return path;
}

- (long long)cacheVersionFileContent {
    NSString *path = [self cacheVersionFilePath];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        NSNumber *version = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        return [version longLongValue];
    } else {
        return 0;
    }
}

- (int)cacheFileDuration:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // get file attribute
    NSError *attributesRetrievalError = nil;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path
                                                             error:&attributesRetrievalError];
    if (!attributes) {
        XLLog(@"Error get attributes for file at %@: %@", path, attributesRetrievalError);
        return -1;
    }
    int seconds = -[[attributes fileModificationDate] timeIntervalSinceNow];
    return seconds;
}

- (void)start {
    if (self.ignoreCache) {
        [super start];
        return;
    }
    
    // check cache time
    if ([self cacheTimeInSeconds] < 0) {
        [super start];
        return;
    }
    
    // check cache version
    long long cacheVersionFileContent = [self cacheVersionFileContent];
    if (cacheVersionFileContent != [self cacheVersion]) {
        [super start];
        return;
    }
    
    // check cache existance
    NSString *path = [self cacheFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path isDirectory:nil]) {
        [super start];
        return;
    }
    
    // check cache time
    int seconds = [self cacheFileDuration:path];
    if (seconds < 0 || seconds > [self cacheTimeInSeconds]) {
        [super start];
        return;
    }
    
    // load cache
    _cacheJson = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (_cacheJson == nil) {
        [super start];
        return;
    }
    
    _dataFromCache = YES;
    [self requestCompleteFilterAndCode:199 message:nil];
    XLCacheRequest *strongSelf = self;
    if (strongSelf.successCompletionBlock) {
        strongSelf.successCompletionBlock(strongSelf);
    }
    [strongSelf clearCompletionBlock];
}

- (void)startWithoutCache {
    [super start];
}

- (id)cacheJson {
    if (_cacheJson) {
        return _cacheJson;
    } else {
        NSString *path = [self cacheFilePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path isDirectory:nil] == YES) {
            _cacheJson = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }
        return _cacheJson;
    }
}

- (BOOL)isDataFromCache {
    return _dataFromCache;
}

- (BOOL)isCacheVersionExpired {
    // check cache version
    long long cacheVersionFileContent = [self cacheVersionFileContent];
    if (cacheVersionFileContent != [self cacheVersion]) {
        return YES;
    } else {
        return NO;
    }
}

- (id)responseJSONObject {
    if (_cacheJson) {
        return _cacheJson;
    } else {
        return [super responseJSONObject];
    }
}

#pragma mark - Network Request Delegate

- (void)requestCompleteFilterAndCode:(NSInteger)code message:(NSString*)message {
    [super requestCompleteFilterAndCode:code message:message];
    [self saveJsonResponseToCacheFile:[super responseJSONObject]];
}

// 手动将其他请求的JsonResponse写入该请求的缓存
// 比如AddNoteApi, UpdateNoteApi都会获得Note，且其与GetNoteApi共享缓存，可以通过这个接口写入GetNoteApi缓存
- (void)saveJsonResponseToCacheFile:(id)jsonResponse {
    if ([self cacheTimeInSeconds] > 0 && ![self isDataFromCache]) {
        NSDictionary *json = jsonResponse;
        if (json != nil) {
            [NSKeyedArchiver archiveRootObject:json toFile:[self cacheFilePath]];
            [NSKeyedArchiver archiveRootObject:@([self cacheVersion]) toFile:[self cacheVersionFilePath]];
        }
    }
}


@end
