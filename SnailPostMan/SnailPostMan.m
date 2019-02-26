//
//  SnailPostMan.m
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/12/11.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailPostMan.h"
#import "SnailPostManUtil.h"
#import "SnailPostManServiceController.h"
#import "SnailPostManCacheController.h"
#import "SnailPostManTaskManager.h"
#import "SnailPostManAF.h"

#define SNAIL_POSTMAN_EXECPTION @"com.snailpostman.error"

#define SNAIL_POST_MAN_LOG_URL @"URL"
#define SNAIL_POST_MAN_LOG_PARAMS @"PARAMS"
#define SNAIL_POST_MAN_LOG_OVER_TIME @"OVER_TIME"
#define SNAIL_POST_MAN_LOG_HTTP_HEADER @"HTTP_HEADER"
#define SNAIL_POST_MAN_LOG_COOKIE @"COOKIE"
#define SNAIL_POST_MAN_LOG_METHOD_TYPE @"METHOD_TYPE"
#define SNAIL_POST_MAN_LOG_REQUEST_STRATEGY @"REQUEST_STRAGTEGY"
#define SNAIL_POST_MAN_LOG_CACHE_STRATEGY @"CACHE_STRATEGY"
#define SNAIL_POST_MAN_LOG_CHECKER @"CHECKER"
#define SNAIL_POST_MAN_LOG_SCREEN @"SCREEN"
#define SNAIL_POST_MAN_LOG_SERVICE @"SERVICE"
#define SNAIL_POST_MAN_LOG_SERVICE_EXPLAIN @"SERVICE_EXPLAIN"
#define SNAIL_POST_MAN_LOG_ERROR @"ERROR"
#define SNAIL_POST_MAN_LOG_RESPONSE @"RESPONSE"
#define SNAIL_POST_MAN_LOG_SNAIL_CACHE_TIME @"SNAIL_CACHE_TIME"

@interface SnailPostMan()

@property (nonatomic ,weak) NSURLSessionTask *task;
@property (nonatomic) BOOL isSending;

@end

@implementation SnailPostMan

static inline NSArray *_sna_take_snail_postman_info_keys() {
    return @[SnailPostManUploadFileKey,SnailPostManScreenKey,SnailPostManCheckerKey,SnailPostManServiceKey,SnailPostManMethodNameKey,SnailPostManHttpsCerKey];
}

static inline NSString *_sna_take_request_method_type_name(SnailPostManMethodType type) {
    NSString *str = nil;
    switch (type) {
        case SnailPostManMethodTypeGET:str = @"GET";
            break;
        case SnailPostManMethodTypePUT:str = @"PUT";
            break;
        case SnailPostManMethodTypePOST:str = @"POST";
            break;
        case SnailPostManMethodTypeDELETE:str = @"DELETE";
            break;
        case SnailPostManMethodTypePOST_JSON:str = @"POST_JSON";
            break;
        default: break;
    }
    return str;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *tmp = NSStringFromClass(self.class);
        if (![tmp hasSuffix:@"PostMan"]) {
            NSAssert(nil, @"Must Suffix 'PostMan'");
        }
    }
    return self;
}

