//
//  YQExcelView.m
//  YQExcel
//
//  Created by Wang on 2017/5/16.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import "YQExcelView.h"

static CGFloat const kVelocity = 10.0f;

@interface YQExcelView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) YQExcelViewLayout *layout;
@property (strong, nonatomic) UIView *columnTitleView;
@property (strong, nonatomic) UIView *rowTitleView;
@property (strong, nonatomic) UILongPressGestureRecognizer *pressGesture;
@property (strong, nonatomic) YQIndexPath *startIndexPath;
@property (strong, nonatomic) YQIndexPath *endIndexPath;

@property (strong, nonatomic) NSMutableSet<YQIndexPath *> *coveredIndexPaths;

@end

@implementation YQExcelView


- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _layout = [[YQExcelViewLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_layout];
    self.pressGesture = ({
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureAction:)];
        [_collectionView addGestureRecognizer:gesture];
        gesture;
    });
    
    [self addSubview:_collectionView];
    
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_collectionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    YQExcelCount count = [_dataSource itemCountInExcelView:self];
    return (count.column + 1) * (count.row + 1);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(YQIndexPath *)indexPath {
    NSAssert(_dataSource, @"请先设置数据源");
    switch (indexPath.type) {
        case IndexPathTypeNormal:
            return [_dataSource excelView:self cellForItemAtIndexPath:indexPath];
        case IndexPathTypeColumnTitle:
            return [_delegate excelView:self columnTitleViewAtIndexPath:indexPath];
        case IndexPathTypeRowTitle:
            return [_delegate excelView:self rowTitleViewAtIndexPath:indexPath];
        default:
            break;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了 %@", indexPath);
}

#pragma mark action

- (void)longPressGestureAction:(UILongPressGestureRecognizer *)gesture {
  
    CGPoint location = [gesture locationOfTouch:0 inView:self.collectionView];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        YQIndexPath *indexPath = (YQIndexPath *)[self.collectionView indexPathForItemAtPoint:location];
        if (indexPath && indexPath.type == IndexPathTypeNormal) {
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            cell.highlighted = YES;
        }
        self.endIndexPath = self.startIndexPath = indexPath;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        YQIndexPath *oldEndIndexPath = self.endIndexPath;
        YQIndexPath *indexPath = (YQIndexPath *)[self.collectionView indexPathForItemAtPoint:location];
        if (indexPath) {
            if (![indexPath isEqualLocation:oldEndIndexPath]) {
                
                NSMutableSet *set = [NSMutableSet set];
                NSInteger startRow, endRow, startColumn, endColumn;
                if (indexPath.yqRow - oldEndIndexPath.yqRow > 0) {
                    startRow = oldEndIndexPath.yqRow;
                    endRow = indexPath.yqRow;
                } else {
                    startRow = indexPath.yqRow;
                    endRow = oldEndIndexPath.yqRow;
                }
                if (indexPath.yqColumn - oldEndIndexPath.yqColumn > 0) {
                    startColumn = oldEndIndexPath.yqColumn;
                    endColumn = indexPath.yqColumn;
                } else {
                    startColumn = indexPath.yqColumn;
                    endColumn = oldEndIndexPath.yqColumn;
                }
                for (NSInteger i = startRow; i <= endRow; i++) {
                    for (NSInteger j = startColumn; j <= endColumn; j++) {
                        YQIndexPath *indexPath = [YQIndexPath indexPathWithColumn:j row:i type:IndexPathTypeNormal referenceColumn:_layout.columnCount referenceRow:_layout.rowCount];
                        [set addObject:indexPath];
                    }
                }
                if (_coveredIndexPaths) {
                    NSMutableSet *copy = [_coveredIndexPaths mutableCopy];
                    [copy intersectSet:set];
                    NSMutableSet *copy2 = [_coveredIndexPaths mutableCopy];
                    [copy2 minusSet:copy];
                    
                        //FIXME:这个算法不对
                    [copy2.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSLog(@"消除的 : %@",obj);
                    }];
                }
                _coveredIndexPaths = set;
                self.endIndexPath = indexPath;
            }
            
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
    
    } else if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        
    }
    

}


#pragma mark override
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self reloadData];
}

#pragma mark set&get


#pragma mark public
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(nonnull NSString *)identifier forIndexPath:(nonnull NSIndexPath *)indexPath {
    return [_collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    return [_collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    return [_collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (void)reloadData {
    YQExcelCount count = [_dataSource itemCountInExcelView:self];
    self.layout.columnCount = count.column;
    self.layout.rowCount = count.row;
    self.layout.minimumLineSpacing = [self.delegate lineSpacingInExcel:self];
    self.layout.minimumInteritemSpacing = [self.delegate interitemSpacingInExcel:self];
    self.layout.columnTitleHeight = [self.delegate columnTitleHeightInExcel:self];
    self.layout.rowTitleWidth = [self.delegate rowTitleWidthInExcel:self];
    self.layout.itemMinimumSize = [self.delegate itemMinimumSize:self];
    
    [self.collectionView reloadData];
}

- (void)updateWidth:(CGFloat)width itemAtIndexPath:(YQIndexPath *)indexPath {
//    NSAssert(indexPath.type == IndexPathTypeNormal, @"传入的IndexPath不正确");
    if (width < self.layout.itemMinimumSize.width) {
        
    }
}
- (void)updateHeight:(CGFloat)height itemAtIndexPath:(YQIndexPath *)indexPath {

}

@end
