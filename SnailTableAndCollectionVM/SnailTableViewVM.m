//
//  SnailTableViewVM.m
//  SnailTCVM
//
//  Created by JobNewMac1 on 2018/12/10.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailTableViewVM.h"
#import <objc/runtime.h>

@interface SnailTableViewVM()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,weak) UITableView *tab;

@property (nonatomic ,strong) NSIndexPath *lastSelectedIndexPath;

@property (nonatomic) BOOL userDraging; //记录用户是否在拖动
@property (nonatomic ,strong) NSMutableSet *targetIndexPaths;
@property (nonatomic ,strong) NSLock *lock;

@property (nonatomic ,strong) SnailTCPreprocessed *processed;

@property (nonatomic) BOOL isFirstReload;

@end

@implementation SnailTableViewVM

- (void)sna_add:(SEL)selector OriSel:(SEL)ori_selector {
    
    Method sna_method = class_getInstanceMethod(self.class, selector);
    IMP sna_imp = method_getImplementation(sna_method);
    const char *types = method_getTypeEncoding(sna_method);
    BOOL addSuccess = class_addMethod(self.class, ori_selector, sna_imp, types);
#ifdef DEBUG
    if (addSuccess) {
        NSLog(@"方法添加成功: %@",NSStringFromSelector(ori_selector));
    }
#endif
    
}


- (instancetype)initWithTableview:(UITableView *)tab {
    self = [super init];
    if (self) {
        self.tab = tab;
        if (self.tab.tableFooterView == nil) self.tab.tableFooterView = UIView.new;
        if (@available(iOS 11.0, *)) {
            [self sna_add:@selector(sna_tableView:estimatedHeightForRowAtIndexPath:) OriSel:@selector(tableView:estimatedHeightForRowAtIndexPath:)];
            [self sna_add:@selector(sna_tableView:estimatedHeightForHeaderInSection:) OriSel:@selector(tableView:estimatedHeightForHeaderInSection:)];
            [self sna_add:@selector(sna_tableView:estimatedHeightForFooterInSection:) OriSel:@selector(tableView:estimatedHeightForFooterInSection:)];
        }
        [self refeshTabProtocol];
    }
    return self;
}

- (void)refeshTabProtocol {
    self.tab.delegate = self;
    self.tab.dataSource = self;
}

- (void)registeCells:(NSArray<SnailTCReg *> *(NS_NOESCAPE ^)(void))block {
    NSArray<SnailTCReg *> *tmp = block();
    [tmp enumerateObjectsUsingBlock:^(SnailTCReg * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.tab registerClass:obj.cls forCellReuseIdentifier:obj.identifer];
    }];
}

- (void)registeHFeaders:(NSArray<SnailTCReg *> *(NS_NOESCAPE ^)(void))block {
    NSArray<SnailTCReg *> *tmp = block();
    [tmp enumerateObjectsUsingBlock:^(SnailTCReg * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.tab registerClass:obj.cls forHeaderFooterViewReuseIdentifier:obj.identifer];
    }];
}

- (id)_takeRowModel:(NSIndexPath *)indexPath {
    if (indexPath && self.rowModel) {
        id sectionModel = nil;
        if (self.sectionModel) sectionModel = self.sectionModel(indexPath.section);
        return self.rowModel(indexPath,sectionModel);
    }
    return nil;
}

- (id)_takeFooterModel:(NSInteger)section {
    if (self.footerModel) return self.footerModel(section);
    return nil;
}

- (id)_takeHeaderModel:(NSInteger)section {
    if (self.headerModel) return self.headerModel(section);
    return nil;
}

- (void)reload {
    [self reload:nil];
}

- (void)reload:(void (NS_NOESCAPE ^)(void))completeBlock {
    [CATransaction begin];
    [self.tab reloadData];
    [CATransaction setCompletionBlock:^{
        if (!self.isFirstReload) {
            [self _configureAvaulableCells];
            self.isFirstReload = true;
        }
        if (completeBlock) completeBlock();
    }];
    [CATransaction commit];
}

- (void)update:(void (NS_NOESCAPE ^)(void))block {
    [self.tab beginUpdates];
    if (block) block();
    [self.tab endUpdates];
}

