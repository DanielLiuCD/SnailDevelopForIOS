//
//  SnailUncaughtException.h
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2019/1/7.
//  Copyright © 2019年 com.jonnew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnailUncaughtException : NSObject

+ (void)SET_UncaughtException:(NSString *(^)(void))block;
+ (NSArray<NSURL *> *)TAKE_ALL_Exception;
+ (void)clear:(NSString *)name;
+ (void)clear;

@end
