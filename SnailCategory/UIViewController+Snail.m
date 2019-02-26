//
//  UIViewController+Snail.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/22.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "UIViewController+Snail.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>

#pragma mark -

@interface SnailRequestAlertAction()

@property (nonatomic ,copy) NSString *title;
@property (nonatomic ,copy) NSString *placeHolder;

@end

#pragma mark -

@interface SnailResultTextAlertAction()

@property (nonatomic ,copy) NSString *placeHolder;
@property (nonatomic ,copy) NSString *text;

@end

#pragma mark -

@interface SnailResultAlertAction()

@property (nonatomic ,copy) NSString *title;
@property (nonatomic ,copy) NSArray<SnailResultTextAlertAction *> *texts;

@end

#pragma mark -

@implementation SnailRequestAlertAction

+ (instancetype)Ttile:(NSString *)title PlaceHolder:(NSString *)placeHolder {
    SnailRequestAlertAction *model = [SnailRequestAlertAction new];
    model.title = title;
    model.placeHolder = placeHolder;
    return model;
}

@end

#pragma mark -

@implementation SnailResultTextAlertAction

+ (instancetype)Text:(NSString *)text PlaceHolder:(NSString *)placeHolder {
    SnailResultTextAlertAction *model = [SnailResultTextAlertAction new];
    model.text = text;
    model.placeHolder = placeHolder;
    return model;
}

@end

#pragma mark -

@implementation SnailResultAlertAction

+ (instancetype)Ttile:(NSString *)title Texts:(NSArray<SnailResultTextAlertAction *> *)texts {
    SnailResultAlertAction *model = [SnailResultAlertAction new];
    model.title = title;
    model.texts = texts;
    return model;
}

@end

#pragma mark -

@interface SnailImageChooseImageModel()

@property (nonatomic ,copy) UIImage *image;
@property (nonatomic ,copy) NSString *imageName;
@property (nonatomic ,copy) NSString *imagePath;

@end

@implementation SnailImageChooseImageModel

@end

@interface SnailImageChooseResult()

@property (nonatomic ,strong) SnailImageChooseImageModel *original;
@property (nonatomic ,strong) SnailImageChooseImageModel *edit;

@end

@implementation SnailImageChooseResult

@end

@implementation SnailImageChooseRequest

+ (instancetype)request {
    SnailImageChooseRequest *objc = [SnailImageChooseRequest new];
    objc.edit = SnailImageChooseEditSystem;
    objc.path = false;
    objc.compressQuality = 0.7;
    objc.compressMaxSize = 1280;
    return objc;
}

@end

#pragma mark -

static char SNAILVIEWCONTROLLERIMAGEPICKERCONTROLLER;

#define SNAILIMAGEPRESSTARGTESIZE 1280

#define SnailControllerImageSelectedSavePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"SnailControllerImageSelectedSave"]

@interface SnailViewControllerImagePickerController : NSObject<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic ,strong) SnailImageChooseRequest *request;
@property (nonatomic ,copy) SnailImageChooseResultBlock selectedImageBlock;
@property (nonatomic ,copy) void (^selectedVideoBlock)(NSURL *videoUrl, UIImage *image, NSTimeInterval time);

@end

@implementation SnailViewControllerImagePickerController

- (UIImage *)_compress:(UIImage *)image Size:(CGSize)size {
    UIImage *result = nil;
    if (image.size.width > size.width && image.size.height > size.height) {
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale);
        [image drawAtPoint:CGPointZero];
        result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else result = image;
    return result;
}

- (UIImage *)_compress:(UIImage *)image Quality:(CGFloat)quality {
    
    CGFloat compression = 1;
    if (quality >= compression) return image;
    
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < quality) return [UIImage imageWithData:data];
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < quality * 0.9) {
            min = compression;
        } else if (data.length > quality) {
            max = compression;
        } else {
            break;
        }
    }
    return [UIImage imageWithData:data];
}