- (void)sendResponse:(id<SnailPostManResponseProtocol>)response Params:(NSDictionary *)params Tag:(NSInteger)tag Context:(id)context {

    self.isSending = true;
    
    id<SnailPostManServiceProtocol> sna_postman_service = [self sna_find_postman_service:params];
    
    NSDictionary *handle_params = [self sna_take_target_params:params Service:sna_postman_service Tag:tag Context:context];
    NSDictionary *sna_postman_params = [self sna_take_out_snail_postman_params:handle_params];
    NSDictionary *target_params = [self sna_filter_snail_postman_params:handle_params];
    
    NSString *methodName = [self sna_find_postman_method_name:sna_postman_params];
    
    NSString *url = [self sna_find_postman_url:methodName Service:sna_postman_service Tag:tag Context:context];
    
    NSTimeInterval overTime = [self sna_take_overTime:sna_postman_service];
    NSTimeInterval cacheTime = [self sna_take_cache_time:sna_postman_service];
    NSDictionary *httpHeaderFileds = [self sna_take_httpHeader:sna_postman_service];
    NSDictionary *cookie = [self sna_take_cookies:sna_postman_service];
    SnailPostManMethodType methodType = [self sna_take_method_type:sna_postman_service];
    NSString *methodTypeName = _sna_take_request_method_type_name(methodType);
    SnailPostManRequestStrategy requestStrategy = [self sna_take_request_strategy:sna_postman_service];
    SnailPostManCacheStrategy cacheStrategy = [self sna_take_cache_strategy:sna_postman_service];
    NSURLRequestCachePolicy request_cache_strategy = [self sna_take_url_cache_strategy:cacheStrategy];
    id<SnailPostManCheckProtocol> checker = [self sna_take_checker:sna_postman_params Service:sna_postman_service];
    id<SnailPostManScreenProtocol> screen = [self sna_take_screen:sna_postman_params];
    
    BOOL log = [self sna_take_log_info:sna_postman_service];
    NSURL *logUrl = [self sna_take_log_url:sna_postman_service];
    NSMutableDictionary *logDic = [NSMutableDictionary new];
    if (log) {
        logDic[SNAIL_POST_MAN_LOG_URL] = url;
        logDic[SNAIL_POST_MAN_LOG_PARAMS] = target_params;
        logDic[SNAIL_POST_MAN_LOG_OVER_TIME] = @(overTime);
        logDic[SNAIL_POST_MAN_LOG_HTTP_HEADER] = httpHeaderFileds;
        logDic[SNAIL_POST_MAN_LOG_COOKIE] = cookie;
        logDic[SNAIL_POST_MAN_LOG_METHOD_TYPE] = methodTypeName;
        logDic[SNAIL_POST_MAN_LOG_REQUEST_STRATEGY] = @(requestStrategy);
        logDic[SNAIL_POST_MAN_LOG_CACHE_STRATEGY] = @(cacheStrategy);
        if (checker) logDic[SNAIL_POST_MAN_LOG_CHECKER] = NSStringFromClass(checker.class);
        if (screen) logDic[SNAIL_POST_MAN_LOG_SCREEN] = NSStringFromClass(screen.class);
        logDic[SNAIL_POST_MAN_LOG_SERVICE] = NSStringFromClass(sna_postman_service.class);
        logDic[SNAIL_POST_MAN_LOG_SERVICE_EXPLAIN] = sna_postman_service.explain;
        logDic[SNAIL_POST_MAN_LOG_SNAIL_CACHE_TIME] = @(cacheTime);
    }
    
    if (checker) {
        if (![checker checkParams:target_params Cls:self.class MethodName:methodName MethodType:methodType Tag:tag Context:context]) {
            NSError *error = [NSError errorWithDomain:SnailPostManErrorDomain code:-101 userInfo:@{NSLocalizedDescriptionKey:@"params error"}];
            [response SnailPostManResponseFalied:error Info:nil Class:self.class Tag:tag Context:context];
            logDic[SNAIL_POST_MAN_LOG_ERROR] = error.localizedDescription;
            [self sna_log:log LogDic:logDic LogPath:logUrl];
            self.isSending = false;
            return;
        }
    }
    
    if (cacheStrategy == SnailPostManCacheStrategyMemoryCache || cacheStrategy == SnailPostManCacheStrategyArchive) {
        id result = [SnailPostManCacheController takeCacheType:cacheStrategy
                                        Path:url
                                         Header:httpHeaderFileds
                                         Cookies:cookie
                                         Params:target_params
                                       MethodType:methodTypeName
                                       Tag:tag
                                       Context:context];
        if (result) {
            if ([result isKindOfClass:[NSError class]]) {
                NSError *error = (NSError *)result;
                [response SnailPostManResponseFalied:error Info:nil Class:self.class Tag:tag Context:context];
                logDic[SNAIL_POST_MAN_LOG_ERROR] = error.localizedDescription;
                [self sna_log:log LogDic:logDic LogPath:logUrl];
            }
            else {
                [self sna_detail_success_response:result
                                          Service:sna_postman_service
                                          Checker:checker
                                           Screen:screen
                                         Response:response
                                            Cache:cacheStrategy
                                              Url:url
                                       MethodName:methodName
                                             Info:nil
                                       HttpHeader:httpHeaderFileds
                                           Cookie:cookie
                                        CacheTime:cacheTime
                                           Params:target_params
                                       MethodType:methodType
                                              Tag:tag
                                          Context:context
                                              Log:log
                                           LogDic:logDic
                                          LogPath:logUrl];
            }
        }
        return;
    }
    
    NSString *requestidentifer = nil;
    switch (self.requestIdentiferStrategy) {
        case SnailPostManRequestIdentiferStrategyDefault:
            requestidentifer = [SnailPostManUtil createRequestIdentifer:url Header:httpHeaderFileds Cookie:cookie Params:target_params Tag:tag];
            break;
        case SnailPostManRequestIdentiferStrategyMethod:
            requestidentifer = [SnailPostManUtil createRequestIdentifer:url Header:nil Cookie:nil Params:nil Tag:tag];
            break;
    }
    
    NSURLSessionTask *latsTask = [SnailPostManTaskManager takeTaskWithIdentifer:requestidentifer];
    if (latsTask) {
        switch (requestStrategy) {
            case SnailPostManRequestStrategyCancleLast:
                [latsTask cancel];
                [SnailPostManTaskManager removeTaskWithIdentifer:requestidentifer];
                break;
            case SnailPostManRequestStrategyCancleCurrent:
                self.isSending = false;
                return;
            default:
                break;
        }
    }
    
    if (sna_postman_params[SnailPostManHttpsCerKey]) {
        [SnailPostManAF HttpsCer:sna_postman_params[SnailPostManHttpsCerKey]];
    }
    
    NSURLSessionTask *task = [SnailPostManAF URL:url MethodTypeName:methodTypeName Cache:request_cache_strategy OverTime:overTime Params:target_params File:sna_postman_params[SnailPostManUploadFileKey] RequestHeaders:httpHeaderFileds Cookies:cookie DownloadProgress:^(NSProgress *pgre) {
        
        if ([response respondsToSelector:@selector(SnailPostManResponseDownloadProgress:Class:Tag:Context:)]) {
            [response SnailPostManResponseDownloadProgress:pgre Class:self.class Tag:tag Context:context];
        }
        
    } UploadProgress:^(NSProgress *pgre) {
        
        if ([response respondsToSelector:@selector(SnailPostManResponseUploadProgress:Class:Tag:Context:)]) {
            [response SnailPostManResponseUploadProgress:pgre Class:self.class Tag:tag Context:context];
        }
        
    } Success:^(NSURLResponse * _Nonnull responseUrl, id ressponseData) {
        
        [SnailPostManTaskManager removeTaskWithIdentifer:requestidentifer];
        
        SnailPostManResponseInfo *info = [self sna_create_response_info:responseUrl];
        [self sna_detail_success_response:ressponseData
                                  Service:sna_postman_service
                                  Checker:checker
                                   Screen:screen
                                 Response:response
                                    Cache:cacheStrategy
                                      Url:url
                               MethodName:methodName
                                     Info:info
                               HttpHeader:httpHeaderFileds
                                   Cookie:cookie
                                CacheTime:30
                                   Params:target_params
                               MethodType:methodType
                                      Tag:tag
                                  Context:context
                                      Log:log
                                   LogDic:logDic
                                  LogPath:logUrl];
        
    } Falied:^(NSURLResponse * _Nonnull responseUrl, NSError *error) {
        SnailPostManResponseInfo *info = [self sna_create_response_info:responseUrl];
        [response SnailPostManResponseFalied:error Info:info Class:self.class Tag:tag Context:context];
        [SnailPostManTaskManager removeTaskWithIdentifer:requestidentifer];
    }];
    [task resume];
    self.task = task;
    [SnailPostManTaskManager saveTask:task Identifer:requestidentifer];
    self.isSending = false;
    
}

