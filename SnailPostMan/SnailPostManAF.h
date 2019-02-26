//
//  SnailPostManAF.h
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/12/14.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface SnailPostManAF : NSObject

+ (void)HttpsCer:(NSData *)data;

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
                        Falied:(void (^)(NSURLResponse * _Nonnull response,NSError *error))falied;

@end
