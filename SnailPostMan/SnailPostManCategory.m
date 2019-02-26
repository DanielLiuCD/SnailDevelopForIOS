//
//  SnailPostManCategory.m
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/12/11.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailPostManCategory.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSArray (SnailPostMan)

- (NSString *)SnailPostManInsertSeparator:(NSString *)separator {
    
    if (self.count == 0) return nil;
    NSMutableString *tmp = [NSMutableString new];
    for (NSString *str in self) {
        [tmp appendString:str];
        [tmp appendString:separator];
    }
    [tmp deleteCharactersInRange:NSMakeRange(tmp.length - 1, 1)];
    return tmp;
    
}

@end

@implementation NSDictionary (SnaiPostMan)

- (NSString *)SnailPostManHttpParmaString {
    
    if (self.count == 0) return nil;
    NSMutableString *tmp = [NSMutableString new];
    for (NSString *key in self.allKeys) {
        [tmp appendString:[NSString stringWithFormat:@"%@=%@&",key,self[key]]];
    }
    [tmp deleteCharactersInRange:NSMakeRange(tmp.length - 1, 1)];
    return tmp;
    
}

- (NSString *)SnailPostManSortParamsString {
    
    if (self.count == 0) return nil;
    
    NSArray *keysArray = [self allKeys];
    NSArray *sortedArray = [keysArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSMutableString *tmp = [NSMutableString new];
    for (NSString *key in sortedArray) {
        [tmp appendString:[NSString stringWithFormat:@"%@=%@&",key,self[key]]];
    }
    [tmp deleteCharactersInRange:NSMakeRange(tmp.length - 1, 1)];
    return tmp;
    
}

@end

@implementation NSString (SnailPostMan)

- (NSString *)SnailPostManMD5 {
    
    if (self == nil) return nil;
    
    const char *data = [self UTF8String];
    unsigned char resultArray[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data, (CC_LONG) strlen(data), resultArray);
    NSMutableString *resultString = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02X", resultArray[i]];
    }
    return resultString;
    
}

- (NSString *)SnailPostManFilterJsonSpace {
    
    NSMutableString *mutStr = [NSMutableString stringWithString:self];
    NSRange range = {0,self.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr.copy;
    
}

@end