- (NSDictionary *)sna_take_out_snail_postman_params:(NSDictionary *)dic {
    
    NSMutableDictionary *sna_snail_postman_params = [NSMutableDictionary new];
    [_sna_take_snail_postman_info_keys() enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id objc = dic[obj];
        if (objc) sna_snail_postman_params[obj] = objc;
    }];
    if (sna_snail_postman_params.count > 0) return sna_snail_postman_params.copy;
    return nil;
    
}

- (NSDictionary *)sna_filter_snail_postman_params:(NSDictionary *)dic {
    
    NSMutableDictionary *tmpdic = nil;
    if ([dic isKindOfClass:[NSMutableDictionary class]]) tmpdic = (NSMutableDictionary *)dic;
    else tmpdic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [tmpdic removeObjectsForKeys:_sna_take_snail_postman_info_keys()];
    return tmpdic.copy;
    
}

- (id<SnailPostManServiceProtocol>)sna_find_postman_service:(NSDictionary *)postmandic {
    
    id<SnailPostManServiceProtocol> service = nil;
    if (postmandic[SnailPostManServiceKey]) service = postmandic[SnailPostManServiceKey];
    else if (self.service) service = self.service;
    else {
        NSString *identifer = self.serviceIdentifer;
        if (!identifer) identifer = SnailPostManDefaultServiceIdentifer;
        service = [[SnailPostManServiceController sharedInstance] takeServiceWithIdentifer:identifer];
    }
    if (!service) {
        @throw [NSException exceptionWithName:SNAIL_POSTMAN_EXECPTION reason:NSLocalizedString(@"have no service", nil) userInfo:nil];
    }
    return service;
    
}

