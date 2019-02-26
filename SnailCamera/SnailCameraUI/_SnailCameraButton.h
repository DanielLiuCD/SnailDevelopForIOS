//
//  _SnailCameraButton.h
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/9/4.
//  Copyright © 2018年 com.snail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface _SnailCameraButton : UIView

@property (nonatomic ,strong) UIImage *image;

@property (nonatomic ,strong) void(^movieDoneActionBlock)(void); //按下去的回调
@property (nonatomic ,strong) void(^clickActionBlock)(void); //单击回调
@property (nonatomic ,strong) void(^startLongPressActionBlock)(void); //开始长按回调
@property (nonatomic ,strong) void(^endLongPressActionBlock)(void); //长按结束的回调

@end
