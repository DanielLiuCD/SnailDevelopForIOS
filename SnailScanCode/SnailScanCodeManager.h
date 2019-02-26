//
//  SnailScanCodeManager.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/11/29.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnailScanCodeManager : NSObject

+ (void)scanFromeImage:(UIImage *)image CompleteCallback:(void(^)(NSString *result))block;

+ (UIImage *)createQRCodeForme:(NSString *)string size:(CGFloat)size;

@end
