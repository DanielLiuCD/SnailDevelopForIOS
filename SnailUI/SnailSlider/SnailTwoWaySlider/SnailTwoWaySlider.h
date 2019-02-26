//
//  SnailTwoWaySlider.h
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2018/12/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailTwoWaySlider : UIControl

@property (nonatomic ,assign) CGFloat littleValue;
@property (nonatomic ,assign) CGFloat largeValue;
@property (nonatomic ,strong) UIColor *foregroundColor;
@property (nonatomic ,strong) UIColor *sliderColor;

-(void)setImageOfLittleSlider:(UIImage *)image;
-(void)setImageOfLargeSlider:(UIImage *)image;

@end