- (NSString *)sna_find_postman_method_name:(NSDictionary *)postmandic {
    
    NSString *methodName = nil;
    if (postmandic[SnailPostManMethodNameKey]) methodName = postmandic[SnailPostManMethodNameKey];
    else if (self.methodName) methodName = self.methodName;
    
    if (!self.methodName) {
        @throw [NSException exceptionWithName:SNAIL_POSTMAN_EXECPTION reason:NSLocalizedString(@"have no methodName", nil) userInfo:nil];
    }
    
    NSString *pathParam = nil;
    if (postmandic[SnailPostManPathParamKey]) pathParam = postmandic[SnailPostManPathParamKey];
    else if (self.pathParam) pathParam = self.pathParam;
    
    NSString *path = nil;
    if (pathParam) {
        if ([methodName hasSuffix:@"/"]) {
            methodName = [methodName substringToIndex:methodName.length - 1];
        }
        if ([methodName hasPrefix:@"/"]) {
            methodName = [methodName substringFromIndex:1];
        }
        if ([pathParam hasPrefix:@"/"]) {
            pathParam = [pathParam substringFromIndex:1];
        }
        path = [NSString stringWithFormat:@"%@/%@",methodName,pathParam];
    }
    else path = methodName;
    
    return path;
    
}

- (NSString *)sna_find_postman_url:(NSString *)path Service:(id<SnailPostManServiceProtocol>)service Tag:(NSInteger)tag Context:(id)context {
    return [service composeUrl:path Tag:tag Context:context];
}

- (NSDictionary *)sna_take_target_params:(NSDictionary *)dic Service:(id<SnailPostManServiceProtocol>)service Tag:(NSInteger)tag Context:(id)context {
    return [service handleParams:dic Tag:tag Context:context];
}

