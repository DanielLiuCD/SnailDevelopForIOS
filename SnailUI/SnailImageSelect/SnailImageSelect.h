//
//  SnailImageSelected.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/21.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger ,SnailImageSelectStyle) {
    SnailImageSelect_H,
    SnailImageSelect_V,
};

@interface SnailImageSelectModel : NSObject

@property (nonatomic ,strong ,readonly) UIImage *image;
@property (nonatomic ,strong ,readonly) NSString *imageName;
@property (nonatomic ,strong ,readonly) NSString *imagePath;
@property (nonatomic ,strong ,readonly) NSString *imageUrl;
@property (nonatomic ,strong) id extend;

+ (instancetype)Image:(UIImage *)image Name:(NSString *)name;
+ (instancetype)Image:(UIImage *)image Name:(NSString *)name Path:(NSString *)path;
+ (instancetype)Image:(UIImage *)image Name:(NSString *)name Url:(NSString *)url;
+ (instancetype)Image:(UIImage *)image Name:(NSString *)name Path:(NSString *)path Url:(NSString *)url;

@end


@interface SnailImageSelect : UIView

@property (nonatomic ,copy) void(^heightChangeBlock)(CGFloat hegiht);
@property (nonatomic ,copy) void(^configureImageBlock)(UIImageView *imv ,NSString *imageUrl);
@property (nonatomic ,copy) void(^selectAction)(void);
@property (nonatomic ,copy) void(^clickAction)(NSInteger index ,SnailImageSelectModel *imageModel);
@property (nonatomic ,copy) void(^deleteAction)(NSInteger index ,SnailImageSelectModel *imageModel);

+ (instancetype)Style:(SnailImageSelectStyle)style MaxNum:(NSInteger)maxNum ItemSize:(CGSize)itemSize Icon:(UIImage *)icon;

- (void)appendImages:(NSArray<SnailImageSelectModel *> *)images;

- (void)appendImages:(NSArray<SnailImageSelectModel *> *)images Animale:(BOOL)animale;

- (void)replaceAtIndex:(NSInteger)index Model:(SnailImageSelectModel *)model;

- (void)replaceAtIndex:(NSInteger)index Model:(SnailImageSelectModel *)model Animale:(BOOL)animale;

- (void)deleteAtIndex:(NSInteger)index;

- (void)deleteAtIndex:(NSInteger)index Animale:(BOOL)animale;

- (NSArray<SnailImageSelectModel *> *)takeSelectedImages;

@end
