//
//  SnailFadePresentationController.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/2.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailFadePresentationController : UIPresentationController

@property (nonatomic ,strong) UIColor *(^dimColor)(void); //返回背景颜色
@property (nonatomic ,strong) void (^tapClick)(void); //背景点击回调

@end
