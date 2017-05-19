//
//  YQExcelView.m
//  YQExcel
//
//  Created by Wang on 2017/5/16.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import "YQExcelView.h"
#import "YQCoverView.h"
//static CGFloat const kVelocity = 10.0f;

//CGRect CGRectFromIndexPaths(YQIndexPath *start, YQIndexPath *end) {
//    return CGRectMake(start.yqColumn, start.yqRow, (CGFloat)end.yqColumn - (CGFloat)start.yqColumn, (CGFloat)end.yqRow - (CGFloat)start.yqRow);
//}

typedef NS_ENUM(NSUInteger, YQIndexPathDirection) {
    YQIPDirectionLeft,
    YQIPDirectionRight,
    YQIPDirectionUp,
    YQIPDirectionDown,
    YQIPDirectionLeftup,
    YQIPDirectionLeftdown,
    YQIPDirectionRightup,
    YQIPDirectionRightdown,
    YQIPDirectionCover,
};

UIKIT_STATIC_INLINE YQIndexPathDirection YQIndexPathGetDirection(YQIndexPath *indexPath, YQIndexPath *refer) {
    if (indexPath.yqRow == refer.yqRow) {
        if (indexPath.yqColumn == refer.yqColumn) return YQIPDirectionCover;
        if (indexPath.yqColumn > refer.yqColumn) return YQIPDirectionRight;
        return YQIPDirectionLeft;
    }
    if (indexPath.yqRow < refer.yqRow) {
        if (indexPath.yqColumn == refer.yqColumn) return YQIPDirectionUp;
        if (indexPath.yqColumn < refer.yqColumn) return YQIPDirectionLeftup;
        return YQIPDirectionRightup;
    }
    
    if (indexPath.yqColumn == refer.yqColumn) return YQIPDirectionDown;
    if (indexPath.yqColumn < refer.yqColumn) return YQIPDirectionLeftdown;
    return YQIPDirectionRightdown;
    
}

@interface YQExcelView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) YQExcelViewLayout *layout;
@property (strong, nonatomic) UIView *columnTitleView;
@property (strong, nonatomic) UIView *rowTitleView;
@property (strong, nonatomic) UILongPressGestureRecognizer *pressGesture;
@property (strong, nonatomic) YQIndexPath *startIndexPath;
@property (strong, nonatomic) YQIndexPath *endIndexPath;
@property (strong, nonatomic) YQCoverView *coverView;
@property (assign, nonatomic) CGRect coverOriginalRect;
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
        UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
        self.coverView.frame = self.coverOriginalRect = cell.frame;
        [self.collectionView addSubview:self.coverView];
        self.startIndexPath = indexPath;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        YQIndexPath *indexPath = (YQIndexPath *)[self.collectionView indexPathForItemAtPoint:location];
        if (indexPath) {
            UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
            CGRect rect = cell.frame;
            switch (YQIndexPathGetDirection(indexPath, _startIndexPath)) {
                case YQIPDirectionLeft:
                case YQIPDirectionLeftup:
                    self.coverView.frame = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(_coverOriginalRect) - CGRectGetMinX(rect), CGRectGetMaxY(_coverOriginalRect) - CGRectGetMinY(rect));
                    break;
                case YQIPDirectionLeftdown:
                    self.coverView.frame = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(_coverOriginalRect), CGRectGetMaxX(_coverOriginalRect) - CGRectGetMinX(rect), CGRectGetMaxY(rect) - CGRectGetMinY(_coverOriginalRect));
                    break;
                case YQIPDirectionUp:
                case YQIPDirectionRight:
                case YQIPDirectionRightup:
                    self.coverView.frame = CGRectMake(CGRectGetMinX(_coverOriginalRect), CGRectGetMinY(rect), CGRectGetMaxX(rect) - CGRectGetMinX(_coverOriginalRect), CGRectGetMaxY(_coverOriginalRect) - CGRectGetMinY(rect));
                    break;
                case YQIPDirectionDown:
                case YQIPDirectionRightdown:
                    self.coverView.frame = CGRectMake(CGRectGetMinX(_coverOriginalRect), CGRectGetMinY(_coverOriginalRect), CGRectGetMaxX(rect) - CGRectGetMinX(_coverOriginalRect), CGRectGetMaxY(rect) - CGRectGetMinY(_coverOriginalRect));
                    break;
                default:
                    self.coverView.frame = cell.frame;
                    break;
            }
            self.endIndexPath = indexPath;
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(excelView:willUnCoverItemsOfIndexPaths:)]) {
            [self.delegate excelView:self willUnCoverItemsOfIndexPaths:[self indexPathsFrom:self.startIndexPath to:self.endIndexPath]];
        }
        [self.coverView removeFromSuperview];
    } else if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        [self.coverView removeFromSuperview];
    }
    

}

#pragma mark help
- (NSArray<YQIndexPath *> *) indexPathsFrom:(YQIndexPath *)origin to:(YQIndexPath *)another {
    NSInteger originX = origin.yqColumn;
    NSInteger originY = origin.yqRow;
    NSInteger endX = another.yqColumn;
    NSInteger endY = another.yqRow;
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = originY ; i <= endY; i++) {
        for (NSInteger j = originX; j <= endX; j++) {
            [array addObject:[YQIndexPath indexPathWithColumn:j row:i type:IndexPathTypeNormal referenceColumn:_layout.columnCount referenceRow:_layout.rowCount]];
        }
    }
    return array;
}

#pragma mark override
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self reloadData];
}

#pragma mark set&get
- (YQCoverView *)coverView {
    if (!_coverView) {
        _coverView = [[YQCoverView alloc] init];
        _coverView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
    }
    return _coverView;
}

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
