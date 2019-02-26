//
//  SnailTableViewVM.h
//  SnailTCVM
//
//  Created by JobNewMac1 on 2018/12/10.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailTableAndCollectionVMCommon.h"

@interface SnailTableViewVM : NSObject

@property (nonatomic ,strong ,readonly) SnailTCPreprocessed *processed;  //进行简单的预处理,可以预处理前后一屏的数据

@property (nonatomic ,copy) NSInteger (^numberOfSection)(void);
@property (nonatomic ,copy) NSInteger (^numberOfRowsInSection)(NSInteger section , __kindof id sectionModel);

@property (nonatomic ,copy) __kindof id (^sectionModel)(NSInteger section);
@property (nonatomic ,copy) __kindof id (^headerModel)(NSInteger section);
@property (nonatomic ,copy) __kindof id (^footerModel)(NSInteger section);
@property (nonatomic ,copy) __kindof id (^rowModel)(NSIndexPath *indexPath , __kindof id sectionModel);

@property (nonatomic ,copy) CGFloat (^rowHeight)(NSIndexPath *indexPath ,__kindof id model);
@property (nonatomic ,copy) CGFloat (^headerHeight)(NSInteger section, __kindof id sectionHeaderModel);
@property (nonatomic ,copy) CGFloat (^footerHeight)(NSInteger section ,__kindof id sectionFooterModel);

@property (nonatomic ,copy) UITableViewCell *(^createCell)(NSIndexPath *indexPath, NSString *dequeueIdentifer ,__kindof id model);
@property (nonatomic ,copy) UIView *(^createHeader)(NSInteger section, NSString *dequeueIdentifer ,__kindof id model);
@property (nonatomic ,copy) UIView *(^createFooter)(NSInteger section, NSString *dequeueIdentifer ,__kindof id model);

@property (nonatomic ,copy) void(^configureCell)(__kindof UITableViewCell *cell, NSIndexPath *indexPath ,__kindof id model ,SnailScrollerTrackInfo trackInfo);
@property (nonatomic ,copy) void(^configureHeader)(__kindof UIView *header, NSInteger section, __kindof id model);
@property (nonatomic ,copy) void(^configureFooter)(__kindof UIView *footer, NSInteger section, __kindof id model);

@property (nonatomic ,copy) NSString *(^cellIdentifer)(NSIndexPath *indexPath ,__kindof id model);
@property (nonatomic ,copy) NSString *(^headerIdentifer)(NSInteger section ,__kindof id model);
@property (nonatomic ,copy) NSString *(^footerIdentifer)(NSInteger section ,__kindof id model);

@property (nonatomic ,copy) void(^didSelectRow)(NSIndexPath *indexPath, __kindof id model, __kindof UITableViewCell *cell, NSIndexPath *lastSelectedIndexPath, __kindof id lastSelectedModel, __kindof UITableViewCell *lastCell);

@property (nonatomic ,copy) NSArray<UITableViewRowAction *> *(^editActionsBlock)(NSIndexPath *indexPath,__kindof id model);
@property (nonatomic ,copy) BOOL(^canEditBlock)(NSIndexPath *indexPath,__kindof id model);

@property (nonatomic ,copy) void(^willDisplayIndexPaths)(NSArray<NSIndexPath *> *indexs);

- (void)reload;
- (void)reload:(void(NS_NOESCAPE ^)(void))completeBlock;

- (void)update:(void(NS_NOESCAPE ^)(void))block;
- (void)update:(void(NS_NOESCAPE ^)(void))block Com:(void(NS_NOESCAPE ^)(void))comBlock;

- (instancetype)initWithTableview:(UITableView *)tab;

- (void)registeCells:(NSArray<SnailTCReg *> *(NS_NOESCAPE ^)(void))block;
- (void)registeHFeaders:(NSArray<SnailTCReg *> *(NS_NOESCAPE ^)(void))block;

- (void)takeCellIndexPath:(UITableViewCell *)cell Block:(void(NS_NOESCAPE ^)(UITableViewCell *cell ,NSIndexPath *indexPath, __kindof id model))block;
- (void)takeIndexPathCell:(NSIndexPath *)indexPath Block:(void(NS_NOESCAPE ^)(UITableViewCell *cell ,NSIndexPath *indexPath, __kindof id model))block;

- (void)selectedAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)takeCurrentSelectedIndexPath;

- (void)configureAvailableCells;

@end
