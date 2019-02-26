//
//  SnailUplaod.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/2.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger ,SnailUploadType) {
    SnailUploadTypeNone,
    SnailUploadTypeImage,
    SnailUploadTypeFile,
};

typedef NS_ENUM(NSInteger ,SnailUploadObjcetType) {
    SnailUploadObjcetTypeNone,
    SnailUploadObjcetTypeREObjc,
    SnailUploadObjcetTypeRUObjc,
    SnailUploadObjcetTypeRECObjc,
    SnailUploadObjcetTypeRUCObjc,
};

@interface SnailUPBModel : NSObject

- (SnailUploadObjcetType)takeSnailUPObjcType;
- (NSArray<NSString *> *)takeSnailUploadResultUrls;
- (NSString *)takeSnailUploadResultUrl;

@end

@interface SnailUPREModel : SnailUPBModel   //需要上传的对象

kSPrStrong(NSURL *path)
kSPrStrong(NSData *data)
kSPrStrong(NSString *name)
kSPrStrong(NSString *domain) //如果存在将替换上传后得到链接的域名部分  alioss 等才会有用,具体替换过程自己实现

@end

@interface SnailUPAFModel : SnailUPREModel //SnailPostMan 上传需要使用的文件

kSPrStrong(NSString *key) //服务器要求的字段

@end

@interface SnailUPRECModel : SnailUPBModel  //上传对象的容器,用于上传多个对象

@property (nonatomic ,strong) NSArray<SnailUPBModel *> *files;

@end

@interface SnailUPRUModel : SnailUPBModel   //上传后得到的结果

kSPrStrong(NSString *path)
kSPrStrong(NSString *md5)

@end

@interface SnailUPRUCModel : SnailUPBModel  //返回结果的容器

@property (nonatomic ,strong) NSArray<SnailUPRUModel *> *files;

@end
