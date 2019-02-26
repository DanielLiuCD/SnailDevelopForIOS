//
//  SnailCameraDefaultController.h
//  SnailCamera
//
//  Created by JobNewMac1 on 2018/9/4.
//  Copyright © 2018年 com.snail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnailCameraHeader.h"

typedef NS_ENUM(char , SnailCameraDefaultControllerMode) {
    SnailCameraDefaultControllerDefault,
    SnailCameraDefaultControllerPhoto, //只能拍照
    SnailCameraDefaultControllerMovie, //只能录像
};

typedef void(^SnailCameraDefaultControllerFaceBlock)(NSArray<UIImage *> *faces,NSArray<NSString *> *faceNames);

@interface SnailCameraDefaultController : UIViewController

@property (nonatomic) SnailCameraDefaultControllerMode mode;

@property (nonatomic ,copy) SnailCameraErrorCallbacks cameraErrorBlock;
@property (nonatomic ,copy) SnailCameraPhotoCallbacks cameraImageBlock;
@property (nonatomic ,copy) SnailCameraMovieCallbacks cameraMovieBlock;

@end

@interface SnailCameraDefaultController(Movie)

@property (nonatomic) NSInteger maxMovieTime; //默认60秒
@property (nonatomic) NSInteger minMovieTime; //最少5秒

@end

@interface SnailCameraDefaultController(FACE)

@property (nonatomic) BOOL enableFace;
@property (nonatomic ,copy) SnailCameraDefaultControllerFaceBlock faceBlock; //only for Photo
@property (nonatomic ,copy) UIColor *faceBorderColor;
@property (nonatomic) UIEdgeInsets faceFixInsets;

@end