- (UIImage *)_compress:(UIImage *)image {
    
    switch (self.request.compress) {
        case SnailImageChooseCompressSize:
            return [self _compress:image Size:self.request.compressSize];
        case SnailImageChooseCompressQuality:
            return [self _compress:image Quality:self.request.compressQuality];
        case SnailImageChooseCompressAuto:
        {
            NSInteger targetSize = self.request.compressMaxSize;
            if (targetSize == 0) targetSize = SNAILIMAGEPRESSTARGTESIZE;
            CGSize imageSize = image.size;
            
            UIImage *tmp = nil;
            BOOL need = false;
            CGFloat needWidth = 0.0;
            CGFloat needHeight = 0.0;
            if (imageSize.width < targetSize && imageSize.height < targetSize) tmp = image;
            else if (imageSize.width > targetSize && imageSize.height > targetSize) {
                need = true;
                if (imageSize.width > imageSize.height * 2) {
                    needHeight = targetSize;
                    needWidth = imageSize.width / imageSize.height * needHeight;
                }
                else if (imageSize.height > imageSize.width * 2) {
                    needWidth = targetSize;
                    needHeight = imageSize.height / imageSize.width * needWidth;
                }
                else {
                    if (imageSize.width > imageSize.height) {
                        needWidth = targetSize;
                        needHeight = imageSize.height / imageSize.width * needWidth;
                    }
                    else {
                        needHeight = targetSize;
                        needWidth = imageSize.width / imageSize.height * needHeight;
                    }
                }
            }
            else if (imageSize.width > targetSize || imageSize.height > targetSize) {
                need = true;
                CGFloat scale = imageSize.width / imageSize.height;
                if (scale > 2 || scale < .5) {
                    needWidth = imageSize.width;
                    needHeight = imageSize.height;
                }
                else if (imageSize.width > targetSize) {
                    needHeight = targetSize;
                    needWidth = imageSize.width / imageSize.height * needHeight;
                }
                else if (imageSize.height > targetSize) {
                    needWidth = targetSize;
                    needHeight = imageSize.height / imageSize.width * needWidth;
                }
            }
            if (need) tmp = [self _compress:image Size:CGSizeMake(needWidth, needHeight)];
            tmp = [self _compress:tmp Quality:self.request.compressQuality];
            return tmp;
        }
            break;
        default:break;
    }
    
    return image;
};

- (void)detailPhotoAction:(NSDictionary<NSString *,id> *)info {
    
    if (info[UIImagePickerControllerOriginalImage]) {
        
        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        originalImage = [self _compress:originalImage];
        
        UIImage *editImage = info[UIImagePickerControllerEditedImage];
        
        NSString *originalFileName;
        NSString *editFileName;
        if (@available(iOS 11.0, *)) {
            NSURL *url = info[UIImagePickerControllerImageURL];
            originalFileName = url.absoluteString.lastPathComponent;
        }
        if (originalFileName == nil) {
            originalFileName = [NSString stringWithFormat:@"%@-%.0f.png",[UIDevice currentDevice].identifierForVendor.UUIDString,[[NSDate date] timeIntervalSince1970]];
        }
        editFileName = [[originalFileName stringByDeletingPathExtension] stringByAppendingString:[NSString stringWithFormat:@"crop%@",[originalFileName pathExtension]]];
        
        SnailImageChooseImageModel *original = [SnailImageChooseImageModel new];
        original.image = originalImage;
        original.imageName = originalFileName;
        if (self.request.path) original.imagePath = [self SnailSaveImage:originalImage Name:originalFileName];
        
        SnailImageChooseImageModel *edit = nil;
        
        switch (self.request.edit) {
            case SnailImageChooseEditSystem:
            {
                editImage = [self _compress:editImage];
                edit = [SnailImageChooseImageModel new];
                edit.image = editImage;
                edit.imageName = editFileName;
                if (self.request.path) edit.imagePath = [self SnailSaveImage:editImage Name:editFileName];
            }
                break;
                
            default:
                break;
        }
        
        SnailImageChooseResult *result = [SnailImageChooseResult new];
        result.original = original;
        result.edit = edit;
        
        self.selectedImageBlock(result);
    }
    
}

