//
//  SnailAudioRecord.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/9.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

@interface SnailAudioRecorder()

kSPrStrong(AVAudioRecorder *recorder)
kSPrStrong(NSTimer *timer)
kSPr(NSTimeInterval maxTime)
kSPrStrong(NSURL *urlPath)

@end

@implementation SnailAudioRecorder

- (void)startRecord {
    
    NSString *fileName = [NSString stringWithFormat:@"voice-i-%f.caf",[[NSDate date] timeIntervalSince1970]];
    NSString *folderPath;
    if (self.savePathBlock) {
        folderPath = self.savePathBlock();
    }
    if (folderPath == nil) {
        if (self.faliedBlock) self.faliedBlock(SnailAudioRecordErrorSavePathError);
        return;
    }
    
    NSString *saveFilePath ;
    if ([folderPath hasSuffix:@"/"]) saveFilePath = [folderPath stringByAppendingString:fileName];
    else saveFilePath = [folderPath stringByAppendingPathComponent:fileName];
    
    NSTimeInterval tim = 0.0;
    if (self.maxTimeBlock) tim = self.maxTimeBlock();
    if (tim < 3) {
        if (self.faliedBlock) self.faliedBlock(SnailAudioRecordErrorTimeTooSmall);
        return;
    }
    
    NSError *err = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err) {
        if (self.faliedBlock) self.faliedBlock(SnailAudioRecordErrorUnknown);
        return;
    }
    
//    if (![audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&err]) {
//        if (self.faliedBlock) self.faliedBlock(SnailAudioRecordErrorUnknown);
//        return;
//    }
    
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
    
    [audioSession setActive:YES error:&err];
    if(err) {
        if (self.faliedBlock) self.faliedBlock(SnailAudioRecordErrorUnknown);
        return;
    }
    
    NSMutableDictionary *recordSetting =[NSMutableDictionary dictionaryWithCapacity:10];
    [recordSetting setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //2 采样率
    [recordSetting setObject:[NSNumber numberWithFloat:8000.0] forKey: AVSampleRateKey];
    //3 通道的数目
    [recordSetting setObject:[NSNumber numberWithInt:1]forKey:AVNumberOfChannelsKey];
    //4 采样位数  默认 16
    [recordSetting setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:saveFilePath] settings:recordSetting error:&err];
    if(err) {
        if (self.faliedBlock) self.faliedBlock(SnailAudioRecordErrorUnknown);
        return;
    }
    
    [self.recorder prepareToRecord];
    
    self.recorder.meteringEnabled = true;
    [self stopTimer];
    
    self.maxTime = tim;
    self.urlPath = [NSURL fileURLWithPath:saveFilePath];
    
    if (self.willRecordBlock) self.willRecordBlock();
    
    [self.recorder record];
    
    self.timer = [NSTimer timerWithTimeInterval:0.0001 target:self selector:@selector(timerAction) userInfo:nil repeats:true];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}

- (void)timerAction {
    
    
    NSTimeInterval currentTime = self.recorder.currentTime;
    if (self.recordTimeBlock) {
        self.recordTimeBlock(self.maxTime, currentTime);
    }
    if (self.recorder && self.powerLevelBlock) {
        
        [self.recorder updateMeters];
        double ff = [self.recorder averagePowerForChannel:0];
        ff = ff + 60;
        if (ff <= 0) self.powerLevelBlock(SnailAudioRecordLevel_0);
        else if (ff > 0 && ff < 10) self.powerLevelBlock(SnailAudioRecordLevel_1);
        else if (ff >= 10 && ff < 20) self.powerLevelBlock(SnailAudioRecordLevel_2);
        else if (ff >= 20 && ff < 30) self.powerLevelBlock(SnailAudioRecordLevel_3);
        else if (ff >= 30 && ff < 40) self.powerLevelBlock(SnailAudioRecordLevel_4);
        else if (ff >= 40 && ff < 50) self.powerLevelBlock(SnailAudioRecordLevel_5);
        else if (ff >= 50 && ff < 60) self.powerLevelBlock(SnailAudioRecordLevel_6);
        else if (ff >= 60 && ff < 70) self.powerLevelBlock(SnailAudioRecordLevel_7);
        else if (ff >= 70 && ff < 80) self.powerLevelBlock(SnailAudioRecordLevel_8);
        else if (ff >= 80 && ff < 90) self.powerLevelBlock(SnailAudioRecordLevel_9);
        else self.powerLevelBlock(SnailAudioRecordLevel_10);
        
    }
    
    if (currentTime >= self.maxTime) {
        [self stopRecord];
    }
    
}

- (void)stopRecord {
    
    [self stopTimer];
    
    NSTimeInterval time = self.recorder.currentTime;
    [self.recorder stop];
    
    NSTimeInterval miniTime = 3;
    if (self.miniTimeBlock) {
        miniTime = self.miniTimeBlock();
        if (miniTime < 3) miniTime = 3;
    }
    if (time < miniTime && self.faliedBlock) {
        [self.recorder deleteRecording];
        self.faliedBlock(SnailAudioRecordErrorTimeTooSmall);
    }
    else if (self.successBlock) self.successBlock(self.urlPath, time);

    self.recorder = nil;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    //恢复外部正在播放的音乐
    NSError *err;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&err];
    
}

- (void)cancleRecord {
    
    [self stopTimer];
    
    [self.recorder stop];
    [self.recorder deleteRecording];
    self.recorder = nil;
    
    if (self.cancleRecordBlock) self.cancleRecordBlock();
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];
    NSError *err;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&err];
    
}

- (void)clear {
    if (self.clearBlock) {
        self.clearBlock();
    }
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
