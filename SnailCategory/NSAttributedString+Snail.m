//
//  NSAttributedString+Snail.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "NSAttributedString+Snail.h"

@implementation NSAttributedString (Snail)

+ (NSMutableAttributedString *)snailAttribute:(NSArray<NSDictionary *> *)array {
    
    NSMutableAttributedString *attr = [NSMutableAttributedString new];
    for (NSDictionary *dic in array) {
        NSAttributedString *tmp;
        if (dic[kSNAAttributed]) tmp = [[NSAttributedString alloc] initWithString:dic[kSNAAttrText] attributes:dic[kSNAAttributed]];
        else tmp = [[NSAttributedString alloc] initWithString:dic[kSNAAttrText]];
        [attr appendAttributedString:tmp];
    }
    return attr;
    
}

- (CGSize)snail_calculate_size:(CGSize)size {
    return [self boundingRectWithSize:size options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
}

@end