- (void)detailVideoAction:(NSDictionary<NSString *,id> *)info {
    
    NSURL *url = info[UIImagePickerControllerMediaURL]; //视频URL
    
    AVURLAsset *asset =[[AVURLAsset alloc] initWithURL:url options:nil];
    Float64 duration = CMTimeGetSeconds(asset.duration); //获取视频总时长
    
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    if (self.selectedVideoBlock) self.selectedVideoBlock(url, videoImage, duration);
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.movie"]) [self detailVideoAction:info];
    else if ([mediaType isEqualToString:@"public.image"]) [self detailPhotoAction:info];

    [self imagePickerControllerDidCancel:picker];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    self.selectedImageBlock = nil;
    self.selectedVideoBlock = nil;
    self.request = nil;
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:true completion:^{
        
    }];
    
}

- (NSString *)SnailSaveImage:(UIImage *)image Name:(NSString *)imageName {

    NSFileManager *fim = [NSFileManager defaultManager];
    if (![fim fileExistsAtPath:SnailControllerImageSelectedSavePath]) [fim createDirectoryAtPath:SnailControllerImageSelectedSavePath withIntermediateDirectories:true attributes:nil error:nil];
    NSString *savePath = [SnailControllerImageSelectedSavePath stringByAppendingPathComponent:imageName];
    if ([fim fileExistsAtPath:savePath]) [fim removeItemAtPath:savePath error:nil];
    [UIImagePNGRepresentation(image) writeToFile:savePath atomically:true];

    return savePath;
    
}

@end

#undef SnailControllerImageSelectedSavePath

#pragma mark -

@interface UIViewController()

@property (nonatomic ,strong) SnailViewControllerImagePickerController *_snailImagePickerContrioller;

@end

@implementation UIViewController (Snail)


#pragma mark -

- (void)SnailAlertTitle:(NSString *)title Message:(NSString *)message Actions:(NSArray<SnailRequestAlertAction *> *)actions Block:(void (^)(SnailResultAlertAction *, NSInteger))block {
    [self _SnailAlertControllertStyle:UIAlertControllerStyleAlert Title:title Message:message Actions:actions Block:block];
}

- (void)SnailSheetTitle:(NSString *)title Message:(NSString *)message Actions:(NSArray<SnailRequestAlertAction *> *)actions Block:(void (^)(SnailResultAlertAction *, NSInteger))block {
    [self _SnailAlertControllertStyle:UIAlertControllerStyleActionSheet Title:title Message:message Actions:actions Block:block];
}

- (void)_SnailAlertControllertStyle:(UIAlertControllerStyle)style Title:(NSString *)title Message:(NSString *)message Actions:(NSArray<SnailRequestAlertAction *> *)actions Block:(void(^)(SnailResultAlertAction *result,NSInteger index))block {
    
    UIAlertController *con = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];
    __weak typeof(con) weakCon = con;
    for (int i = 0; i < actions.count; i++) {
        @autoreleasepool {
            SnailRequestAlertAction *action = actions[i];
            if (action.placeHolder.length > 0) {
                [con addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.text = action.title;
                    textField.placeholder = action.placeHolder;
                }];
            }
            else {
                UIAlertAction *actionale = [UIAlertAction actionWithTitle:action.title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull actionle) {
                    
                    SnailResultAlertAction *result;
                    if (weakCon.textFields.count > 0) {
                        NSMutableArray *tmps = [NSMutableArray new];
                        for (UITextField *filed in weakCon.textFields) {
                            [tmps addObject:[SnailResultTextAlertAction Text:filed.text PlaceHolder:filed.placeholder]];
                        }
                        result = [SnailResultAlertAction Ttile:action.title Texts:tmps];
                    }
                    else {
                        result = [SnailResultAlertAction Ttile:action.title Texts:nil];
                    }
                    block(result,i);
                    
                }];
                [con addAction:actionale];
            }
        }
    }
    [self presentViewController:con animated:true completion:^{
        
    }];
    
}

#pragma mark -

- (void)_SnailOpenPhotoAuthBlock:(void(^)(void))block {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        switch (authStatus) {
            case PHAuthorizationStatusAuthorized:block();
                break;
            default:
            {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) block();
                    else {
                        [self SnailAlertTitle:NSLocalizedString(@"提示", nil) Message:NSLocalizedString(@"请在设置中允许相册权限", nil) Actions:@[[SnailRequestAlertAction Ttile:NSLocalizedString(@"取消", nil) PlaceHolder:nil]] Block:^(SnailResultAlertAction *result, NSInteger index) {
                            
                        }];
                    }
                }];
            }
                break;
        }
        
    }
    
}

