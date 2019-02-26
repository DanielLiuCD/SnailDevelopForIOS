//
//  SnailAliOSS.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/11/16.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import "SnailAliOSS.h"
#import <AliyunOSSiOS/OSSService.h>

@implementation SnailAliOSSFile

@end

@interface SnailAliOSSResult()

@property (nonatomic ,strong) NSError *error;
@property (nonatomic ,strong) NSString *fileName;

@end

@implementation SnailAliOSSResult

@end

@implementation SnailAliOSSTokenProvider

@end

@implementation SnailAliOSSExtendInfo

@end

@interface sna_SnailAliOSSUploadTmpModel : NSObject

@property (nonatomic ,strong) NSLock *lock;
@property (nonatomic) CGFloat progress;
@property (nonatomic) NSInteger totalFileCount;
@property (nonatomic) BOOL running;
@property (nonatomic) BOOL callBack;

@end

@implementation sna_SnailAliOSSUploadTmpModel

- (void)changeTotalCount:(NSInteger)totalCount {
    [self.lock lock];
    self.totalFileCount = totalCount;
    self.progress = 0.0;
    [self.lock unlock];
}

- (void)changeRunning:(BOOL)run {
    [self.lock lock];
    self.running = run;
    [self.lock unlock];
}

- (void)changeCallBack:(BOOL)callBack {
    [self.lock lock];
    self.callBack = callBack;
    [self.lock unlock];
}

- (void)appendProgress:(CGFloat)pro {
    [self.lock lock];
    self.progress += pro;
    [self.lock unlock];
}

- (CGFloat)takeProgress {
    CGFloat tmp = 0.0;
    [self.lock lock];
    tmp = self.progress * 1.0 / self.totalFileCount;
    [self.lock unlock];
    return tmp;
}

- (NSLock *)lock {
    if (!_lock) {
        _lock = [NSLock new];
    }
    return _lock;
}

@end

static NSError *errorMaker(NSString * des) {
    return [NSError errorWithDomain:SNAIL_ALI_OSS_ERROR_DOMIN code:-101 userInfo:@{NSLocalizedDescriptionKey:des}];
}

@interface SnailAliOSSToken()

@property (nonatomic ,copy) SnailAliOSSFile *(^fileBlock)(void);
@property (nonatomic ,copy) void(^progressBlock)(CGFloat value);
@property (nonatomic ,copy) void(^successBlock)(SnailAliOSSResult *result);
@property (nonatomic ,copy) void(^faliedBlock)(NSError *error);

@property (nonatomic ,weak) OSSClient *client;

@property (nonatomic ,strong) sna_SnailAliOSSUploadTmpModel *tmpModel;

@property (nonatomic ,strong) NSOperationQueue *queue;

@property (nonatomic ,strong) NSMutableArray *puts;
@property (nonatomic ,strong) NSMutableArray *operas;
@property (nonatomic ,strong) NSMutableDictionary *haveUploadFiles;
@property (nonatomic ,strong) NSTimer *timer;

@end

@implementation SnailAliOSSToken

- (void)upload {
    
    if (self.running) return;
    
    if (self.fileBlock) {
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(_upload) object:nil];
        [thread start];
    }
    else [self faliedAction:errorMaker(NSLocalizedString(@"缺少文件", nil))];
}

- (void)_upload {
    SnailAliOSSFile *file = self.fileBlock();
    SnailAliOSSResult *result = [self preparedUpload:file];
    [self.tmpModel changeTotalCount:self.operas.count];
    [self.tmpModel changeRunning:true];
    [self.tmpModel changeCallBack:true];
    [self startTimer];
    [self.queue addOperations:self.operas waitUntilFinished:true];
    [self.tmpModel changeRunning:false];
    [self.puts removeAllObjects];
    [self.operas removeAllObjects];
    [self stopTimer];
    [self performSelectorOnMainThread:@selector(_uploadFinished:) withObject:result waitUntilDone:false];
}

- (void)_uploadFinished:(SnailAliOSSResult *)result {
    if (self.tmpModel.callBack) {
        NSError *error = [self validResult:result];
        if (error) [self faliedAction:error];
        else {
            [self.haveUploadFiles removeAllObjects];
            if (self.successBlock) self.successBlock(result);
        }
    }
}

