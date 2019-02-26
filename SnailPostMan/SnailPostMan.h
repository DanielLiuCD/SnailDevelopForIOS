//
//  SnailPostMan.h
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/12/11.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnailPostManServiceController.h"


@interface SnailPostMan : NSObject

@property (nonatomic ,copy) NSString *methodName;
@property (nonatomic ,copy) NSString *pathParam;
@property (nonatomic ,copy) NSString *serviceIdentifer;

@property (nonatomic ,copy) NSDictionary *cookie;
@property (nonatomic ,copy) NSDictionary *headerFileds;

@property (nonatomic) NSTimeInterval overTime;
@property (nonatomic) NSTimeInterval snailMaxCacheTime; //自定义缓存时长,只对内置的自定义缓存有效

@property (nonatomic) SnailPostManMethodType methodType;
@property (nonatomic) SnailPostManCacheStrategy cachePolicy;
@property (nonatomic) SnailPostManRequestStrategy requestStrategy;
@property (nonatomic) SnailPostManRequestIdentiferStrategy requestIdentiferStrategy;

@property (nonatomic ,strong) id<SnailPostManScreenProtocol> screen;
@property (nonatomic ,strong) id<SnailPostManServiceProtocol> service;
@property (nonatomic ,strong) id<SnailPostManCheckProtocol> checker;

@property (nonatomic) BOOL logRequestInfo;
@property (nonatomic ,copy) NSURL *logRequestInfoPath;

@property (nonatomic ,readonly) BOOL isSending;

- (void)sendResponse:(id<SnailPostManResponseProtocol>)response Params:(NSDictionary *)params Tag:(NSInteger)tag Context:(id)context;

- (void)resume;
- (void)pause;
- (void)cancle;

@end