- (void)_SnailCameraAuth:(void(^)(void))block {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (authStatus) {
            case AVAuthorizationStatusAuthorized:block();
                break;
            default:
            {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        block();
                    }
                    else {
                        [self SnailAlertTitle:NSLocalizedString(@"提示", nil) Message:NSLocalizedString(@"请在设置中允许拍照权限", nil) Actions:@[[SnailRequestAlertAction Ttile:NSLocalizedString(@"取消", nil) PlaceHolder:nil]] Block:^(SnailResultAlertAction *result, NSInteger index) {
                            
                        }];
                    }
                }];
            }
                break;
        }
        
    }
    
}

- (void)_SnailOpenImagePicker:(SnailImageChooseRequest *)request Block:(SnailImageChooseResultBlock)block {
    
    [self _SnailOpenPhotoAuthBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self._snailImagePickerContrioller.selectedImageBlock = block;
            self._snailImagePickerContrioller.request = request;
            UIImagePickerController *picker = [UIImagePickerController new];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.mediaTypes = @[(NSString*)kUTTypeImage];
            picker.delegate = self._snailImagePickerContrioller;
            picker.allowsEditing = request.edit == SnailImageChooseEditSystem;
            [self presentViewController:picker animated:YES completion:^{
                
            }];
        });
        
    }];
    
}

- (void)_SnailOpenCamera:(SnailImageChooseRequest *)request Block:(SnailImageChooseResultBlock)block {
    
    [self _SnailCameraAuth:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self._snailImagePickerContrioller.selectedImageBlock = block;
            self._snailImagePickerContrioller.request = request;
            UIImagePickerController *picker = [UIImagePickerController new];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self._snailImagePickerContrioller;
            picker.allowsEditing = request.edit == SnailImageChooseEditSystem;
            [self presentViewController:picker animated:YES completion:^{
                
            }];
        });
        
    }];

}

- (void)SnailOpenImageChooseRequest:(SnailImageChooseRequest *)request Block:(SnailImageChooseResultBlock)block {
    
    [self SnailSheetTitle:nil Message:nil Actions:@[[SnailRequestAlertAction Ttile:NSLocalizedString(@"相册", nil) PlaceHolder:nil],[SnailRequestAlertAction Ttile:NSLocalizedString(@"拍照", nil) PlaceHolder:nil],[SnailRequestAlertAction Ttile:NSLocalizedString(@"取消", nil) PlaceHolder:nil]] Block:^(SnailResultAlertAction *result, NSInteger index) {
        
        if (index == 0) {
            [self _SnailOpenImagePicker:request Block:block];
        }
        else if (index == 1) {
            [self _SnailOpenCamera:request Block:block];
        }
        
    }];
    
}

- (void)SnailOpenImagePickerController:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    [self SnailOpenImageChooseRequest:request Block:block];
}

- (void)SnailOpenImagePickerControllerNoEdit:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    request.edit = SnailImageChooseEditNone;
    [self SnailOpenImageChooseRequest:request Block:block];
}

- (void)SnailOpenImagePickerControllerAutoCompress:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    request.compress = SnailImageChooseCompressAuto;
    [self SnailOpenImageChooseRequest:request Block:block];
}

- (void)SnailOpenImagePickerControllerNoEditAutoCompress:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    request.edit = SnailImageChooseEditNone;
    request.compress = SnailImageChooseCompressAuto;
    [self SnailOpenImageChooseRequest:request Block:block];
}

- (void)SnailOpenCamera:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    [self _SnailOpenCamera:request Block:block];
}

- (void)SnailOpenCameraNoEdit:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    request.edit = SnailImageChooseEditNone;
    [self _SnailOpenCamera:request Block:block];
}

- (void)SnailOpenCameraAutoCompress:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    request.compress = SnailImageChooseCompressAuto;
    [self _SnailOpenCamera:request Block:block];
}

- (void)SnailOpenCameraNoEditAutoCompress:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    request.edit = SnailImageChooseEditNone;
    request.compress = SnailImageChooseCompressAuto;
    [self _SnailOpenCamera:request Block:block];
}

