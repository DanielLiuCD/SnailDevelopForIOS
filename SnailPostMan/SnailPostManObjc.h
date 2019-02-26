//
//  SnailPostManTemp.h
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/12/11.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SnailPostManResponseInfo;

typedef NSString * SnailPostManKey NS_STRING_ENUM;

FOUNDATION_EXPORT NSString * const SnailPostManDefaultServiceIdentifer;

FOUNDATION_EXPORT SnailPostManKey const SnailPostManUploadFileKey;
FOUNDATION_EXPORT SnailPostManKey const SnailPostManScreenKey;
FOUNDATION_EXPORT SnailPostManKey const SnailPostManCheckerKey;
FOUNDATION_EXPORT SnailPostManKey const SnailPostManServiceKey;
FOUNDATION_EXPORT SnailPostManKey const SnailPostManMethodNameKey;
FOUNDATION_EXPORT SnailPostManKey const SnailPostManPathParamKey;
FOUNDATION_EXPORT SnailPostManKey const SnailPostManHttpsCerKey;

FOUNDATION_EXPORT NSErrorDomain const SnailPostManErrorDomain;

typedef NS_ENUM(NSInteger ,SnailPostManMethodType) {
    SnailPostManMethodTypeUnknown,
    ///GET
    SnailPostManMethodTypeGET,
    ///POST
    SnailPostManMethodTypePOST,
    ///JSON
    SnailPostManMethodTypePOST_JSON,
    ///PUT
    SnailPostManMethodTypePUT,
    ///DELETE
    SnailPostManMethodTypeDELETE,
};

typedef NS_ENUM(NSInteger ,SnailPostManRequestStrategy) {
    SnailPostManRequestStrategyDefault,
    ///如果同一接口还有请求没完成,取消之前的
    SnailPostManRequestStrategyCancleLast,
    ///如果同一接口还有请求没完成,取消现在的
    SnailPostManRequestStrategyCancleCurrent,
};

typedef NS_ENUM(NSInteger ,SnailPostManRequestIdentiferStrategy) {
    SnailPostManRequestIdentiferStrategyDefault, //使用路径和参数
    SnailPostManRequestIdentiferStrategyMethod, //使用路径
};

typedef NS_ENUM(NSInteger ,SnailPostManCacheStrategy) {
    SnailPostManCacheStrategyNone,
    ///按照网络协议标准中实现的缓存策略
    SnailPostManCacheStrategyProtocolCache,
    ///不使用缓存
    SnailPostManCacheStrategyIgnoringLocalCacheData,
    ///无论缓存是否过期，有缓存则使用缓存，否则重新请求原始数据
    SnailPostManCacheStrategyCacheDataElseLoad,
    ///无论缓存是否过期，有缓存则使用缓存，否则视为失败，不会重新请求原始数据
    SnailPostManCacheStrategyCacheDataDontLoad,
    ///NSCache实现内存缓存
    SnailPostManCacheStrategyMemoryCache,
    ///序列化实现磁盘缓存
    SnailPostManCacheStrategyArchive,
    ///自定义缓存方式  尚未实现
    SnailPostManCacheStrategyCustome,
};


@protocol SnailPostManCheckProtocol <NSObject>

@required
- (BOOL)checkParams:(NSDictionary *)params Cls:(Class)cls MethodName:(NSString *)methodName MethodType:(SnailPostManMethodType)methodType Tag:(NSInteger)tag Context:(id)context;
- (BOOL)checkResponse:(id)response Cls:(Class)cls MethodName:(NSString *)methodName MethodType:(SnailPostManMethodType)methodType Tag:(NSInteger)tag Context:(id)context;

@end

@protocol SnailPostManInfoProtocol <NSObject>

@optional
///超时时间 默认 30秒
- (NSTimeInterval)overtime;
///cookies
- (NSDictionary *)cookie;
///请求头
- (NSDictionary *)httpHeaderFileds;
///使用自定义的缓存的缓存的存储时间 默认时长 3秒  只对内置的自定义缓存有效
- (NSTimeInterval)snailMaxCacheTime;

@end

