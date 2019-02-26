//
//  SnailPhotoView.m
//  lesan
//
//  Created by liu on 2018/7/22.
//  Copyright © 2018年 ning. All rights reserved.
//

#import "SnailPhotoView.h"
#import "SnailPhotoFlowLayout.h"

@interface SnailPhotoView()<UICollectionViewDelegate,UICollectionViewDataSource>

kSPrStrong(UICollectionView *coll)
kSPrStrong(UILabel *numLbl)
kSPr(NSInteger totalCount)

@end

@implementation SnailPhotoView

- (instancetype)init {
    self = [super init];
    if (self) {
        
        SnailPhotoFlowLayout *flow = [SnailPhotoFlowLayout new];
        
        self.coll = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
        self.coll.backgroundColor = SNA_CLEAR_COLOR;
        self.coll.delegate = self;
        self.coll.dataSource = self;
        [self.coll registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"c"];
        
        self.numLbl = [UILabel new];
        self.numLbl.font = SNAS_SYS_FONT(13);
        self.numLbl.textAlignment = NSTextAlignmentCenter;
        self.numLbl.textColor = SNA_WHITE_COLOR;
        
        UIView *back = [UIView new];
        back.snail_corner(5);
        back.backgroundColor = [SNA_BLACK_COLOR colorWithAlphaComponent:0.6];
        
        [self addSubview:self.coll];
        [self addSubview:back];
        [back addSubview:self.numLbl];
        
        [self.coll mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [back mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.trailing.equalTo(self).offset(-15);
            make.height.equalTo(@20);
        }];
        [self.numLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(back);
            make.leading.equalTo(back).offset(15);
        }];
        
    }
    return self;
}

- (void)reload {
    if (self.itemCountBlock) self.totalCount = self.itemCountBlock();
    if (self.totalCount > 0) {
        self.numLbl.text = [NSString stringWithFormat:@"%d/%ld",1,self.totalCount];
        self.numLbl.hidden = false;
    }
    else self.numLbl.hidden = true;
    [self.coll reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger integer = (scrollView.contentOffset.x + self.coll.frame.size.width * 0.25 * 0.5)/ (self.coll.frame.size.width * 0.75);
    self.numLbl.text = [NSString stringWithFormat:@"%ld/%ld",integer+1,self.totalCount];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.itemCountBlock) return self.itemCountBlock();
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"c" forIndexPath:indexPath];
    
    UIImageView *imgV = [cell viewWithTag:-1];
    if (imgV == nil) {
        imgV = [UIImageView new];
        imgV.tag = -1;
        [cell addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell);
        }];
    }
    
    if (self.configureImageBlock) self.configureImageBlock(imgV, indexPath.row);
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.clickBlock) self.clickBlock(indexPath.row);
}

@end
