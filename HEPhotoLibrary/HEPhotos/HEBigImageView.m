//
//  HEBigImageView.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/13.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEBigImageView.h"
#import "HEBigImageCell.h"
#import "HEPhotoConstant.h"

#define kItemMargin 30

@interface HEBigImageView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray <PHAsset *> *assets;       // 所有的图片资源数据源

@end

@implementation HEBigImageView

- (void)dealloc
{
    self.assets = nil;
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    self.collectionView = nil;
    self.BlockOnClickBigImage = NULL;
    self.BlockOnCurrentImage = NULL;
}


- (instancetype)initWithAssets:(NSArray <PHAsset *> *)assets currentIndex:(NSUInteger)index
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, kViewWidth, kViewHeight);
        self.backgroundColor = [UIColor blackColor];
        
        self.assets = assets;
        [self setupCollectionView];
        
        [self.collectionView setContentOffset:CGPointMake((index - 1) * self.collectionView.frame.size.width, 0)];
    }
    return self;
}

- (void)setupCollectionView {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = kItemMargin;
    layout.sectionInset = UIEdgeInsetsMake(0, kItemMargin/2, 0, kItemMargin/2);
    layout.itemSize = self.bounds.size;
    
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-kItemMargin/2, 0, kViewWidth + kItemMargin, kViewHeight) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[HEBigImageCell class] forCellWithReuseIdentifier:@"HEBigImageCell"];
    [self addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HEBigImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HEBigImageCell" forIndexPath:indexPath];
    cell.asset = [self.assets objectAtIndex:indexPath.item];
    WS(weakSelf)
    cell.BlockOnSingalTap = ^{
        if (weakSelf.BlockOnClickBigImage) {
            weakSelf.BlockOnClickBigImage();
        }
    };
    
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    if (self.BlockOnCurrentImage) {
        NSUInteger page = scrollView.contentOffset.x / scrollView.frame.size.width + 1;
        self.BlockOnCurrentImage(page);
    }
}

@end