@protocol SnailPostManScreenProtocol <NSObject>

@required
- (id)analysisRequestResponse:(id)urlResponse MethodName:(NSString *)methodName Class:(Class)cls Tag:(NSInteger)tag Context:(id)context;

@end

@protocol SnailPostManServiceProtocol <NSObject,SnailPostManInfoProtocol>

@required
///服务器说明
- (NSString *)explain;
///参数处理
- (NSDictionary *)handleParams:(NSDictionary *)params Tag:(NSInteger)tag Context:(id)context;
///拼接服务器路径
- (NSString *)composeUrl:(NSString *)methodName Tag:(NSInteger)tag Context:(id)context;
///处理响应
- (void)handleResponse:(id)response Success:(void(^)(id response))successBlock Falied:(void(^)(NSError *error))faliedBlock;
///是否打印请求信息 default false
- (BOOL)logRequestInfo;
///打印请求信息的路径
- (NSURL *)logRequestInfoPath;

@optional
///默认 SnailPostManMethodTypePOST
- (SnailPostManMethodType)methodType;
///缓存策略 默认 SnailPostManCacheStrategyNone
- (SnailPostManCacheStrategy)cachePolicy;
///请求策略 默认 SnailPostManCacheStrategyNone
- (SnailPostManRequestStrategy)requestStrategy;
///校验器
- (id<SnailPostManCheckProtocol>)checker;

@end

@protocol SnailPostManResponseProtocol<NSObject>

@required
- (void)SnailPostManResponseSuccess:(id)response Info:(SnailPostManResponseInfo *)responseInfo Class:(Class)cls Tag:(NSInteger)tag Context:(id)context;

- (void)SnailPostManResponseFalied:(NSError *)error Info:(SnailPostManResponseInfo *)responseInfo Class:(Class)cls Tag:(NSInteger)tag Context:(id)context;

@optional
- (void)SnailPostManResponseDownloadProgress:(NSProgress *)progress Class:(Class)cls Tag:(NSInteger)tag Context:(id)context;
- (void)SnailPostManResponseUploadProgress:(NSProgress *)progress Class:(Class)cls Tag:(NSInteger)tag Context:(id)context;


@end

@protocol SnailPostManCacheProtocol <NSObject>

@required
///保存缓存
+ (BOOL)saveCacheWithPath:(NSString *)path
                   Header:(NSDictionary *)header
                  Cookies:(NSDictionary *)cookies
                   Params:(NSDictionary *)params
               MethodType:(NSString *)methodTypeName
                      Tag:(NSInteger)tag
                  Context:(id)context
                     Time:(NSTimeInterval)tim
                 Response:(id)response;

///判断是否有缓存
+ (BOOL)haveCacheWithPath:(NSString *)path
                   Header:(NSDictionary *)header
                  Cookies:(NSDictionary *)cookies
                   Params:(NSDictionary *)params
               MethodType:(NSString *)methodTypeName
                      Tag:(NSInteger)tag
                  Context:(id)context;

///取出缓存
+ (id)takeCacheWithPath:(NSString *)path
                 Header:(NSDictionary *)header
                Cookies:(NSDictionary *)cookies
                 Params:(NSDictionary *)params
             MethodType:(NSString *)methodTypeName
                    Tag:(NSInteger)tag
                Context:(id)context;

///清除缓存
+ (BOOL)removeCacheWithPath:(NSString *)path
                     Header:(NSDictionary *)header
                    Cookies:(NSDictionary *)cookies
                     Params:(NSDictionary *)params
                 MethodType:(NSString *)methodTypeName
                        Tag:(NSInteger)tag
                    Context:(id)context;

@end

@interface SnailPostManFile : NSObject

@property (nonatomic ,copy) NSString *name;
@property (nonatomic ,copy) NSData *data;
@property (nonatomic ,copy) NSURL *url;
@property (nonatomic ,copy) NSString *key;

@end

@interface SnailPostManResponseInfo : NSObject

@property (nonatomic) NSInteger statusCode;
@property (nonatomic ,copy) NSDictionary *responseHeader;

@end

