//
//  SnailCoolectionViewVM.m
//  SnailTCVM
//
//  Created by JobNewMac1 on 2018/12/10.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailCoolectionViewVM.h"
#import <objc/runtime.h>

@interface SnailColReg()

@property (nonatomic) Class cls;
@property (nonatomic ,copy) NSString *identifer;
@property (nonatomic ,copy) NSString *kind;

@end

@implementation SnailColReg

+ (instancetype):(Class)cls :(NSString *)identifer :(NSString *)kind {
    SnailColReg *reg = [SnailColReg new];
    reg.cls = cls;
    reg.identifer = identifer;
    reg.kind = kind;
    return reg;
}

+ (NSArray<SnailColReg *> *)Clss:(NSArray<Class> *)clss Identifers:(NSArray<NSString *> *)identifers Kinds:(NSArray<NSString *> *)kinds {
    NSMutableArray *tmps = [NSMutableArray new];
    [clss enumerateObjectsUsingBlock:^(Class obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tmps addObject:[self :obj :identifers[idx] :kinds[idx]]];
    }];
    return tmps;
}

@end

@interface SnailCoolectionViewVM()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic ,weak) UICollectionView *coll;

@property (nonatomic ,strong) NSIndexPath *lastSelectedIndexPath;

@property (nonatomic) BOOL userDraging; //记录用户是否在拖动
@property (nonatomic ,strong) NSMutableSet *targetIndexPaths;
@property (nonatomic ,strong) SnailTCPreprocessed *processed;

@property (nonatomic) BOOL isFirstReload;

@end

@implementation SnailCoolectionViewVM

- (instancetype)initWithCollectionView:(UICollectionView *)coll {
    self = [super init];
    if (self) {
        self.coll = coll;
        self.coll.delegate = self;
        self.coll.dataSource = self;
    }
    return self;
}

- (void)registeCells:(NSArray<SnailTCReg *> *(^)(void))block {
    if (block) {
        NSArray<SnailTCReg *> *tmps = block();
        [tmps enumerateObjectsUsingBlock:^(SnailTCReg * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.coll registerClass:obj.cls forCellWithReuseIdentifier:obj.identifer];
        }];
    }
}

- (void)registeHFeaders:(NSArray<SnailColReg *> *(^)(void))block {
    if (block) {
        NSArray<SnailColReg *> *tmps = block();
        [tmps enumerateObjectsUsingBlock:^(SnailColReg * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.coll registerClass:obj.cls forSupplementaryViewOfKind:obj.kind withReuseIdentifier:obj.identifer];
        }];
    }
}

- (void)selectedAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectRow) {
        self.didSelectRow(indexPath, [self _takeCellModel:indexPath], [self.coll cellForItemAtIndexPath:indexPath], self.lastSelectedIndexPath, [self _takeCellModel:self.lastSelectedIndexPath], [self.coll cellForItemAtIndexPath:self.lastSelectedIndexPath]);
    }
    self.lastSelectedIndexPath = indexPath;
}

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated NeedConfigure:(BOOL)configure {
    
    if (configure) {
        [CATransaction begin];
        [self.coll scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
        [CATransaction setCompletionBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self _configureAvaulableCells];
            });
        }];
        [CATransaction commit];
    }
    else {
        [self.coll scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
    }
}

- (id)_takeSectionModel:(NSInteger)section {
    if (self.sectionModel) return self.sectionModel(section);
    return nil;
}

- (id)_takeCellModel:(NSIndexPath *)indexPath {
    if (self.cellModel) return self.cellModel(indexPath,[self _takeSectionModel:indexPath.section]);
    return nil;
}

- (id)_takeSupplementaryModel:(NSIndexPath *)indexPath {
    if (self.supplementaryModel) return self.supplementaryModel(indexPath);
    return nil;
}

- (void)configureAvailableCells {
    [self _configureAvaulableCells];
}

- (void)_configureAvaulableCells {
    
    NSArray<UICollectionViewCell *> *cells = [self.coll visibleCells];
    [cells enumerateObjectsUsingBlock:^(UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = [self.coll indexPathForCell:obj];
        id model = [self _takeCellModel:indexPath];
        [self _configureCell:obj :indexPath :model :true];
    }];
    
}

- (void)_configureCell:(UICollectionViewCell *)cell :(NSIndexPath *)indexPath :(__kindof id)model :(BOOL)isInTargetRect {
    
    if (cell.sna_have_configured) return;
    cell.sna_isConfigureing = true;
    if (self.configureCell) {
        BOOL inTargetRect = isInTargetRect;
        BOOL draging = self.userDraging;
        SnailScrollerTrackInfo info = (SnailScrollerTrackInfo){.draging= draging ,inTargetRect=inTargetRect};
        void(^block)(__kindof id model ,NSIndexPath *indexPath ,SnailScrollerTrackInfo info) = objc_getAssociatedObject(cell, @selector(snail_setConfigureBlock:));
        if (block) block(model,indexPath,info);
        self.configureCell(cell, indexPath, model, info);
    }
    cell.sna_isConfigureing = false;
}

- (void)reload {
    [self reload:nil];
}

