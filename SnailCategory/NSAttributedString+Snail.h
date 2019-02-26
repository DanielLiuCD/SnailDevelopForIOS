//
//  NSAttributedString+Snail.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSNAAttrText    @"kSNAAttrText"
#define kSNAAttributed   @"kSNAAttributed"

@interface NSAttributedString (Snail)

+ (NSMutableAttributedString *)snailAttribute:(NSArray<NSDictionary *> *)array;

- (CGSize)snail_calculate_size:(CGSize)size;

@end
