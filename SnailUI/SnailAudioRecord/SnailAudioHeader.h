//
//  SnailAudioRecordHUD.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/10.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger ,SnailAudioRecordLevel) {
    SnailAudioRecordLevel_0,
    SnailAudioRecordLevel_1,
    SnailAudioRecordLevel_2,
    SnailAudioRecordLevel_3,
    SnailAudioRecordLevel_4,
    SnailAudioRecordLevel_5,
    SnailAudioRecordLevel_6,
    SnailAudioRecordLevel_7,
    SnailAudioRecordLevel_8,
    SnailAudioRecordLevel_9,
    SnailAudioRecordLevel_10,
};

typedef NS_ENUM(NSInteger ,SnailAudioRecordErrorType) {
    SnailAudioRecordErrorTimeTooSmall,
    SnailAudioRecordErrorSavePathError,
    SnailAudioRecordErrorUnknown,
};
