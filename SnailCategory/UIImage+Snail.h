//
//  UIImage+Snail.h
//  repai
//
//  Created by liu on 2018/8/26.
//  Copyright © 2018年 ning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Snail)

- (UIImage *)snail_compressImageTargetWidth:(CGFloat)maxWidth MaxLenght:(NSInteger)maxLength;

///某一点的颜色
- (UIColor *)snail_color_at_pixel:(CGPoint)point;

@end
