//
//  SnailPostManTaskManager.h
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/6/12.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnailPostManTaskManager : NSObject

+ (void)saveTask:(NSURLSessionTask *)task Identifer:(NSString *)identifer;

+ (void)removeTaskWithIdentifer:(NSString *)identifer;

+ (NSURLSessionTask *)takeTaskWithIdentifer:(NSString *)identifer;

@end