- (void)cancle {
    [self.tmpModel changeCallBack:false];
    [self.queue cancelAllOperations];
    [self.puts makeObjectsPerformSelector:@selector(cancle)];
}

- (void)clear {
    [self cancle];
    [self.haveUploadFiles removeAllObjects];
}

- (NSError *)validResult:(SnailAliOSSResult *)result {
    NSError *error = nil;
    if (result.error) {
        error = result.error;
        if (!error && result.url) self.haveUploadFiles[result.fileName] = result.url;
    }
    if (result.results) {
        for (SnailAliOSSResult *tmp in result.results) {
            NSError *tmperror = [self validResult:tmp];
            if (!error) error = tmperror;
        }
    }
    return error;
}

- (SnailAliOSSResult *)preparedUpload:(SnailAliOSSFile *)file {
    
    __weak typeof(self) self_weak_ = self;
    
    int64_t expertime = file.expirationTimeInMilliSecond;
    
    NSString *bucketName = [file.bucketName copy];
    if (!bucketName) bucketName = [SnailAliOSS sharedInstance].extendInfo.bucketName;
    
    NSString *name = [file.name copy];
    if (!name) name = [NSString stringWithFormat:@"file-%f",[[NSDate date] timeIntervalSince1970]];
    
    SnailAliOSSResult *result = [SnailAliOSSResult new];
    result.fileName = name;
    result.extendInfo = file.extendInfo;
    
    BOOL shouldUpload = true;
    if (self.haveUploadFiles[name]) {
        result.url = self.haveUploadFiles[name];
        shouldUpload = false;
    }
    else if (!file.data) {
        NSData *tmpdata = [NSData dataWithContentsOfURL:file.path];
        if (!tmpdata) shouldUpload = false;
    }
    
    if (shouldUpload) {
        
        OSSPutObjectRequest * put = [OSSPutObjectRequest new];
        put.objectKey = name;
        put.bucketName = bucketName;
        if (file.path) {
            put.uploadingFileURL = file.path;
            if (!file.contentMd5) file.contentMd5 = [OSSUtil base64Md5ForFileURL:file.path];
        }
        else if (file.data) {
            put.uploadingData = file.data;
            if (!file.contentMd5) file.contentMd5 = [OSSUtil base64Md5ForData:file.data];
        }
        put.contentType = file.contentType;
        put.contentMd5 = file.contentMd5;
        put.contentEncoding = file.contentEncoding;
        put.contentDisposition = file.contentDisposition;
        put.objectMeta = file.objectMeta;
        
        put.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            [self_weak_.tmpModel appendProgress:bytesSent * 1.0 / totalBytesExpectedToSend];
        };
        
        [self.puts addObject:put];
        
        NSBlockOperation *opera = [NSBlockOperation blockOperationWithBlock:^{
            OSSTask * putTask = [self.client putObject:put];
            [putTask continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {
                if (task.error) result.error = task.error;
                else if (expertime <= 0) result.url = [self_weak_.client presignPublicURLWithBucketName:bucketName withObjectKey:name].result;
                else result.url = [self_weak_.client presignConstrainURLWithBucketName:bucketName withObjectKey:name withExpirationInterval:expertime].result;
                return nil;
            }];
            [putTask waitUntilFinished];
        }];
        [self.operas addObject:opera];
    }

    if (file.subfiles.count > 0) {
        NSMutableArray *tmps = [NSMutableArray new];
        for (SnailAliOSSFile *subfile in file.subfiles) {
            [tmps addObject:[self preparedUpload:subfile]];
        }
        result.results = tmps.copy;
    }
    result.contentMd5 = file.contentMd5;
    
    return result;
    
}

- (void)faliedAction:(NSError *)error {
    if (self.faliedBlock) {
        self.faliedBlock(error);
    }
}

- (void)startTimer {
    [self stopTimer];
    self.timer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(timerAction) userInfo:nil repeats:true];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerAction {
    if (self.progressBlock) self.progressBlock([self.tmpModel takeProgress]);
}

