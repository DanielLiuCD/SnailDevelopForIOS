//
//  SnailUplaod.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/2.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailUplaod.h"

@implementation SnailUPBModel

- (SnailUploadObjcetType)takeSnailUPObjcType {
    return SnailUploadObjcetTypeNone;
}

- (NSArray *)takeSnailUploadResultUrls {
    return nil;
}

- (NSString *)takeSnailUploadResultUrl {
    return nil;
}

@end

@implementation SnailUPREModel

- (SnailUploadObjcetType)takeSnailUPObjcType {
    return SnailUploadObjcetTypeREObjc;
}

- (NSArray *)takeSnailUploadResultUrls {
    return nil;
}

- (NSString *)takeSnailUploadResultUrl {
    return nil;
}

@end

@implementation SnailUPAFModel

@end

@implementation SnailUPRECModel

- (SnailUploadObjcetType)takeSnailUPObjcType {
    return SnailUploadObjcetTypeRECObjc;
}

- (NSArray<NSString *> *)takeSnailUploadResultUrls {
    return nil;
}

- (NSString *)takeSnailUploadResultUrl {
    return nil;
}

@end

@implementation SnailUPRUModel

- (SnailUploadObjcetType)takeSnailUPObjcType {
    return SnailUploadObjcetTypeRUObjc;
}

- (NSArray *)takeSnailUploadResultUrls {
    return @[self.path];
}

- (NSString *)takeSnailUploadResultUrl {
    return self.path;
}

@end

@implementation SnailUPRUCModel

- (SnailUploadObjcetType)takeSnailUPObjcType {
    return SnailUploadObjcetTypeRUCObjc;
}

- (NSArray<NSString *> *)takeSnailUploadResultUrls {
    NSMutableArray *datas = [NSMutableArray new];
    for (SnailUPRUModel *ru in self.files) {
        [datas addObject:ru.path];
    }
    return datas;
}

- (NSString *)takeSnailUploadResultUrl {
    return [[self takeSnailUploadResultUrls] componentsJoinedByString:@","];
}

@end
