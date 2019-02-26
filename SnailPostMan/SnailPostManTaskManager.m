//
//  SnailPostManTaskManager.m
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/6/12.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailPostManTaskManager.h"

@interface SnailPostManTaskManager()

@property (nonatomic ,strong) dispatch_semaphore_t sem;
@property (nonatomic ,strong) NSMutableDictionary *tasks;

@end

@implementation SnailPostManTaskManager

+ (instancetype)sharedInstance {
    
    static SnailPostManTaskManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [SnailPostManTaskManager new];
        manager.sem = dispatch_semaphore_create(1);
    });
    return manager;

}

+ (void)saveTask:(NSURLSessionTask *)task Identifer:(NSString *)identifer {
    
    SnailPostManTaskManager *manager = [self sharedInstance];
    dispatch_semaphore_wait(manager.sem, DISPATCH_TIME_FOREVER);
    manager.tasks[identifer] = task;
    dispatch_semaphore_signal(manager.sem);
    
}

+ (void)removeTaskWithIdentifer:(NSString *)identifer {
    
    SnailPostManTaskManager *manager = [self sharedInstance];
    dispatch_semaphore_wait(manager.sem, DISPATCH_TIME_FOREVER);
    [manager.tasks removeObjectForKey:identifer];
    dispatch_semaphore_signal(manager.sem);
    
}

+ (NSURLSessionTask *)takeTaskWithIdentifer:(NSString *)identifer {
    
    SnailPostManTaskManager *manager = [self sharedInstance];
    dispatch_semaphore_wait(manager.sem, DISPATCH_TIME_FOREVER);
    NSURLSessionTask *task = manager.tasks[identifer];
    dispatch_semaphore_signal(manager.sem);
    return task;
    
}

- (NSMutableDictionary *)tasks {
    if (!_tasks) {
        _tasks = [NSMutableDictionary new];
    }
    return _tasks;
}

@end
