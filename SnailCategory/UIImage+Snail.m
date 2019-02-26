//
//  UIImage+Snail.m
//  repai
//
//  Created by liu on 2018/8/26.
//  Copyright © 2018年 ning. All rights reserved.
//

#import "UIImage+Snail.h"

@implementation UIImage (Snail)

- (UIImage *)snail_compressImageTargetWidth:(CGFloat)maxWidth MaxLenght:(NSInteger)maxLength {
    
    NSLog(@"最开始%ldkb",[UIImagePNGRepresentation(self) length] / 1000);
    
    CGFloat whScale = self.size.width / self.size.height;
    CGFloat maxHeight = maxWidth / whScale;
    CGSize imageSize = self.size;
    
    CGSize targetSize = CGSizeZero;
    
    BOOL needDraw = false;
    if (imageSize.width >= maxWidth && imageSize.height > maxHeight) {
        needDraw = true;
        targetSize = CGSizeMake(maxWidth, maxHeight);
    }
    else if (imageSize.width >= maxWidth && imageSize.height < maxHeight) {
        needDraw = true;
        targetSize = CGSizeMake(maxWidth, imageSize.height);
    }
    else if (imageSize.height > maxHeight) {
        needDraw = true;
        targetSize = CGSizeMake(imageSize.width, maxHeight);
    }
    
    UIImage *tmpImage;
    if (needDraw) {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, self.scale);
        [self drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
        tmpImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else tmpImage = self;
    
    NSLog(@"前%ldkb",[UIImageJPEGRepresentation(tmpImage, 1) length] / 1000);
    
    if ([UIImageJPEGRepresentation(tmpImage, 1) length] > maxLength * 1000) {
        tmpImage = [[UIImage alloc] initWithData:UIImageJPEGRepresentation(tmpImage,.5)];
    };
    
    NSLog(@"后%ldkb",[UIImageJPEGRepresentation(tmpImage, 1) length] / 1000);
    
    return tmpImage;
    
}
/*https://www.jianshu.com/p/51a0e32c8016*/
- (UIColor *)snail_color_at_pixel:(CGPoint)point {
    
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast |     kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
