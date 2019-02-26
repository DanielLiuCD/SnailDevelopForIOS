//
//  SnailAudioRecord.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/9.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnailAudioHeader.h"


@interface SnailAudioRecorder : NSObject

kSPrStrong(void(^powerLevelBlock)(SnailAudioRecordLevel level))

kSPrStrong(NSTimeInterval(^miniTimeBlock)(void))

kSPrStrong(NSTimeInterval(^maxTimeBlock)(void))  //时间不能小于3秒

kSPrStrong(NSString *(^savePathBlock)(void))

kSPrStrong(void(^willRecordBlock)(void))

kSPrStrong(void(^clearBlock)(void))

kSPrStrong(void(^recordTimeBlock)(NSTimeInterval maxTime ,NSTimeInterval currentTime))

kSPrStrong(void(^successBlock)(NSURL *path,NSTimeInterval totalTime))

kSPrStrong(void(^faliedBlock)(SnailAudioRecordErrorType type))

kSPrStrong(void(^cancleRecordBlock)(void))

- (void)startRecord;

- (void)stopRecord;

- (void)cancleRecord;

- (void)clear;

@end
