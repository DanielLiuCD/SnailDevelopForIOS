//
//  SnailPostManCacheController.h
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/12/11.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnailPostManObjc.h"

@interface SnailPostManCacheController : NSObject

+ (BOOL)saveCacheType:(SnailPostManCacheStrategy)cacheStrategy
                 Path:(NSString *)path
               Header:(NSDictionary *)header
              Cookies:(NSDictionary *)cookies
               Params:(NSDictionary *)params
           MethodType:(NSString *)methodType
                  Tag:(NSInteger)tag
              Context:(id)context
             Response:(id)response
                 Time:(NSTimeInterval)tim;

+ (BOOL)haveCacheType:(SnailPostManCacheStrategy)cacheStrategy
                 Path:(NSString *)path
               Header:(NSDictionary *)header
              Cookies:(NSDictionary *)cookies
               Params:(NSDictionary *)params
           MethodType:(NSString *)methodType
                  Tag:(NSInteger)tag
              Context:(id)context;

+ (id)takeCacheType:(SnailPostManCacheStrategy)cacheStrategy
               Path:(NSString *)path
             Header:(NSDictionary *)header
            Cookies:(NSDictionary *)cookies
             Params:(NSDictionary *)params
         MethodType:(NSString *)methodType
                Tag:(NSInteger)tag
            Context:(id)context;

+ (BOOL)removeCacheType:(SnailPostManCacheStrategy)cacheStrategy
                   Path:(NSString *)path
                 Header:(NSDictionary *)header
                Cookies:(NSDictionary *)cookies
                 Params:(NSDictionary *)params
             MethodType:(NSString *)methodType
                    Tag:(NSInteger)tag
                Context:(id)context;

@end
