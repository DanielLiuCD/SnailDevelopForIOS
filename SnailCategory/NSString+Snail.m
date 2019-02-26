//
//  NSString+Snail.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/6.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "NSString+Snail.h"
#import "NSDate+Snail.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (Snail)

- (CGFloat)snail_calculate_height:(CGSize)size attributes:(NSDictionary *)attributes {
    CGSize tsize = [self snail_calculate_size:size attributes:attributes];
    return tsize.height;
}

- (CGFloat)snail_calculate_width:(CGSize)size attributes:(NSDictionary *)attributes {
    CGSize tsize = [self snail_calculate_size:size attributes:attributes];
    return tsize.width;
}

- (CGFloat)snail_calculate_width_ForUILabel:(CGSize)size attributes:(NSDictionary *)attributes {
    CGSize tsize = [self snail_calculate_size:size attributes:attributes];
    return tsize.width + 10;
}

- (CGSize)snail_calculate_size:(CGSize)size attributes:(NSDictionary *)attributes {
    CGSize tsize = [self boundingRectWithSize:size options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return (CGSize){.width=ceil(tsize.width),.height=ceil(tsize.height)};
}

- (NSString *)snail_unix_time_to_human:(NSString *)dateFormater {
    
    double temp = [self doubleValue] / 1000.0;
    if ([self length] == 10) temp = [self doubleValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:temp];
    return [date snail_date_string:dateFormater];
    
}

- (NSString *)snail_url_encode {
    
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodedUrl = [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return encodedUrl;
    
}

- (NSString *)snail_url_decode {
    
    NSString *decodedString  = [self stringByRemovingPercentEncoding];
    return decodedString;
    
}

- (NSString *)snail_filter_json_space_line {
    
    NSMutableString *mutStr = [NSMutableString stringWithString:self];
    NSRange range = {0,self.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr.copy;
    
}

- (BOOL)snail_check_num_char_under {
    return [self _snail_check_regex_match:@"^\\w+$"];
}

- (BOOL)snail_check_email {
    return [self _snail_check_regex_match:@"[\\w!#$%&'*+/=?^_`{|}~-]+(?:\\.[\\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\\w](?:[\\w-]*[\\w])?\\.)+[\\w](?:[\\w-]*[\\w])?"];
}

- (BOOL)_snail_check_regex_match:(NSString *)regx {
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regx];
    return [pre evaluateWithObject:self];
    
}

/*https://www.jianshu.com/p/d0f6c62b57e1*/
- (BOOL)snail_contains_emoji {
    
    __block BOOL returnValue = NO;
    
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
    
}

/*https://www.jianshu.com/p/d0f6c62b57e1*/
- (BOOL)snail_has_emoji {
    
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
    
}

/*https://www.jianshu.com/p/d0f6c62b57e1*/
- (BOOL)snail_is_nine_keybord {
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)self.length;
    for(int i=0;i<len;i++)
    {
        if(!([other rangeOfString:self].location != NSNotFound))
            return NO;
    }
    return YES;
}

- (NSString *)snail_md5:(BOOL)isLower {
    
    if (self == nil) return nil;
    
    const char *data = [self UTF8String];
    unsigned char resultArray[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data, (CC_LONG) strlen(data), resultArray);
    NSMutableString *resultString = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        if (isLower) [resultString appendFormat:@"%02x", resultArray[i]];
        else [resultString appendFormat:@"%02X", resultArray[i]];
    }
    return resultString;
    
}
@end
