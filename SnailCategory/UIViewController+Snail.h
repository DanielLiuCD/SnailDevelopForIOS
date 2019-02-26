//
//  UIViewController+Snail.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/22.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -

@interface SnailRequestAlertAction : NSObject

@property (nonatomic ,copy ,readonly) NSString *title;
@property (nonatomic ,copy ,readonly) NSString *placeHolder;

+ (instancetype)Ttile:(NSString *)title PlaceHolder:(NSString *)placeHolder;

@end

#pragma mark -

@interface SnailResultTextAlertAction : NSObject

@property (nonatomic ,copy ,readonly) NSString *placeHolder;
@property (nonatomic ,copy ,readonly) NSString *text;

@end

#pragma mark -

@interface SnailResultAlertAction : NSObject

@property (nonatomic ,copy ,readonly) NSString *title;
@property (nonatomic ,copy ,readonly) NSArray<SnailResultTextAlertAction *> *texts;

@end

#pragma mark -

@interface SnailImageChooseImageModel : NSObject

@property (nonatomic ,copy ,readonly) UIImage *image;
@property (nonatomic ,copy ,readonly) NSString *imageName;
@property (nonatomic ,copy ,readonly) NSString *imagePath;

@end

@interface SnailImageChooseResult : NSObject

@property (nonatomic ,strong ,readonly) SnailImageChooseImageModel *original;
@property (nonatomic ,strong ,readonly) SnailImageChooseImageModel *edit;

@end

typedef NS_ENUM(char,SnailImageChooseEditType) {
    SnailImageChooseEditNone,
    SnailImageChooseEditSystem,
};

typedef NS_ENUM(char,SnailImageChooseCompressType) {
    SnailImageChooseCompressNone,
    SnailImageChooseCompressQuality,
    SnailImageChooseCompressSize,
    /// max size 1280
    SnailImageChooseCompressAuto,
};

@interface SnailImageChooseRequest : NSObject

@property (nonatomic) SnailImageChooseEditType edit;
@property (nonatomic) BOOL path;
@property (nonatomic) SnailImageChooseCompressType compress;

@property (nonatomic) CGSize compressSize;
@property (nonatomic) CGFloat compressQuality;
@property (nonatomic) NSInteger compressMaxSize;

@end

typedef void(^SnailImageChooseResultBlock)(SnailImageChooseResult *result);

#pragma mark -

@interface UIViewController (Snail)

#pragma mark -

- (void)SnailAlertTitle:(NSString *)title Message:(NSString *)message Actions:(NSArray<SnailRequestAlertAction *> *)actions Block:(void(^)(SnailResultAlertAction *result,NSInteger index))block;

- (void)SnailSheetTitle:(NSString *)title Message:(NSString *)message Actions:(NSArray<SnailRequestAlertAction *> *)actions Block:(void(^)(SnailResultAlertAction *result,NSInteger index))block;

#pragma mark -

- (void)SnailOpenImagePickerController:(SnailImageChooseResultBlock)block;
- (void)SnailOpenImagePickerControllerNoEdit:(SnailImageChooseResultBlock)block;

- (void)SnailOpenImagePickerControllerAutoCompress:(SnailImageChooseResultBlock)block;
- (void)SnailOpenImagePickerControllerNoEditAutoCompress:(SnailImageChooseResultBlock)block;

- (void)SnailOpenCamera:(SnailImageChooseResultBlock)block;
- (void)SnailOpenCameraNoEdit:(SnailImageChooseResultBlock)block;

- (void)SnailOpenCameraAutoCompress:(SnailImageChooseResultBlock)block;
- (void)SnailOpenCameraNoEditAutoCompress:(SnailImageChooseResultBlock)block;

- (void)SnailOpenCameraWithPath:(SnailImageChooseResultBlock)block;
- (void)SnailOpenCameraWithPathNoEdit:(SnailImageChooseResultBlock)block;

- (void)SnailOpenCameraWithPathAutoCompress:(SnailImageChooseResultBlock)block;
- (void)SnailOpenCameraWithPathNoEditAutoCompress:(SnailImageChooseResultBlock)block;

- (void)SnailOpenImageChoose:(SnailImageChooseResultBlock)block;
- (void)SnailOpenImageChooseNoEdit:(SnailImageChooseResultBlock)block;

- (void)SnailOpenImageChooseAutoCompress:(SnailImageChooseResultBlock)block;
- (void)SnailOpenImageChooseNoEditAutoCompress:(SnailImageChooseResultBlock)block;

- (void)SnailOpenImageChooseRequest:(SnailImageChooseRequest *)request Block:(SnailImageChooseResultBlock)block;

- (void)SnailOpenVideoChoose:(NSTimeInterval)maxTime Block:(void (^)(NSURL *videoUrl ,UIImage *image ,NSTimeInterval time))block;

- (void)SnailOpenVideoRecord:(NSTimeInterval)time Block:(void (^)(NSURL *videoUrl ,UIImage *image ,NSTimeInterval time))block;

@end
