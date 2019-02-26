//
//  SnailImageCropController.h
//  QianXun
//
//  Created by JobNewMac1 on 2018/9/26.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(char ,SnailImageCropType) {
    SnailImageCropSquare,
    SnailImageCropCycle,
};

@interface SnailImageCropController : UIViewController

@property (nonatomic ,copy) UIImage *image;

@property (nonatomic) SnailImageCropType type;

@property (nonatomic) CGFloat scale; //square 时 宽高比
@property (nonatomic) BOOL canScaleFrame; //是否可以缩放裁剪框 默认yes

@property (nonatomic ,strong) void(^cropImageDoneBlock)(UIImage *cropImage);

@end
