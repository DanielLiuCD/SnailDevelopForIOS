//
//  SnailAliOSS.h
//  QianXun
//
//  Created by JobNewMac1 on 2018/11/16.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SNAIL_ALI_OSS_ERROR_DOMIN @"SNAIL_ALI_OSS_ERROR_DOMIN"

@interface SnailAliOSSFile : NSObject

@property (nonatomic ,strong) NSURL *path;
@property (nonatomic ,strong) NSData *data;
@property (nonatomic ,strong) NSString *name;

@property (nonatomic ,strong) id extendInfo;  //用于存放附加信息,会原样返回在result中

@property (nonatomic) int64_t expirationTimeInMilliSecond; //过期时间 >0 会返回签名了访问时间的链接
@property (nonatomic ,strong) NSString *bucketName;
@property (nonatomic ,strong) NSString *contentType;
@property (nonatomic ,strong) NSString *contentMd5;
@property (nonatomic ,strong) NSString *contentEncoding;
@property (nonatomic ,strong) NSString *contentDisposition;
@property (nonatomic ,strong) NSDictionary *objectMeta;

@property (nonatomic ,strong) NSArray<SnailAliOSSFile *> *subfiles;

@end

@interface SnailAliOSSResult : NSObject

@property (nonatomic ,strong) NSString *url;
@property (nonatomic ,strong) NSString *contentMd5;

@property (nonatomic ,strong) id extendInfo; //用于存放附加信息 , 由file传入

@property (nonatomic ,strong) NSArray<SnailAliOSSResult *> *results;

@end

@interface SnailAliOSSTokenProvider : NSObject

@property (nonatomic ,copy) NSString *accessKeyId;
@property (nonatomic ,copy) NSString *accessKeySecret;
@property (nonatomic ,copy) NSString *securityToken;
@property (nonatomic ,copy) NSString *expirationTimeInGMTFormat;
@property (nonatomic) int64_t expirationTimeInMilliSecond; //token 过期时间

@end

@interface SnailAliOSSExtendInfo : NSObject

@property (nonatomic ,strong) NSString *bucketName;
@property (nonatomic ,strong) NSString *endPoint;

@end

@interface SnailAliOSSToken : NSObject

- (BOOL)running;
- (void)cancle;
- (void)clear;
- (void)upload;

@end

@interface SnailAliOSS : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic ,strong) SnailAliOSSExtendInfo *extendInfo;

@property (nonatomic ,copy) SnailAliOSSTokenProvider *(^takeAliOSSTokenProvider)(NSString *endpoint);
@property (nonatomic ,copy) SnailAliOSSExtendInfo *(^takeAliOSSExtendInfo)(void);

+ (SnailAliOSSToken *)EndPoint:(NSString *)endPoint Token:(SnailAliOSSFile *(^)(void))fileBlock Progress:(void(^)(CGFloat value))progressBlock Success:(void(^)(SnailAliOSSResult *result))successBlock Falied:(void(^)(NSError *error))faliedBlock;

+ (SnailAliOSSToken *)Token:(SnailAliOSSFile *(^)(void))fileBlock Progress:(void(^)(CGFloat value))progressBlock Success:(void(^)(SnailAliOSSResult *result))successBlock Falied:(void(^)(NSError *error))faliedBlock;

@end
