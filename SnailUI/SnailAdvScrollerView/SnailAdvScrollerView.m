//
//  SnailAdvScrollerView.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/9/13.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import "SnailAdvScrollerView.h"
#import <objc/runtime.h>

#define SNA_ADV_DEBUG @"SNA_ADV_DEBUG"

@interface SnailAdvScrollerAdvShowView()

#ifdef SNA_ADV_DEBUG
kSPrStrong(UILabel *debug_num_lbl)
#endif

@end

@implementation SnailAdvScrollerAdvShowView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageView = [UIImageView new];
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
#ifdef SNA_ADV_DEBUG
        self.debug_num_lbl = [UILabel new];
        self.debug_num_lbl.hidden = false;
        self.debug_num_lbl.textAlignment = NSTextAlignmentCenter;
        self.debug_num_lbl.font = [UIFont systemFontOfSize:30];
        self.debug_num_lbl.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3];
        [self addSubview:self.debug_num_lbl];
        [self.debug_num_lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
#endif
    }
    return self;
}

@end

@interface SnailAdvScrollerView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

kSPrStrong(id middleTarget)

kSPrStrong(UICollectionViewFlowLayout *flow)
kSPrStrong(UICollectionView *coll);
kSPrStrong(NSTimer *timer)
kSPr(NSInteger currentPage)
kSPr(NSInteger truePage)

kSPr(NSInteger totalCount)

kSPr(BOOL isPause)

@end

@implementation SnailAdvScrollerView

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.flow = [[UICollectionViewFlowLayout alloc] init];
        self.flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.flow.minimumLineSpacing = 0.0;
        self.flow.minimumInteritemSpacing = 0.0;
        
        self.coll = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flow];
        [self.coll registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"c"];
        self.coll.delegate = self;
        self.coll.dataSource = self;
        self.coll.pagingEnabled = true;
        self.coll.backgroundColor = [UIColor clearColor];
        self.coll.showsVerticalScrollIndicator = false;
        self.coll.showsHorizontalScrollIndicator = false;
        
        [self addSubview:self.coll];
        
        [self.coll mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)reload {
    
    self.totalCount = self.advCountBlock();
    if (self.totalCount < 0) self.totalCount = 0;
    self.currentPage = 0;
    self.truePage = 0;
    self.isPause = false;
    if (self.totalCount == 0) [self stopTimer];
    else {
        self.totalCount += 2;
        [self.coll reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.coll scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:false];
            [self startTimer];
        });
    }

}

- (void)startTimer {
    
    if (self.isPause) return;
    
    [self stopTimer];
    
    NSTimeInterval time = 1.5;
    if (self.timeSpaceingBlock) time = self.timeSpaceingBlock();
    if (time <= 0) return;
    
    self.middleTarget = [NSObject new];
    
    self.timer = [NSTimer timerWithTimeInterval:time target:self.middleTarget selector:@selector(timerAction) userInfo:nil repeats:true];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    class_addMethod([self.middleTarget class], @selector(timerAction), (IMP)_timerAction, "v@:");
    objc_setAssociatedObject(self.middleTarget, @selector(timerAction), self, OBJC_ASSOCIATION_ASSIGN);
    
}

void _timerAction(id self,SEL _cmd) {
    SnailAdvScrollerView *view = objc_getAssociatedObject(self, @selector(timerAction));
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Warc-performSelector-leaks"
    [view performSelector:_cmd];
#pragma clang disgnostic pop
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
    self.middleTarget = nil;
}

- (void)timerAction {
    
    if (self.currentPage + 1 > self.totalCount - 1) {
        [self.coll scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
    else {
        [self.coll scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentPage + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
    
}

- (void)pause {
    [self stopTimer];
    self.isPause = true;
}

- (void)resume {
    if (self.isPause) {
        self.isPause = false;
        [self startTimer];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.bounds.size;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.totalCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"c" forIndexPath:indexPath];
    if (![cell.contentView viewWithTag:-1]) {
        SnailAdvScrollerAdvShowView *view = [SnailAdvScrollerAdvShowView new];
        view.tag = -1;
        [cell.contentView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView);
        }];
    }
    SnailAdvScrollerAdvShowView *view = [cell.contentView viewWithTag:-1];
    if (self.configureAdvBlock) {
        
        NSInteger showIndex = 0;
        if (indexPath.row == 0) {
            showIndex = self.totalCount - 2 - 1;
        }
        else if (indexPath.row == self.totalCount - 1) {
            showIndex = 0;
        }
        else showIndex = indexPath.row - 1;
        
#ifdef SNA_ADV_DEBUG
       NSLog(@"showIndex:%ld row:%ld",(long)showIndex,(long)indexPath.row);
#endif
        self.configureAdvBlock(view, showIndex);
        
    }
#ifdef SNA_ADV_DEBUG
    view.debug_num_lbl.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
#endif
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectItemAtIndexBlock) {
        if (indexPath.row >= self.totalCount - 2) self.didSelectItemAtIndexBlock(indexPath.row - 2);
        else self.didSelectItemAtIndexBlock(indexPath.row);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.totalCount <= 0) {
        return;
    }
    
    NSInteger index = scrollView.contentOffset.x / self.bounds.size.width;
    if (index != self.currentPage) {
        self.currentPage = index;
        if (self.currentPage == 0) {
            self.truePage = self.totalCount - 2 - 1;
        }
        else if (self.currentPage == self.totalCount - 1) {
            self.truePage = 0;
        }
        else self.truePage = self.currentPage - 1;
    }
    if (self.currentPage == 0 && scrollView.contentOffset.x < 0) {
        [self.coll scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.totalCount - 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:false];
    }
    else if (self.currentPage == self.totalCount - 1) {
        [self.coll scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:false];
    }
    
}

- (void)setTruePage:(NSInteger)truePage {
    _truePage = truePage;
    if (self.pageChangedBlock) {
        self.pageChangedBlock(_truePage);
    }
}

- (void)dealloc {
    [self stopTimer];
}

@end