- (void)SnailOpenCameraWithPath:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    request.path = true;
    [self _SnailOpenCamera:request Block:block];
}

- (void)SnailOpenCameraWithPathNoEdit:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    request.path = true;
    request.edit = SnailImageChooseEditNone;
    [self _SnailOpenCamera:request Block:block];
}

- (void)SnailOpenCameraWithPathAutoCompress:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    request.path = true;
    request.compress = SnailImageChooseCompressAuto;
    [self _SnailOpenCamera:request Block:block];
}

- (void)SnailOpenCameraWithPathNoEditAutoCompress:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    request.path = true;
    request.edit = SnailImageChooseEditNone;
    request.compress = SnailImageChooseCompressAuto;
    [self _SnailOpenCamera:request Block:block];
}

- (void)SnailOpenImageChoose:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    [self _SnailOpenImagePicker:request Block:block];
}

- (void)SnailOpenImageChooseNoEdit:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    request.edit = SnailImageChooseEditNone;
    [self _SnailOpenImagePicker:request Block:block];
}

- (void)SnailOpenImageChooseAutoCompress:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    request.compress = SnailImageChooseCompressAuto;
    [self _SnailOpenImagePicker:request Block:block];
}

- (void)SnailOpenImageChooseNoEditAutoCompress:(SnailImageChooseResultBlock)block {
    SnailImageChooseRequest *request = [SnailImageChooseRequest request];
    request.edit = SnailImageChooseEditNone;
    request.compress = SnailImageChooseCompressAuto;
    [self _SnailOpenImagePicker:request Block:block];
}

- (void)SnailOpenVideoChoose:(NSTimeInterval)maxTime Block:(void (^)(NSURL *, UIImage *, NSTimeInterval))block {

    [self _SnailOpenPhotoAuthBlock:^{

        dispatch_async(dispatch_get_main_queue(), ^{
            self._snailImagePickerContrioller.selectedVideoBlock = block;

            UIImagePickerController *picker=[[UIImagePickerController alloc] init];
            picker.delegate = self._snailImagePickerContrioller;
            picker.allowsEditing = NO;
            picker.videoMaximumDuration = maxTime > 0 ? maxTime : 3600 * 24;
            picker.videoQuality = UIImagePickerControllerQualityTypeMedium; //视频质量
            picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", nil]; //媒体类型：@"public.movie" 为视频  @"public.image" 为图片
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;

            [self presentViewController:picker animated:YES completion:^{

            }];
        });

    }];

}

- (void)SnailOpenVideoRecord:(NSTimeInterval)time Block:(void (^)(NSURL *videoUrl ,UIImage *image ,NSTimeInterval time))block {

    [self _SnailCameraAuth:^{

        dispatch_async(dispatch_get_main_queue(), ^{
            self._snailImagePickerContrioller.selectedVideoBlock = block;

            UIImagePickerController *picker = [UIImagePickerController new];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;    //设置来源为摄像头
            picker.cameraDevice = UIImagePickerControllerCameraDeviceRear; //设置使用的摄像头为：后置摄像头
            picker.delegate = self._snailImagePickerContrioller;
            picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", nil];
            picker.videoQuality = UIImagePickerControllerQualityTypeMedium;   //设置视频质量
            picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            picker.allowsEditing = true;
            picker.videoMaximumDuration = time;
            [self presentViewController:picker animated:true completion:^{

            }];
        });

    }];

}

#pragma mark -

- (void)set_snailImagePickerContrioller:(SnailViewControllerImagePickerController *)_snailImagePickerContrioller {
    objc_setAssociatedObject(self, &SNAILVIEWCONTROLLERIMAGEPICKERCONTROLLER, _snailImagePickerContrioller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SnailViewControllerImagePickerController *)_snailImagePickerContrioller {
    
    SnailViewControllerImagePickerController *controller = objc_getAssociatedObject(self, &SNAILVIEWCONTROLLERIMAGEPICKERCONTROLLER);
    if (controller == nil) {
        controller = [SnailViewControllerImagePickerController new];
        [self set_snailImagePickerContrioller:controller];
    }
    return controller;
}

@end
