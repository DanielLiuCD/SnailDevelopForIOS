//
//  SnailAudioPlayer.m
//  SnailChatUI
//
//  Created by JobNewMac1 on 2018/11/20.
//  Copyright © 2018年 CrazySnail. All rights reserved.
//

#import "SnailAudioPlayer.h"

@interface sna_SnailAudioPlayerItem : NSObject

@property (nonatomic ,copy) NSURL *url;
@property (nonatomic ,strong) NSData *data;
@property (nonatomic ,copy) SnailAudioPlayerPrepareDataBlock preBlock;
@property (nonatomic ,copy) SnailAudioPlayerCompleteBlock comBlock;
@property (nonatomic ,copy) SnailAudioPlayerProgressBlock proBlock;
@property (nonatomic ,copy) SnailAudioPlayerErrorBlock eorBlock;

@end

@implementation sna_SnailAudioPlayerItem

@end

@interface SNA_TimerBridge : NSObject

@property (nonatomic ,copy) void(^timerBlock)(void);

@end

@implementation SNA_TimerBridge

- (void)timerAction {
    if (self.timerBlock) self.timerBlock();
}

@end

@interface SnailAudioPlayer()<AVAudioPlayerDelegate>

@property (nonatomic ,strong) NSOperationQueue *prepareDataQueue;
@property (nonatomic ,strong) NSMutableArray<sna_SnailAudioPlayerItem *> *preparePlaylist;
@property (nonatomic ,strong) NSMutableArray<sna_SnailAudioPlayerItem *> *playlist;
@property (nonatomic ,strong) AVAudioPlayer *player;
@property (nonatomic ,strong) NSLock *lock;
@property (nonatomic ,strong) NSTimer *timer;
@property (nonatomic ,strong) SNA_TimerBridge *timerBridge;
@property (nonatomic ,weak) sna_SnailAudioPlayerItem *playItem;
@property (nonatomic) NSInteger index;

@end

@implementation SnailAudioPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.volume = 3.0;
        self.preparePlaylist = [NSMutableArray new];
        self.playlist = [NSMutableArray new];
        self.prepareDataQueue = [NSOperationQueue new];
        self.prepareDataQueue.maxConcurrentOperationCount = 2;
        self.lock = [NSLock new];
        self.index = -1;
        __weak typeof(self) self_weak_ = self;
        self.timerBridge = [SNA_TimerBridge new];
        self.timerBridge.timerBlock = ^{
            [self_weak_ timerAction];
        };
    }
    return self;
}

- (void)appendPlaylist:(NSURL *)url Pre:(SnailAudioPlayerPrepareDataBlock)preBlock Pro:(SnailAudioPlayerProgressBlock)proBlock Com:(SnailAudioPlayerCompleteBlock)comBlock Eor:(SnailAudioPlayerErrorBlock)eorBlock {
    
    if (url) {
        sna_SnailAudioPlayerItem *item = [sna_SnailAudioPlayerItem new];
        item.url = url;
        item.preBlock = preBlock;
        item.proBlock = proBlock;
        item.comBlock = comBlock;
        item.eorBlock = eorBlock;
        
        [self.lock lock];
        [self.preparePlaylist addObject:item];
        [self.lock unlock];
    }
    
}

- (void)sna_prepareData {
    
    if (self.preparePlaylist.count > 0) {
        [self.lock lock];
        sna_SnailAudioPlayerItem *item = self.preparePlaylist.firstObject;
        [self.preparePlaylist removeObject:item];
        [self.lock unlock];
        
        __weak typeof(self) self_weak_ = self;
        NSBlockOperation *opera = [NSBlockOperation blockOperationWithBlock:^{
            if (item.preBlock) item.preBlock();
            NSData *data = [NSData dataWithContentsOfURL:item.url];
            if (data) {
                item.data = data;
                [self_weak_.lock lock];
                [self_weak_.playlist addObject:item];
                [self_weak_.lock unlock];
                if (self_weak_.playing) [self _play];
            }
        }];
        [self.prepareDataQueue addOperation:opera];
    
    }
    
}

