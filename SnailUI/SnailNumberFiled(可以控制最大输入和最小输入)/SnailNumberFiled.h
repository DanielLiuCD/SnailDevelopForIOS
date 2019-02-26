//
//  SnailNumberFiled.h
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2018/12/21.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailNumberFiled : UIView

@property (nonatomic) NSInteger minNum;
@property (nonatomic) NSInteger maxNum;
@property (nonatomic) NSInteger num;
@property (nonatomic ,strong) UIColor *textColor;
@property (nonatomic ,strong) UIFont *font;

@property(nonatomic, readonly) BOOL isFirstResponder;

@property (nonatomic ,copy) void(^numberChangeBlock)(NSInteger num,BOOL isKeybordHidden);

@end
