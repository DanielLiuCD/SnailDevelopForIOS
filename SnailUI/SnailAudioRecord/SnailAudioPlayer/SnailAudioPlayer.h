//
//  SnailAudioPlayer.h
//  SnailChatUI
//
//  Created by JobNewMac1 on 2018/11/20.
//  Copyright © 2018年 CrazySnail. All rights reserved.
//

@import AVFoundation;
@import UIKit;

typedef void(^SnailAudioPlayerPrepareDataBlock)(void);
typedef void(^SnailAudioPlayerCompleteBlock)(void);
typedef void(^SnailAudioPlayerProgressBlock)(NSTimeInterval playTime, NSTimeInterval totalTime);
typedef void(^SnailAudioPlayerErrorBlock)(NSError *error);

@interface SnailAudioPlayer : NSObject

@property (nonatomic) CGFloat volume;

@property BOOL playing;

- (void)appendPlaylist:(NSURL *)url Pre:(SnailAudioPlayerPrepareDataBlock)preBlock Pro:(SnailAudioPlayerProgressBlock)proBlock Com:(SnailAudioPlayerCompleteBlock)comBlock Eor:(SnailAudioPlayerErrorBlock)eorBlock;

- (void)play;

- (void)previous;

- (void)next;

- (void)pause;

- (void)stop;

- (void)clear;

@end
