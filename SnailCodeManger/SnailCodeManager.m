//
//  SnailCodeManager.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailCodeManager.h"

@interface SnailCodeManager()

@property (nonatomic ,strong) NSTimer *timer;
@property (nonatomic ,copy) NSString *identifer;

@end

@implementation SnailCodeManager

- (void)loadWithIdentifer:(NSString *)identifer {
    
    [self stop];
    self.identifer = identifer;
    
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:self.identifer];
    if (dic) {
        self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:true];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer fire];
    }
    else self.identifer = nil;
    
    
}

- (void)recordWithIdentifer:(NSString *)identifer MaxValue:(NSInteger)value OtherInfo:(NSDictionary *)otherInfo {
    
    [[NSUserDefaults standardUserDefaults] setObject:@{@"date":[NSDate date],@"Max":@(value),@"other":otherInfo?:@{}} forKey:identifer];
    [self loadWithIdentifer:identifer];
    
}

- (void)timerAction {
    
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:self.identifer];
    if (dic) {
        NSDictionary *otherInfo = dic[@"other"];
        NSDate *last = dic[@"date"];
        NSDate *date = [NSDate date];
        NSInteger max = [dic[@"Max"] integerValue];
        NSTimeInterval tim = [date timeIntervalSinceDate:last];
        
        if (tim > max) {
            [self stop];
            self.identifer = nil;
        }
        else {
            if (self.block) self.block(max - tim,otherInfo);
        }
    }
    else {
        [self stop];
        self.identifer = nil;
    }
    
}

- (void)stop {
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.block) self.block(0,nil);
    if (self.identifer) [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.identifer];
 
}

@end