- (void)update:(void (NS_NOESCAPE ^)(void))block Com:(void (NS_NOESCAPE ^)(void))comBlock {
    [self update:block];
    if (comBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            comBlock();
        });
    }
}

- (void)takeCellIndexPath:(UITableViewCell *)cell Block:(void (NS_NOESCAPE ^)(UITableViewCell *, NSIndexPath *, __kindof id))block {
    if (block){
        NSIndexPath *indexPath = [self.tab indexPathForCell:cell];
        id model = [self _takeRowModel:indexPath];
        block(cell,indexPath,model);
    }
}

- (void)takeIndexPathCell:(NSIndexPath *)indexPath Block:(void (NS_NOESCAPE ^)(UITableViewCell *, NSIndexPath *, __kindof id))block {
    if (block) {
        UITableViewCell *cell = [self.tab cellForRowAtIndexPath:indexPath];
        id model = [self _takeRowModel:indexPath];
        block(cell,indexPath,model);
    }
}

- (void)selectedAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectRow) {
        self.didSelectRow(indexPath, [self _takeRowModel:indexPath], [self.tab cellForRowAtIndexPath:indexPath], self.lastSelectedIndexPath, [self _takeRowModel:self.lastSelectedIndexPath], [self.tab cellForRowAtIndexPath:self.lastSelectedIndexPath]);
    }
    self.lastSelectedIndexPath = indexPath;
}

- (NSIndexPath *)takeCurrentSelectedIndexPath {
    return self.lastSelectedIndexPath;
}

- (void)configureAvailableCells {
    [self _configureAvaulableCells];
}

- (void)_configureAvaulableCells {
    
    NSArray<UITableViewCell *> *cells = [self.tab visibleCells];
    [cells enumerateObjectsUsingBlock:^(UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = [self.tab indexPathForCell:obj];
        id model = [self _takeRowModel:indexPath];
        [self _configureCell:obj :indexPath :model :true];
    }];
    
}

- (void)_configureCell:(UITableViewCell *)cell :(NSIndexPath *)indexPath :(__kindof id)model :(BOOL)isInTargetRect {
    
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

#pragma mark -

- (NSLock *)lock {
    if (!_lock) _lock = [NSLock new];
    return _lock;
}

- (SnailTCPreprocessed *)processed {
    if (!_processed) _processed = [SnailTCPreprocessed new];
    return _processed;
}

- (void)setEditActionsBlock:(NSArray<UITableViewRowAction *> *(^)(NSIndexPath *, __kindof id))editActionsBlock {
    _editActionsBlock = editActionsBlock;
    if (![self respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)]) {
        [self sna_add:@selector(sna_tableView:editActionsForRowAtIndexPath:) OriSel:@selector(tableView:editActionsForRowAtIndexPath:)];
    }
    [self refeshTabProtocol];
}

