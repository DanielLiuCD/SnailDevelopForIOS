//
//  SnailPostManServiceController.m
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/12/11.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailPostManServiceController.h"
#import "SnailPostManObjc.h"

@interface SnailPostManServiceController()

@property (nonatomic ,strong) NSMutableDictionary *cache;

@end

@implementation SnailPostManServiceController

+ (instancetype)sharedInstance {
    static SnailPostManServiceController *ojc = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ojc = SnailPostManServiceController.new;
        ojc.cache = [NSMutableDictionary new];
    });
    return ojc;
}

- (id<SnailPostManServiceProtocol>)takeServiceWithIdentifer:(NSString *)identifer {
    id<SnailPostManServiceProtocol> ser = self.cache[identifer];
    if (ser == nil) {
        ser = [self.delegate SnailPostManServiceController_TakeService:identifer];
        if (ser && identifer) self.cache[identifer] = ser;
    }
    return ser;
}

- (NSString *)takeUrlPath:(NSString *)serviceIdentifer MethodName:(NSString *)methodName Tag:(NSInteger)tag Context:(id)context {
    id<SnailPostManServiceProtocol> ser = [self takeServiceWithIdentifer:serviceIdentifer];
    return [ser composeUrl:methodName Tag:tag Context:context];
}

- (void)clearServices {
    [self.cache removeAllObjects];
}

@end
