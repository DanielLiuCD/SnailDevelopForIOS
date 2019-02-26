//
//  SnailTableAndCollectionVMCommon.h
//  SnailTCVM
//
//  Created by JobNewMac1 on 2018/12/10.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <UIKit/UIKit.h>

struct SnailScrollerTrackInfo {
    BOOL draging;
    BOOL inTargetRect;
};

typedef struct SnailScrollerTrackInfo SnailScrollerTrackInfo;

@interface SnailTCReg : NSObject

@property (nonatomic ,readonly) Class cls;
@property (nonatomic ,copy ,readonly) NSString *identifer;

+ (instancetype):(Class)cls :(NSString *)identifer;
+ (NSArray<SnailTCReg *> *)Clss:(NSArray<Class> *)clss Identifers:(NSArray<NSString *> *)identifers;

@end

@interface UITableViewCell(SnailTableAndCollectionVM)

@property (nonatomic) BOOL sna_isConfigureing; //用于记录是否是正在配置

@property (nonatomic) BOOL sna_have_configured; //用于记录是是配置过了,用户自己手动控制

- (void)snail_Configure:(__kindof id)model;

- (void)snail_setConfigureBlock:(void(^)(__kindof id model ,NSIndexPath *indexPath ,SnailScrollerTrackInfo info))block;

@end

@interface UICollectionViewCell(SnailTableAndCollectionVM)

@property (nonatomic) BOOL sna_isConfigureing;

@property (nonatomic) BOOL sna_have_configured; //用于记录是是配置过了,用户自己手动控制

- (void)snail_Configure:(__kindof id)model;

- (void)snail_setConfigureBlock:(void(^)(__kindof id model ,NSIndexPath *indexPath ,SnailScrollerTrackInfo info))block;

@end

@interface SnailTCPreprocessed : NSObject

@property (nonatomic ,copy) NSArray<__kindof id> *(^dataBlock)(void);
@property (nonatomic ,copy) void(^preprocessedBlock)(__kindof id model);
@property (nonatomic ,copy) void(^completeBlock)(NSArray<__kindof id> *datas);
@property (nonatomic ,readonly) BOOL isOpen;

- (void)resume;
- (void)stop;

@end