- (NSTimeInterval)sna_take_overTime:(id<SnailPostManServiceProtocol>)service {
    NSTimeInterval overtime = 0;
    if (self.overTime > 0) overtime = self.overTime;
    else if ([service respondsToSelector:@selector(overTime)]) overtime = [service overtime];
    if (overtime < 3) overtime = 30;
    return overtime;
}

- (NSTimeInterval)sna_take_cache_time:(id<SnailPostManServiceProtocol>)service {
    NSTimeInterval cachetime = 0;
    if (self.snailMaxCacheTime > 0) cachetime = self.snailMaxCacheTime;
    else if ([service respondsToSelector:@selector(snailMaxCacheTime)]) cachetime = [service snailMaxCacheTime];
    return cachetime;
}

- (NSDictionary *)sna_take_httpHeader:(id<SnailPostManServiceProtocol>)service {
    NSDictionary *header = nil;
    if (self.headerFileds) header = self.headerFileds;
    else if ([service respondsToSelector:@selector(httpHeaderFileds)]) header = [service httpHeaderFileds];
    return header;
}

- (NSDictionary *)sna_take_cookies:(id<SnailPostManServiceProtocol>)service {
    NSDictionary *cookie = nil;
    if (self.cookie) cookie = self.cookie;
    else if ([service respondsToSelector:@selector(cookie)]) cookie = [service cookie];
    return cookie;
}

- (SnailPostManMethodType)sna_take_method_type:(id<SnailPostManServiceProtocol>)service {
    SnailPostManMethodType type = SnailPostManMethodTypeUnknown;
    if (self.methodType != SnailPostManMethodTypeUnknown) type = self.methodType;
    else if ([service respondsToSelector:@selector(methodType)]) {
        type = [service methodType];
    }
    if (type == SnailPostManMethodTypeUnknown) type = SnailPostManMethodTypePOST;
    return type;
}

- (SnailPostManCacheStrategy)sna_take_cache_strategy:(id<SnailPostManServiceProtocol>)service {
    SnailPostManCacheStrategy strategy = SnailPostManCacheStrategyNone;
    if (self.cachePolicy) {
        strategy = self.cachePolicy;
    }
    else if ([service respondsToSelector:@selector(cachePolicy)]) strategy = [service cachePolicy];
    return strategy;
}

- (NSURLRequestCachePolicy)sna_take_url_cache_strategy:(SnailPostManCacheStrategy)cacheStagery {
    
    NSURLRequestCachePolicy urlRequestCache = NSURLRequestUseProtocolCachePolicy;
    switch (cacheStagery) {
        case SnailPostManCacheStrategyProtocolCache: urlRequestCache = NSURLRequestUseProtocolCachePolicy;
            break;
        case SnailPostManCacheStrategyIgnoringLocalCacheData: urlRequestCache = NSURLRequestReloadIgnoringLocalCacheData;
            break;
        case SnailPostManCacheStrategyCacheDataElseLoad: urlRequestCache = NSURLRequestReturnCacheDataElseLoad;
            break;
        case SnailPostManCacheStrategyCacheDataDontLoad: urlRequestCache = NSURLRequestReturnCacheDataDontLoad;
            break;
        case SnailPostManCacheStrategyNone: urlRequestCache = NSURLRequestUseProtocolCachePolicy;
            break;
        default:
            urlRequestCache = NSURLRequestReloadIgnoringLocalCacheData;
            break;
    }
    return urlRequestCache;
    
}

- (SnailPostManRequestStrategy)sna_take_request_strategy:(id<SnailPostManServiceProtocol>)service {
    SnailPostManRequestStrategy strategy = SnailPostManRequestStrategyDefault;
    if (self.requestStrategy) strategy = self.requestStrategy;
    else if ([service respondsToSelector:@selector(requestStrategy)]) {
        strategy = [service requestStrategy];
    }
    return strategy;
}