- (void)setCanEditBlock:(BOOL (^)(NSIndexPath *, __kindof id))canEditBlock {
    _canEditBlock = canEditBlock;
    if (![self respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        [self sna_add:@selector(sna_tableView:canEditRowAtIndexPath:) OriSel:@selector(tableView:canEditRowAtIndexPath:)];
    }
    [self refeshTabProtocol];
}

#pragma mark -

- (void)dealloc {
    if (self.processed.isOpen) [self.processed stop];
}

#pragma mark -

- (void)handleProcessedScro {
    [self _scrollViewDidScroll:self.tab];
}

- (void)_scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGRect current = CGRectMake(scrollView.contentOffset.x, scrollView.contentOffset.y, scrollView.bounds.size.width, scrollView.bounds.size.height);
    CGRect topVisiableRect = CGRectOffset(current, 0, -scrollView.bounds.size.height);
    CGRect bottomVisiableRect = CGRectOffset(current, 0, scrollView.bounds.size.height);
    
    NSArray *topIndexs = [self.tab indexPathsForRowsInRect:topVisiableRect];
    NSArray *bottomIndexs = [self.tab indexPathsForRowsInRect:bottomVisiableRect];
    
    NSInteger topCount = topIndexs.count;
    while (topCount < 10) {
        topVisiableRect.origin.y -= scrollView.bounds.size.height;
        topVisiableRect.size.height += scrollView.bounds.size.height;
        topIndexs = [self.tab indexPathsForRowsInRect:topVisiableRect];
        if (topIndexs.count == topCount) break;
        topCount = topIndexs.count;
    }
    
    NSInteger bottomCount = bottomIndexs.count;
    while (bottomCount < 10) {
        bottomVisiableRect.size.height += scrollView.bounds.size.height;
        bottomIndexs = [self.tab indexPathsForRowsInRect:bottomVisiableRect];
        if (bottomIndexs.count == bottomCount) break;
        bottomCount = bottomIndexs.count;
    }
    
    NSMutableArray *tmps = [NSMutableArray new];
    [tmps addObjectsFromArray:topIndexs];
    [tmps addObjectsFromArray:bottomIndexs];
    
    self.willDisplayIndexPaths(tmps);
    
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
    
    NSMutableSet *tmpSet = [NSMutableSet new];
    NSArray *tmps = [self.tab indexPathsForRowsInRect:finalRect];
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
    if (self.processed.isOpen && self.willDisplayIndexPaths) { //进行预处理,预先处理前后一屏的数据
        [self handleProcessedScro];
    }
}

#pragma mark -

- (NSArray<UITableViewRowAction *> *)sna_tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editActionsBlock) {
        NSArray *tmp = self.editActionsBlock(indexPath,[self _takeRowModel:indexPath]);
        return tmp;
    }
    return nil;
}

- (BOOL)sna_tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.canEditBlock) {
        return self.canEditBlock(indexPath,[self _takeRowModel:indexPath]);
    }
    return false;
}

- (CGFloat)sna_tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)sna_tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section {
    return [self tableView:tableView heightForFooterInSection:section];
}

- (CGFloat)sna_tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return [self tableView:tableView heightForHeaderInSection:section];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.numberOfSection) return self.numberOfSection();
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.numberOfRowsInSection && tableView.numberOfSections) {
        id model = nil;
        if (self.sectionModel) model = self.sectionModel(section);
        return self.numberOfRowsInSection(section, model);
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.rowHeight) {
        id rowModel = [self _takeRowModel:indexPath];
        return self.rowHeight(indexPath,rowModel);
    }
    return 50.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.headerHeight) {
        id headerModel = [self _takeHeaderModel:section];
        return self.headerHeight(section, headerModel);
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.footerHeight) {
        id footerModel = [self _takeFooterModel:section];
        return self.footerHeight(section, footerModel);
    }
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = [self _takeRowModel:indexPath];
    NSString *identifer = nil;
    if (self.cellIdentifer) identifer = self.cellIdentifer(indexPath ,model);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        if (self.createCell) cell = self.createCell(indexPath,identifer,model);
    }
    if (cell) {
        BOOL inTargetRect = self.targetIndexPaths && [self.targetIndexPaths containsObject:indexPath];
        [self _configureCell:cell :indexPath :model :inTargetRect];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    id model = [self _takeHeaderModel:section];
    NSString *identifer = nil;
    if (self.headerIdentifer) identifer = self.headerIdentifer(section ,model);
    UIView *vi = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifer];
    if (!vi) {
        if (self.createHeader) vi = self.createHeader(section,identifer,model);
    }
    if (!vi) {
        UITableViewHeaderFooterView *hf = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:identifer];
        hf.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        vi = hf;
    }
    if (self.configureHeader) {
        self.configureHeader(vi, section, nil);
    }
    return vi;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    id model = [self _takeFooterModel:section];
    NSString *identifer = nil;
    if (self.footerIdentifer) identifer = self.footerIdentifer(section ,model);
    UIView *vi = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifer];
    if (!vi) {
        if (self.createFooter) vi = self.createFooter(section,identifer,model);
    }
    if (!vi) {
        UITableViewHeaderFooterView *hf = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:identifer];
        hf.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        vi = hf;
    }
    if (self.configureFooter) {
        self.configureFooter(vi, section, nil);
    }
    return vi;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self selectedAtIndexPath:indexPath];
    });
}

@end
