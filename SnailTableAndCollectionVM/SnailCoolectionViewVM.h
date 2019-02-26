//
//  SnailCoolectionViewVM.h
//  SnailTCVM
//
//  Created by JobNewMac1 on 2018/12/10.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailTableAndCollectionVMCommon.h"

@interface SnailColReg : NSObject

@property (nonatomic ,readonly) Class cls;
@property (nonatomic ,copy ,readonly) NSString *identifer;
@property (nonatomic ,copy ,readonly) NSString *kind;

+ (instancetype):(Class)cls :(NSString *)identifer :(NSString *)kind;
+ (NSArray<SnailColReg *> *)Clss:(NSArray<Class> *)clss Identifers:(NSArray<NSString *> *)identifers Kinds:(NSArray<NSString *> *)kinds;

@end

@interface SnailCoolectionViewVM : NSObject

@property (nonatomic ,strong ,readonly) SnailTCPreprocessed *processed;

@property (nonatomic ,copy) NSInteger (^numberOfSection)(void);
@property (nonatomic ,copy) NSInteger (^numberOfRowsInSection)(NSInteger section , __kindof id sectionModel);

@property (nonatomic ,copy) __kindof id (^sectionModel)(NSInteger section);
@property (nonatomic ,copy) __kindof id (^supplementaryModel)(NSIndexPath *indexPath);
@property (nonatomic ,copy) __kindof id (^cellModel)(NSIndexPath *indexPath , __kindof id sectionModel);

@property (nonatomic ,copy) NSString *(^cellIdentifer)(NSIndexPath *indexPath ,__kindof id model);
@property (nonatomic ,copy) NSString *(^supplementaryIdentifer)(NSIndexPath *indexPath ,NSString *kind ,__kindof id model);

@property (nonatomic ,copy) UIEdgeInsets (^sectionInsets)(NSInteger section ,__kindof id model);

@property (nonatomic ,copy) CGSize (^cellSize)(NSIndexPath *indexPath ,__kindof id model);
@property (nonatomic ,copy) CGSize (^supplementaryHeaderSize)(NSInteger section, __kindof id sectionHeaderModel);
@property (nonatomic ,copy) CGSize (^supplementaryFooterSize)(NSInteger section, __kindof id sectionHeaderModel);

@property (nonatomic ,copy) CGFloat (^minimumInteritemSpacing)(NSInteger section ,__kindof id model);
@property (nonatomic ,copy) CGFloat (^minimumLineSpacing)(NSInteger section ,__kindof id model);

@property (nonatomic ,copy) void(^configureCell)(__kindof UICollectionViewCell *cell, NSIndexPath *indexPath ,__kindof id model ,SnailScrollerTrackInfo trackInfo);
@property (nonatomic ,copy) void(^configureSupplementary)(__kindof UICollectionReusableView *supView ,NSString *kind, NSIndexPath *indexPath, __kindof id model);

@property (nonatomic ,copy) void(^didSelectRow)(NSIndexPath *indexPath, __kindof id model, __kindof UICollectionViewCell *cell, NSIndexPath *lastSelectedIndexPath, __kindof id lastSelectedModel, __kindof UICollectionViewCell *lastCell);

@property (nonatomic ,copy) void(^didEndScroBlock)(UICollectionView *collection);

@property (nonatomic ,copy) void(^willDisplayIndexPaths)(NSArray<NSIndexPath *> *indexs);

- (instancetype)initWithCollectionView:(UICollectionView *)coll;

- (void)registeCells:(NSArray<SnailTCReg *> *(NS_NOESCAPE ^)(void))block;
- (void)registeHFeaders:(NSArray<SnailColReg *> *(NS_NOESCAPE ^)(void))block;

- (void)selectedAtIndexPath:(NSIndexPath *)indexPath;

- (void)configureAvailableCells;

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated NeedConfigure:(BOOL)configure;

- (void)reload;
- (void)reload:(void(NS_NOESCAPE ^)(void))block;

@end