- (id<SnailPostManCheckProtocol>)sna_take_checker:(NSDictionary *)dic Service:(id<SnailPostManServiceProtocol>)service {
    id<SnailPostManCheckProtocol> checker = nil;
    if (dic[SnailPostManCheckerKey]) checker = dic[SnailPostManCheckerKey];
    else if (self.checker) checker = self.checker;
    else if ([service respondsToSelector:@selector(checker)]) checker = [service checker];
    return checker;
}

- (id<SnailPostManScreenProtocol>)sna_take_screen:(NSDictionary *)dic {
    id<SnailPostManScreenProtocol> screen = nil;
    if (dic[SnailPostManScreenKey]) screen = dic[SnailPostManScreenKey];
    else if (self.screen) screen = self.screen;
    return screen;
}

- (BOOL)sna_take_log_info:(id<SnailPostManServiceProtocol>)service {
    BOOL log = self.logRequestInfo;
    if (log == false) {
        log = [service logRequestInfo];
    }
    return log;
}

- (NSURL *)sna_take_log_url:(id<SnailPostManServiceProtocol>)service {
    NSURL *url = self.logRequestInfoPath;
    if (!url) {
        url = [service logRequestInfoPath];
    }
    return url;
}

- (SnailPostManResponseInfo *)sna_create_response_info:(NSURLResponse *)response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = httpResponse.statusCode;
    NSDictionary *allHeaders = httpResponse.allHeaderFields;
    
    SnailPostManResponseInfo *info = [SnailPostManResponseInfo new];
    info.statusCode = statusCode;
    info.responseHeader = allHeaders;
    
    return info;
    
}

- (void)sna_log:(BOOL)log
         LogDic:(NSDictionary *)logDic
        LogPath:(NSURL *)logPath
{
#ifdef DEBUG
    if (log) {
        if (logPath) [logDic writeToURL:logPath error:nil];
        else {
            NSLog(@"%@",logDic);
        }
    }
#endif
}

- (void)sna_detail_success_response:(id)responseData
                            Service:(id<SnailPostManServiceProtocol>)service
                            Checker:(id<SnailPostManCheckProtocol>)checker
                             Screen:(id<SnailPostManScreenProtocol>)screen
                           Response:(id<SnailPostManResponseProtocol>)responseProtocol
                              Cache:(SnailPostManCacheStrategy)cacheStrategy
                                Url:(NSString *)url
                         MethodName:(NSString *)methodName
                               Info:(SnailPostManResponseInfo *)info
                         HttpHeader:(NSDictionary *)httpHeader
                             Cookie:(NSDictionary *)cookie
                          CacheTime:(NSTimeInterval)cacheTime
                             Params:(NSDictionary *)params
                         MethodType:(SnailPostManMethodType)methodType
                                Tag:(NSInteger)tag
                            Context:(id)context
                                Log:(BOOL)log
                             LogDic:(NSMutableDictionary *)logdic
                            LogPath:(NSURL *)logPath
{
    
    [service handleResponse:responseData Success:^(id response) {
        [self sna_checke_response:response
                          Checker:checker
                           Screen:screen
                         Response:responseProtocol
                            Cache:cacheStrategy
                              Url:url
                       MethodName:methodName
                             Info:info
                       HttpHeader:httpHeader
                           Cookie:cookie
                        CacheTime:cacheTime
                           Params:params
                       MethodType:methodType
                              Tag:tag
                          Context:context
                              Log:log
                           LogDic:logdic
                          LogPath:logPath];
    } Falied:^(NSError *error) {
        [responseProtocol SnailPostManResponseFalied:error Info:info Class:self.class Tag:tag Context:context];
        logdic[SNAIL_POST_MAN_LOG_ERROR] = error.localizedDescription;
        [self sna_log:log LogDic:logdic LogPath:logPath];
    }];
    
}