- (void)reload:(void (^)(void))completeBlock {
    [CATransaction begin];
    [self.coll reloadData];
    [CATransaction setCompletionBlock:^{
        if (!self.isFirstReload) {
            [self _configureAvaulableCells];
            self.isFirstReload = true;
        }
        if (completeBlock) completeBlock();
    }];
    [CATransaction commit];
}

#pragma mark -

- (SnailTCPreprocessed *)processed {
    if (!_processed) _processed = [SnailTCPreprocessed new];
    return _processed;
}

#pragma mark -

- (void)dealloc {
    if (self.processed.isOpen) [self.processed stop];
}

#pragma mark -

- (NSArray<NSIndexPath *> *)takeIndexPathsFromeRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *tmps = [self.coll.collectionViewLayout layoutAttributesForElementsInRect:rect];
    
    NSMutableArray *tmpIndexs = [NSMutableArray new];
    [tmps enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tmpIndexs addObject:obj.indexPath];
    }];
    return tmpIndexs.copy;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.processed.isOpen && self.willDisplayIndexPaths) {
        
        CGRect current = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.bounds.size.width, scrollView.bounds.size.height);
        CGRect topVisiableRect = CGRectOffset(current, 0, -scrollView.bounds.size.height);
        CGRect bottomVisiableRect = CGRectOffset(current, 0, scrollView.bounds.size.height);
        
        NSArray *topIndexs = [self takeIndexPathsFromeRect:topVisiableRect];
        NSArray *bottomIndexs = [self takeIndexPathsFromeRect:bottomVisiableRect];
        
        NSInteger topCount = topIndexs.count;
        while (topCount < 10) {
            topVisiableRect.origin.y -= scrollView.bounds.size.height;
            topVisiableRect.size.height += scrollView.bounds.size.height;
            topIndexs = [self takeIndexPathsFromeRect:topVisiableRect];
            if (topIndexs.count == topCount) break;
            topCount = topIndexs.count;
        }
        
        NSInteger bottomCount = bottomIndexs.count;
        while (bottomCount < 10) {
            bottomVisiableRect.size.height += scrollView.bounds.size.height;
            bottomIndexs = [self takeIndexPathsFromeRect:bottomVisiableRect];
            if (bottomIndexs.count == bottomCount) break;
            bottomCount = bottomIndexs.count;
        }
        
        NSMutableArray *tmps = [NSMutableArray new];
        [tmps addObjectsFromArray:topIndexs];
        [tmps addObjectsFromArray:bottomIndexs];
        
        self.willDisplayIndexPaths(tmps);
        
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.userDraging = true;
    self.targetIndexPaths = nil;
    [self _configureAvaulableCells];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    CGFloat y = targetContentOffset->y - 100;
    CGFloat height = scrollView.bounds.size.height + 200;
    CGRect finalRect = CGRectMake(targetContentOffset->x, y, scrollView.bounds.size.width, height);
    NSLog(@"%@",NSStringFromCGRect(finalRect));
    
    NSMutableSet *tmpSet = [NSMutableSet new];
    NSArray *tmps = [self takeIndexPathsFromeRect:finalRect];
    
    [tmpSet addObjectsFromArray:tmps];
    self.targetIndexPaths = tmpSet;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.userDraging = false;
    if (!decelerate) [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.targetIndexPaths = nil;
    [self _configureAvaulableCells];
    if (self.didEndScroBlock) self.didEndScroBlock(self.coll);
}

#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.numberOfSection) return self.numberOfSection();
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.numberOfRowsInSection) {
        return self.numberOfRowsInSection(section, [self _takeSectionModel:section]);
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id model = [self _takeCellModel:indexPath];
    NSString *identifer = nil;
    if (self.cellIdentifer) {
        identifer = self.cellIdentifer(indexPath,model);
    }
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifer forIndexPath:indexPath];
    BOOL inTarget = self.targetIndexPaths && [self.targetIndexPaths containsObject:indexPath];
    [self _configureCell:cell :indexPath :model :inTarget];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    id model = [self _takeSupplementaryModel:indexPath];
    NSString *identifer = nil;
    if (self.supplementaryIdentifer) {
        identifer = self.supplementaryIdentifer(indexPath,kind,model);
    }
    UICollectionReusableView *vi = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifer forIndexPath:indexPath];
    if (self.configureSupplementary) {
        self.configureSupplementary(vi, kind, indexPath, model);
    }
    return vi;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self selectedAtIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.sectionInsets) return self.sectionInsets(section,[self _takeSectionModel:section]);
    return UIEdgeInsetsZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellSize) return self.cellSize(indexPath, [self _takeCellModel:indexPath]);
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.supplementaryHeaderSize) return self.supplementaryHeaderSize(section, [self _takeSectionModel:section]);
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (self.supplementaryFooterSize) return self.supplementaryFooterSize(section, [self _takeSectionModel:section]);
    return CGSizeZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (self.minimumLineSpacing) {
        return self.minimumLineSpacing(section,[self _takeSectionModel:section]);
    }
    return CGFLOAT_MIN;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (self.minimumInteritemSpacing) {
        return self.minimumInteritemSpacing(section,[self _takeSectionModel:section]);
    }
    return CGFLOAT_MIN;
}



@end
