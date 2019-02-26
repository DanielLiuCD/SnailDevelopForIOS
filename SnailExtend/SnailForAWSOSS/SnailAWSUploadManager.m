//
//  SnailAWSUploadManager.m
//  lesan
//
//  Created by liu on 2018/8/6.
//  Copyright © 2018年 ning. All rights reserved.
//

#import "SnailAWSUploadManager.h"

@interface SnailAWSUploadManager()

kSPr(BOOL isUploading)

kSPrStrong(AWSS3TransferManagerUploadRequest *uploadRequest)

kSPrStrong(void(^snail_progress_block)(CGFloat progress))
kSPrStrong(void(^snail_error_block)(NSError *error))
kSPrStrong(void(^snail_success_block)(NSString *url))

kSPrStrong(NSMutableDictionary *subManagerDic)
kSPrStrong(void(^snail_success_block_s)(NSArray<NSString *> *url))
kSPr(NSInteger haveFinishedCount)
kSPrStrong(NSLock *lock)
kSPrStrong(NSMutableArray *saveUrls);
kSPr(CGFloat totalProgress)

@end

@implementation SnailAWSUploadManager

- (void)uploadWithBucketName:(NSString *)bucket
                         Key:(NSString *)fileName
                        Data:(NSURL *)fileUrl
                    Progress:(void(^)(CGFloat progress))proBlock
                       Error:(void(^)(NSError *error))errorBlock
                     Success:(void(^)(NSString *url))successBlock
{
    if (self.isUploading) return;
    
    @weakify(self);
    
    self.isUploading = true;
    
    self.snail_progress_block = proBlock;
    self.snail_error_block = errorBlock;
    self.snail_success_block = successBlock;
    
    self.uploadRequest = [AWSS3TransferManagerUploadRequest new];
    self.uploadRequest.ACL = AWSS3ObjectCannedACLPublicReadWrite;
    self.uploadRequest.bucket = bucket;
    self.uploadRequest.key = fileName;
    self.uploadRequest.body = fileUrl;
    self.uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        if (self_weak_.snail_progress_block) {
            self_weak_.snail_progress_block(bytesSent * 1.0 / totalBytesExpectedToSend);
        }
    };
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:self.uploadRequest] continueWithExecutor:[AWSExecutor defaultExecutor] withBlock:^id _Nullable(AWSTask * _Nonnull t) {
        
        if (t.error) {
            
            NSLog(@"errorcode:%d",t.error.code);
            
            if (self_weak_.snail_error_block) {
                self_weak_.snail_error_block(t.error);
            }
        }
        else if (t.result && self_weak_.snail_success_block){
            self_weak_.snail_success_block([NSString stringWithFormat:@"https://s3.us-east-2.amazonaws.com/%@/%@",self_weak_.uploadRequest.bucket,self_weak_.uploadRequest.key]);
        }
        
        self_weak_.snail_success_block = nil;
        self_weak_.snail_progress_block = nil;
        self_weak_.snail_error_block = nil;
        self_weak_.uploadRequest = nil;
        self_weak_.isUploading = false;
        
        return nil;
    }];
    
}

- (void)uploadWithBucketName:(NSString *)bucket
                       Files:(NSArray<NSURL *> *)fileUrls
                        Keys:(NSArray<NSString *> *)keys
                    Progress:(void(^)(CGFloat progress))proBlock
                       Error:(void(^)(NSError *error))errorBlock
                     Success:(void(^)(NSArray<NSString *> *urls))successBlock {
    
    self.isUploading = true;
    
    self.snail_progress_block = proBlock;
    self.snail_success_block_s = successBlock;
    self.snail_error_block = errorBlock;
    self.haveFinishedCount = 0;
    
    NSInteger totalCount = fileUrls.count;
    
    for (int i = 0; i < totalCount; i++) {
        [self.saveUrls addObject:[NSNull null]];
    }
    
    @weakify(self);
    for (int i = 0; i < totalCount; i++) {

        SnailAWSUploadManager *sub = [SnailAWSUploadManager new];
        [sub uploadWithBucketName:bucket Key:keys[i] Data:fileUrls[i] Progress:^(CGFloat progress) {
            
            [self safeAddProgress:progress];
            if (self_weak_.snail_progress_block) {
                self_weak_.snail_progress_block(self_weak_.totalProgress / totalCount);
            }
            
        } Error:^(NSError *error) {
            
            [self_weak_ safeAddFinshedCount];
            [self_weak_ safeReplaceUrl:error Index:i];
            if (self_weak_.haveFinishedCount == totalCount) {
                [self_weak_ haveFinishUpload];
            }
            
        } Success:^(NSString *url) {
            
            [self_weak_ safeAddFinshedCount];
            [self_weak_ safeReplaceUrl:url Index:i];
            if (self_weak_.haveFinishedCount == totalCount) {
                [self_weak_ haveFinishUpload];
            }
            
        }];
        
        @synchronized(self) {
            self.subManagerDic[keys[i]] = sub;
        }
        
    }
    
}

- (void)safeAddFinshedCount {
    [self.lock lock];
    self.haveFinishedCount++;
    [self.lock unlock];
}

- (void)safeAddProgress:(CGFloat)progress {
    [self.lock lock];
    self.totalProgress += progress;
    [self.lock unlock];
}

- (void)safeReplaceUrl:(id)obj Index:(NSInteger)index {
    [self.lock lock];
    if (index < self.saveUrls.count) {
        self.saveUrls[index] = obj;
    }
    [self.lock unlock];
}

- (void)haveFinishUpload {
    
    NSError *error;
    for (int i = 0; i < self.saveUrls.count; i++) {
        id obj = self.saveUrls[i];
        if ([obj isKindOfClass:[NSError class]]) {
            error = obj;
            break;
        }
    }
    
    if (error && self.snail_error_block) {
        self.snail_error_block(error);
    }
    else if (self.snail_success_block_s) {
        self.snail_success_block_s(self.saveUrls);
    }
    
    self.snail_success_block_s = nil;
    self.snail_success_block = nil;
    self.snail_error_block = nil;
    self.snail_progress_block = nil;
    self.saveUrls = nil;
    self.haveFinishedCount = 0;
    self.subManagerDic = nil;
    self.isUploading = false;
}

- (NSMutableDictionary *)subManagerDic {
    if (!_subManagerDic) _subManagerDic = [NSMutableDictionary new];
    return _subManagerDic;
}

- (NSLock *)lock {
    if (!_lock) _lock = [NSLock new];
    return _lock;
}

- (NSMutableArray *)saveUrls {
    if (!_saveUrls) {
        _saveUrls = [NSMutableArray new];
    }
    return _saveUrls;
}

@end