- (void)sna_checke_response:(id)responseData
                    Checker:(id<SnailPostManCheckProtocol>)checker
                     Screen:(id<SnailPostManScreenProtocol>)screen
                   Response:(id<SnailPostManResponseProtocol>)responseProtocol
                      Cache:(SnailPostManCacheStrategy)cacheStrategy
                        Url:(NSString *)url
                 MethodName:(NSString *)methodName
                       Info:(SnailPostManResponseInfo *)info
                 HttpHeader:(NSDictionary *)httpHeader
                     Cookie:(NSDictionary *)cookie
                  CacheTime:(NSTimeInterval)cacheTime
                     Params:(NSDictionary *)params
                 MethodType:(SnailPostManMethodType)methodType
                        Tag:(NSInteger)tag
                    Context:(id)context
                        Log:(BOOL)log
                     LogDic:(NSMutableDictionary *)logdic
                    LogPath:(NSURL *)logPath
{
    if (checker) {
        if (![checker checkResponse:responseData Cls:self.class MethodName:methodName MethodType:methodType Tag:tag Context:context]) {
            NSError *error = [NSError errorWithDomain:SnailPostManErrorDomain code:-101 userInfo:@{NSLocalizedDescriptionKey:@"response error"}];
            [responseProtocol SnailPostManResponseFalied:error Info:info Class:self.class Tag:tag Context:context];
            logdic[SNAIL_POST_MAN_LOG_ERROR] = error.localizedDescription;
            [self sna_log:log LogDic:logdic LogPath:logPath];
            return;
        }
    }
    
    BOOL shouldCache = false;
    switch (cacheStrategy) {
        case SnailPostManCacheStrategyMemoryCache:
        case SnailPostManCacheStrategyArchive:
            shouldCache = true;
            break;
        default:
            break;
    }
    if (shouldCache) {
        [SnailPostManCacheController saveCacheType:cacheStrategy Path:url Header:httpHeader Cookies:cookie Params:params MethodType:_sna_take_request_method_type_name(methodType) Tag:tag Context:context Response:responseData Time:cacheTime];
    }
    [self sna_screen_response:responseData
                       Screen:screen
                     Response:responseProtocol
                        Url:url
                   MethodName:methodName
                         Info:info
                   HttpHeader:httpHeader
                       Cookie:cookie
                    CacheTime:cacheTime
                       Params:params
                   MethodType:methodType
                          Tag:tag
                      Context:context
                          Log:log
                       LogDic:logdic
                      LogPath:logPath];
}

- (void)sna_screen_response:(id)responseData
                     Screen:(id<SnailPostManScreenProtocol>)screen
                   Response:(id<SnailPostManResponseProtocol>)responseProtocol
                        Url:(NSString *)url
                 MethodName:(NSString *)methodName
                       Info:(SnailPostManResponseInfo *)info
                 HttpHeader:(NSDictionary *)httpHeader
                     Cookie:(NSDictionary *)cookie
                  CacheTime:(NSTimeInterval)cacheTime
                     Params:(NSDictionary *)params
                 MethodType:(SnailPostManMethodType)methodType
                        Tag:(NSInteger)tag
                    Context:(id)context
                        Log:(BOOL)log
                     LogDic:(NSMutableDictionary *)logdic
                    LogPath:(NSURL *)logPath
{
    logdic[SNAIL_POST_MAN_LOG_RESPONSE] = responseData;
    [self sna_log:log LogDic:logdic LogPath:logPath];
    if (screen) {
        responseData = [screen analysisRequestResponse:responseData MethodName:methodName Class:self.class Tag:tag Context:context];
    }
    [responseProtocol SnailPostManResponseSuccess:responseData Info:info Class:self.class Tag:tag Context:context];
}

- (void)cancle {
    [self.task cancel];
}

- (void)pause {
    [self.task suspend];
}

- (void)resume {
    [self.task resume];
}

@end
