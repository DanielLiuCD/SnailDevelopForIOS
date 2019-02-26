//
//  SnailAudioRecordHUD.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/10.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailAudioRecordHUD.h"

@interface SnailAudioRecordHUD()

kSPrStrong(UIImageView *mcImg)
kSPrStrong(UIImageView *levImg)
kSPrStrong(UILabel *tip)
kSPrStrong(UIImageView *oicImg)
kSPrStrong(NSTimer *timer)

kSPr(CGFloat width)
kSPr(CGFloat height)

kSPr(BOOL canChangeUI)

@end

#define SnailAudio_HUD_TOP  20
#define SnailAudio_HUD_LEADINT  30
#define SnailAudio_HUD_SPACEING 20

#define SnailAudio_HUD_MC_SIZE_WIDTH 40
#define SnailAudio_HUD_MC_SIZE_HEIGHT (SnailAudio_HUD_MC_SIZE_WIDTH / (83.0 / 135))
#define SnailAudio_HUD_LEV_SIZE_WIDTH 30
#define SnailAudio_HUD_LEV_SIZE_HEIGHT (SnailAudio_HUD_LEV_SIZE_WIDTH / (1 / 3.0))


@implementation SnailAudioRecordHUD

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.snail_corner(10);
        self.backgroundColor = [SNA_HEX_COLOR(0x333333) colorWithAlphaComponent:0.3];
        
        self.mcImg = [UIImageView new];
        self.mcImg.image = SNA_IMAGE_NAME(snail_audio_microphone);
        
        self.levImg = [UIImageView new];
        
        self.oicImg = [UIImageView new];
        self.oicImg.contentMode = UIViewContentModeScaleAspectFit;
        self.oicImg.clipsToBounds = true;
        
        self.tip = [UILabel new];
        self.tip.numberOfLines = 1;
        self.tip.font = SNAS_SYS_FONT(15);
        self.tip.textColor = SNA_WHITE_COLOR;
        self.tip.textAlignment = NSTextAlignmentCenter;
        
        [self snail_addSubviews:@[self.mcImg,self.levImg,self.oicImg,self.tip]];
        
        self.mcImg.frame = CGRectMake(SnailAudio_HUD_LEADINT, SnailAudio_HUD_TOP, SnailAudio_HUD_MC_SIZE_WIDTH, SnailAudio_HUD_MC_SIZE_HEIGHT);
        
        self.levImg.frame = CGRectMake(CGRectGetMaxX(self.mcImg.frame) + SnailAudio_HUD_SPACEING, CGRectGetMinY(self.mcImg.frame) + (SnailAudio_HUD_MC_SIZE_HEIGHT - SnailAudio_HUD_LEV_SIZE_HEIGHT), SnailAudio_HUD_LEV_SIZE_WIDTH, SnailAudio_HUD_LEV_SIZE_HEIGHT);
        
        self.width = CGRectGetMaxX(self.levImg.frame) + SnailAudio_HUD_LEADINT;
        
        self.oicImg.frame = CGRectMake(0, SnailAudio_HUD_TOP, self.width, CGRectGetHeight(self.mcImg.frame));
        
        self.tip.frame = CGRectMake(5, CGRectGetMaxY(self.mcImg.frame) + SnailAudio_HUD_SPACEING, self.width - 5 * 2, self.tip.font.lineHeight);
        
        self.height = CGRectGetMaxY(self.tip.frame) + SnailAudio_HUD_TOP;
        
        self.oicImg.hidden = true;
        
    }
    return self;
}

- (void)showOnView:(UIView *)view {
    
    [self stopTimer];
    
    [view addSubview:self];
    self.bounds = CGRectMake(0, 0, self.width, self.height);
    self.center = view.center;
    self.canChangeUI = true;
    
}

- (void)showLevel:(SnailAudioRecordLevel)level Text:(NSString *)text {
    
    if (self.canChangeUI == false) return;
    
    if (self.mcImg.hidden) {
        self.mcImg.hidden = false;
        self.levImg.hidden = false;
        self.oicImg.hidden = true;
    }
    self.tip.text = text;
    
    NSInteger index = 0;
    switch (level) {
        case SnailAudioRecordLevel_0:
        case SnailAudioRecordLevel_1:
            index = 1;
            break;
        case SnailAudioRecordLevel_2:
        case SnailAudioRecordLevel_3:
            index = 2;
            break;
        case SnailAudioRecordLevel_4:
        case SnailAudioRecordLevel_5:
            index = 3;
            break;
        case SnailAudioRecordLevel_6:
        case SnailAudioRecordLevel_7:
            index = 4;
            break;
        case SnailAudioRecordLevel_8:
        case SnailAudioRecordLevel_9:
            index = 5;
            break;
        case SnailAudioRecordLevel_10:
            index = 6;
            break;
        default:
            break;
    }
    
    self.levImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"snail_audio_power_level_%ld",(long)index]];
    
}

- (void)showCancle:(NSString *)text {
    
    if (self.canChangeUI == false) return;
    
    if (!self.mcImg.hidden) {
        self.mcImg.hidden = true;
        self.levImg.hidden = true;
        self.oicImg.hidden = false;
    }
    
    self.tip.text = text;
    self.oicImg.image = SNA_IMAGE_NAME(snail_audio_cancle);
    
}

- (void)showWaraing:(NSString *)text {
    
    if (self.canChangeUI == false) return;
    
    if (!self.mcImg.hidden) {
        self.mcImg.hidden = true;
        self.levImg.hidden = true;
        self.oicImg.hidden = false;
    }
    
    self.tip.text = text;
    self.oicImg.image = SNA_IMAGE_NAME(snail_audio_waraing);
    
}

- (void)beginLockUI {
    self.canChangeUI = false;
}

- (void)endLockUI {
    self.canChangeUI = true;
}

- (void)hidden {
    [self stopTimer];
    [self removeFromSuperview];
}

- (void)hiddenDelay:(NSTimeInterval)time {
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(hidden) userInfo:nil repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}


@end