#pragma mark -

- (void)play {
    if (!self.player.playing) {
        if (self.player) {
            [self resume];
        }
        else if (self.playlist.count > 0) {
            [self next];
        }
        else if (self.preparePlaylist.count > 0) {
            [self.lock lock];
            self.playing = true;
            self.index = 0;
            [self.lock unlock];
            [self sna_prepareData];
        }
    }
}

- (void)_play {
    
    if (self.index < self.playlist.count) {
        self.playItem = self.playlist[self.index];
    }
    else if (self.index < self.preparePlaylist.count + self.playlist.count) {
        self.playItem = self.preparePlaylist[self.index - self.playlist.count];
    }
    
    if (self.playItem) {
        if (self.playItem.data) {
            
            [self.lock lock];
            self.playing = true;
            [self.lock unlock];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                if (self.player) {
                    [self.player stop];
                    self.player.delegate = nil;
                    self.player = nil;
                }
                self.player = [[AVAudioPlayer alloc] initWithData:self.playItem.data error:nil];
                self.player.delegate = self;
                self.player.volume = self.volume;
                [self.player prepareToPlay];
                [self.player play];
                [self startTimer];
            });
        }
        else {
            [self.lock lock];
            self.playing = true;
            [self.lock unlock];
            [self sna_prepareData];
        }
    }

}

- (void)next {
    [self.lock lock];
    self.index++;
    [self.lock unlock];
    if ([self checkIndex]) [self _play];
}

- (void)previous {
    [self.lock lock];
    self.index--;
    [self.lock unlock];
    if ([self checkIndex]) [self _play];
}

- (BOOL)checkIndex {
    BOOL tmp = false;
    
    [self.lock lock];
    if (self.index >= self.playlist.count && self.index >= (self.playlist.count + self.preparePlaylist.count)) {
        tmp = false;self.index--;
    }
    else if (self.index < 0) {
        tmp = false;self.index++;
    }
    else tmp = true;
    [self.lock unlock];
    
    return tmp;
}

- (void)resume {
    if (self.player) {
        self.playing = true;
        [self startTimer];
        [self.player play];
    }
}

- (void)pause {
    if (self.player) {
        self.playing = false;
        [self clearTimer];
        [self.player pause];
    }
}

- (void)stop {
    [self pause];
    if (self.playItem && self.playItem.comBlock) self.playItem.comBlock();
    self.playItem = nil;
    self.index = -1;
    self.player.delegate = nil;
    self.player = nil;
}

- (void)clear {
    [self stop];
    [self.prepareDataQueue cancelAllOperations];
    self.preparePlaylist = nil;
    self.playlist = nil;
}

#pragma mark -

- (void)startTimer {
    if (self.timer) [self clearTimer];
    self.timer = [NSTimer timerWithTimeInterval:1 target:self.timerBridge selector:@selector(timerAction) userInfo:nil repeats:true];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)clearTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerAction {
    if (self.playItem && self.playItem.proBlock) {
        self.playItem.proBlock(self.player.currentTime, self.player.duration);
    }
}

- (void)dealloc {
    [self clear];
}

@end

@interface SnailAudioPlayer(PLAYERDELEGATE)

@end

@implementation SnailAudioPlayer(PLAYERDELEGATE)

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (self.playItem) if (self.playItem.comBlock) self.playItem.comBlock();
    [self.lock lock];
    self.playItem = nil;
    self.playing = false;
    [self.lock unlock];
    [self next];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    if (self.playItem) if (self.playItem.eorBlock) self.playItem.eorBlock(error);
    [self.lock lock];
    self.playItem = nil;
    self.playing = false;
    [self.lock unlock];
    [self next];
}

@end
