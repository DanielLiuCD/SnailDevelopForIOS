//
//  SnailScanCodeManager.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/11/29.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailScanCodeManager.h"

@interface _SnailScanImageQRCode : NSObject

+ (void)scanFromeImage:(UIImage *)image CompleteCallback:(void(^)(NSString *result))block;

@end

@implementation _SnailScanImageQRCode

+ (UIImage *)detailImage:(UIImage *)image {
    
    UIImage* bigImage = image;
    float actualHeight = bigImage.size.height;
    float actualWidth = bigImage.size.width;
    float newWidth =0;
    float newHeight =0;
    if(actualWidth > actualHeight) {//宽图
        newHeight = 256.0f;
        newWidth = actualWidth / actualHeight * newHeight;
    }
    else {//长图
        newWidth = 256.0f;
        newHeight = actualHeight / actualWidth * newWidth;
    }
    
    CGRect rect = CGRectMake(0.0,0.0, newWidth, newHeight);
    UIGraphicsBeginImageContext(rect.size);
    [bigImage drawInRect:rect];
    image =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (void)scanFromeImage:(UIImage *)image CompleteCallback:(void(^)(NSString *result))block {
    
    UIImage *tImage = [self detailImage:image];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSData *imageData = UIImagePNGRepresentation(tImage);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    NSArray *features = [detector featuresInImage:ciImage];
    CIQRCodeFeature *feature = [features objectAtIndex:0];
    NSString *scannedResult = feature.messageString;
    
#if DEBUG
    block(scannedResult);
#else
    if (block) block(scannedResult);
#endif
    
}

@end

@interface _SnailScanCreateQRCode : NSObject

+ (UIImage *)createQRCodeForme:(NSString *)string size:(CGFloat)size;

@end

@implementation _SnailScanCreateQRCode

+ (UIImage *)createQRCodeForme:(NSString *)string size:(CGFloat)size {
    
    //创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //过滤器恢复默认
    [filter setDefaults];
    //将NSString格式转化成NSData格式
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [filter setValue:data forKeyPath:@"inputMessage"];
    //获取二维码过滤器生成的二维码
    CIImage *image = [filter outputImage];
    
    return [self createNonInterpolatedUIImageFormCIImage:image withSize:size];
    
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end

@implementation SnailScanCodeManager

+ (void)scanFromeImage:(UIImage *)image CompleteCallback:(void(^)(NSString *result))block {
    return [_SnailScanImageQRCode scanFromeImage:image CompleteCallback:block];
}

+ (UIImage *)createQRCodeForme:(NSString *)string size:(CGFloat)size {
    return [_SnailScanCreateQRCode createQRCodeForme:string size:size];
}

@end
