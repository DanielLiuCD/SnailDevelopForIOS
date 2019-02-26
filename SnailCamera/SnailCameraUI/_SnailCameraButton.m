//
//  _SnailCameraButton.m
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/9/4.
//  Copyright © 2018年 com.snail. All rights reserved.
//

#import "_SnailCameraButton.h"

@interface _SnailCameraButton()

@property (nonatomic ,strong) UIButton *button;
@property (nonatomic ,strong) NSTimer *timer;
@property (nonatomic) NSUInteger timeStamp;

@end

@implementation _SnailCameraButton

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.button = [UIButton new];
        [self.button addTarget:self action:@selector(touchUpInAction) forControlEvents:UIControlEventTouchUpInside];
        [self.button addTarget:self action:@selector(touchUpInAction) forControlEvents:UIControlEventTouchUpOutside];
        [self.button addTarget:self action:@selector(startMovieAction) forControlEvents:UIControlEventTouchDown];
        
        [self addSubview:self.button];
        
        self.button.translatesAutoresizingMaskIntoConstraints = false;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_button);
        
        NSArray *tmps0 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_button]-0-|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:views];
        NSArray *tmps1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_button]-0-|" options:NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing metrics:nil views:views];
        
        [self addConstraints:tmps0];
        [self addConstraints:tmps1];
        
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    [self.button setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)startMovieAction {
    
    if (self.movieDoneActionBlock) self.movieDoneActionBlock();
    
    [self stopTimer];
    if (self.startLongPressActionBlock || self.endLongPressActionBlock) {
        self.timeStamp = CACurrentMediaTime();
        self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:false];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    
}

- (void)touchUpInAction {
    
    [self stopTimer];
    
    NSTimeInterval tmp = CACurrentMediaTime();
    
    if ((self.startLongPressActionBlock || self.endLongPressActionBlock) && tmp - self.timeStamp >= 1) {
        if (self.endLongPressActionBlock) self.endLongPressActionBlock();
    }
    else if (self.clickActionBlock) self.clickActionBlock();
}

- (void)timerAction {
    
    [self stopTimer];
    NSTimeInterval tmp = CACurrentMediaTime();
    if (tmp - self.timeStamp >= 1) {
        if (self.startLongPressActionBlock) self.startLongPressActionBlock();
    }
    
}

- (void)stopTimer {
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
}

@end
