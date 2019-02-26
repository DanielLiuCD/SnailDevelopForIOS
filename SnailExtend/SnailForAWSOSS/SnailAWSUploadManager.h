//
//  SnailAWSUploadManager.h
//  lesan
//
//  Created by liu on 2018/8/6.
//  Copyright © 2018年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSS3.h"

@interface SnailAWSUploadManager : NSObject

- (void)uploadWithBucketName:(NSString *)bucket
                       Files:(NSArray<NSURL *> *)fileUrls
                        Keys:(NSArray<NSString *> *)keys
                    Progress:(void(^)(CGFloat progress))proBlock
                       Error:(void(^)(NSError *error))errorBlock
                     Success:(void(^)(NSArray<NSString *> *urls))successBlock;

@end