- (BOOL)running {
    return self.tmpModel.running;
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [NSOperationQueue new];
        _queue.maxConcurrentOperationCount = 5;
    }
    return _queue;
}

- (NSMutableArray *)puts {
    if (!_puts) _puts = [NSMutableArray new];
    return _puts;
}

- (NSMutableArray *)operas {
    if (!_operas) _operas = [NSMutableArray new];
    return _operas;
}

- (NSMutableDictionary *)haveUploadFiles {
    if (!_haveUploadFiles) _haveUploadFiles = [NSMutableDictionary new];
    return _haveUploadFiles;
}

- (sna_SnailAliOSSUploadTmpModel *)tmpModel {
    if (!_tmpModel) _tmpModel = [sna_SnailAliOSSUploadTmpModel new];
    return _tmpModel;
}

- (void)dealloc {
    [self stopTimer];
    self.fileBlock = nil;
    self.successBlock = nil;
    self.progressBlock = nil;
}

@end

@interface SnailAliOSS()

@property (nonatomic ,strong) NSMutableDictionary<NSString *,OSSClient *> *clients;

@end

@implementation SnailAliOSS

+ (instancetype)sharedInstance {
    static SnailAliOSS *ali;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ali = [SnailAliOSS new];
    });
    return ali;
}

+ (SnailAliOSSToken *)Token:(SnailAliOSSFile *(^)(void))fileBlock Progress:(void (^)(CGFloat))progressBlock Success:(void (^)(SnailAliOSSResult *))successBlock Falied:(void (^)(NSError *))faliedBlock {
    
    NSString *endPoint = nil;
    return [self EndPoint:endPoint Token:fileBlock Progress:progressBlock Success:successBlock Falied:faliedBlock];
    
}

+ (SnailAliOSSToken *)EndPoint:(NSString *)endPoint Token:(SnailAliOSSFile *(^)(void))fileBlock Progress:(void (^)(CGFloat))progressBlock Success:(void (^)(SnailAliOSSResult *))successBlock Falied:(void (^)(NSError *))faliedBlock {
    
    SnailAliOSS *ali = [SnailAliOSS sharedInstance];
    if (!ali.extendInfo && ali.takeAliOSSExtendInfo) {
        ali.extendInfo = [ali takeAliOSSExtendInfo]();
    }
    if (endPoint == nil) {
        if (ali.extendInfo) endPoint = ali.extendInfo.endPoint;
    }
    
    if (endPoint == nil) {
        if (faliedBlock) faliedBlock(errorMaker(@"endPoint is nil"));
        return nil;
    }
    
    SnailAliOSSToken *token = [SnailAliOSSToken new];
    token.client = [[SnailAliOSS sharedInstance] takeClient:endPoint];
    token.faliedBlock = faliedBlock;
    token.progressBlock = progressBlock;
    token.successBlock = successBlock;
    token.fileBlock = fileBlock;
    return token;
    
}

- (OSSClient *)takeClient:(NSString *)endpoint {
    OSSClient *client = self.clients[endpoint];
    if (!client) {
        id<OSSCredentialProvider> credential = [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken * {
            
            OSSFederationToken * token = nil;
            if (self.takeAliOSSTokenProvider) {
                SnailAliOSSTokenProvider *provider = self.takeAliOSSTokenProvider(endpoint);
                token = [OSSFederationToken new];
                token.tAccessKey = provider.accessKeyId;
                token.tSecretKey = provider.accessKeySecret;
                token.tToken = provider.securityToken;
                if (provider.expirationTimeInGMTFormat) token.expirationTimeInGMTFormat = provider.expirationTimeInGMTFormat;
                else if (provider.expirationTimeInMilliSecond > 0) token.expirationTimeInMilliSecond = provider.expirationTimeInMilliSecond;
            }
            return token;
        }];
        client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
        self.clients[endpoint] = client;
    }
    return client;
}

- (NSMutableDictionary<NSString *,OSSClient *> *)clients {
    if (!_clients) {
        _clients = [NSMutableDictionary new];
    }
    return _clients;
}

@end
