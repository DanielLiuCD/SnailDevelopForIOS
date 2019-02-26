//
//  SnailPostManServiceController.h
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/12/11.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnailPostManObjc.h"

@protocol SnailPostManServiceControllerDelegate<NSObject>

@required
- (id<SnailPostManServiceProtocol>)SnailPostManServiceController_TakeService:(NSString *)identifer;

@end

@interface SnailPostManServiceController : NSObject

@property (nonatomic, weak) id<SnailPostManServiceControllerDelegate> delegate;

+ (instancetype)sharedInstance;

- (id<SnailPostManServiceProtocol>)takeServiceWithIdentifer:(NSString *)identifer;

- (NSString *)takeUrlPath:(NSString *)serviceIdentifer MethodName:(NSString *)methodName Tag:(NSInteger)tag Context:(id)context;

- (void)clearServices;

@end
