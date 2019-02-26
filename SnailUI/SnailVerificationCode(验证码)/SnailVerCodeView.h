//
//  SnailVerCodeView.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/27.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailVerCodeView : UIView

@property (nonatomic) NSInteger vCount; //验证码的个数
@property (nonatomic) NSInteger lineCount; //线条的条数
@property (nonatomic) CGSize codeSize; //生成验证码的大小
@property (nonatomic ,strong) UIColor *codeColor; //生成验证码的背景色

kSPrStrong(void(^clickBlock)(void))

- (NSString *)rightCodeString;

- (void)switchCode;

- (void)setSourcesCharacts:(NSArray<NSString *> *)sources;

@end
