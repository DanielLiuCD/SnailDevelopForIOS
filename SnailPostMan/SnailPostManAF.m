//
//  SnailPostManAF.m
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/12/14.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailPostManAF.h"
#import "SnailPostManCategory.h"
#import "SnailPostManObjc.h"

static AFHTTPSessionManager *_snail_af_manger() {
    
    static AFHTTPSessionManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [AFHTTPSessionManager manager];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return _manager;
    
}

@implementation SnailPostManAF

+ (void)HttpsCer:(NSData *)data {
    AFHTTPSessionManager *manager = _snail_af_manger();
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[[NSSet alloc] initWithObjects:data, nil]];
    manager.securityPolicy.allowInvalidCertificates = YES;
    [manager.securityPolicy setValidatesDomainName:NO];
}

+ (NSURLSessionTask *)URL:(NSString *)path
           MethodTypeName:(NSString *)methodTypeName
                    Cache:(NSURLRequestCachePolicy)policy
                 OverTime:(NSTimeInterval)overtime
                   Params:(NSDictionary *)params
                     File:(id)file
           RequestHeaders:(NSDictionary *)requestHeader
                  Cookies:(NSDictionary *)cookie
         DownloadProgress:(void (^)(NSProgress *pgre))progress
           UploadProgress:(void (^)(NSProgress *pgre))uploadprogress
                  Success:(void (^)(NSURLResponse * _Nonnull response,id ressponseData))success
                   Falied:(void (^)(NSURLResponse * _Nonnull response,NSError *error))falied
{
    NSString *params_str = nil;
    if ([methodTypeName isEqualToString:@"POST_JSON"]) {
        methodTypeName = @"POST";
        params_str = [[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding] SnailPostManFilterJsonSpace];
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:requestHeader];
        if (!tmp[@"Content-Type"]) tmp[@"Content-Type"] = @"application/json";
        requestHeader = tmp.copy;
    }
    else params_str = [params SnailPostManHttpParmaString];
    
    BOOL isUpload = false;
    if (file) {
        if ([file isKindOfClass:[NSArray class]]) isUpload = [file count] > 0;
        else if ([file isKindOfClass:[SnailPostManFile class]]) isUpload = true;
    }
    if (isUpload) {
        methodTypeName = @"POST";
    }
    
    NSString *url = nil;
    if ([methodTypeName isEqualToString:@"GET"]) {
        if ([path hasSuffix:@"?"]) path = [path substringToIndex:path.length - 1];
        url = [NSString stringWithFormat:@"%@?%@",path,params_str];
    }
    else url = path;
    
    NSMutableURLRequest *request = nil;
    if (isUpload) {
        request = [_snail_af_manger().requestSerializer multipartFormRequestWithMethod:methodTypeName URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [self sna_detail_formData:formData File:file];
        } error:nil];
    }
    else {
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:policy timeoutInterval:overtime];
        request.HTTPMethod = methodTypeName;
        if (![methodTypeName isEqualToString:@"GET"]) {
            request.HTTPBody = [params_str dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    
    if (cookie.count > 0) [request setValue:[cookie SnailPostManHttpParmaString] forHTTPHeaderField:@"Cookie"];
    
    if (requestHeader) {
        for (NSString *key in requestHeader) {
            if (requestHeader[key]) [request setValue:requestHeader[key] forHTTPHeaderField:key];
        }
    }
    
    void(^downloadProgressBlock)(NSProgress * _Nonnull uploadProgress) = ^(NSProgress * _Nonnull tmpprogress){
        progress(tmpprogress);
    };
    void(^uploadProgressBlock)(NSProgress * _Nonnull uploadProgress) = ^(NSProgress * _Nonnull tmpprogress){
        uploadprogress(tmpprogress);
    };
    
    void (^completeBlock)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error) = ^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) falied(response,error);
        else success(response,responseObject);
    };
    
    NSURLSessionTask *task = nil;
    if (isUpload) {
        task = [_snail_af_manger() uploadTaskWithStreamedRequest:request progress:uploadProgressBlock completionHandler:completeBlock];
    }
    else {
       task = [_snail_af_manger() dataTaskWithRequest:request uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:completeBlock];
    }
    [task resume];
    return task;
    
}

+ (void)sna_detail_formData:(id<AFMultipartFormData> _Nonnull)formData File:(id)file {
    if ([file isKindOfClass:[SnailPostManFile class]]) {
        SnailPostManFile *tmpFile = (SnailPostManFile *)file;
        NSString *fileName = tmpFile.name;
        NSString *key = tmpFile.key;
        if (tmpFile.data) {
            [formData appendPartWithFileData:tmpFile.data name:fileName fileName:key mimeType:@"application/octet-stream"];
        }
        else if (tmpFile.url) {
            [formData appendPartWithFileURL:tmpFile.url name:fileName fileName:key mimeType:@"application/octet-stream" error:nil];
        }
    }
    else if ([file isKindOfClass:[NSArray class]]) {
        NSArray *tmps = (NSArray *)file;
        for (id tmpFile in tmps) {
            @autoreleasepool {
                [self sna_detail_formData:formData File:tmpFile];
            }
        }
    }
}

@end
