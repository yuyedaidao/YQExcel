//
//  YQExcelViewLayout.m
//  YQExcel
//
//  Created by Wang on 2017/5/16.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import "YQExcelViewLayout.h"


@interface NSArray (Sum)
- (double)sum;
@end

@implementation NSArray (Sum)

- (double)sum {
    __block double sum = 0;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        sum += [obj doubleValue];
    }];
    return sum;
}

@end


@interface YQIndexPath ()
+ (instancetype)indexPathWithColumn:(NSUInteger)column row:(NSUInteger)row type:(IndexPathType)type referenceColumn:(NSUInteger)referenceColumn referenceRow:(NSUInteger)referenceRow;
@end

@implementation YQIndexPath

+ (instancetype)indexPathWithColumn:(NSUInteger)column row:(NSUInteger)row type:(IndexPathType)type referenceColumn:(NSUInteger)referenceColumn referenceRow:(NSUInteger)referenceRow {
    NSInteger count = 0;
    switch (type) {
        case IndexPathTypeNormal:
            count = (referenceColumn + 1) * (row + 1) + column + 1;
            break;
       case IndexPathTypeColumnTitle:
            count = column;
            break;
        case IndexPathTypeRowTitle:
            count = (referenceColumn + 1) * (row + 1);
            break;
        default:
            break;
    }
  
    YQIndexPath *indexPath = [YQIndexPath indexPathForItem:count inSection:0];
    indexPath->_yqColumn = column;
    indexPath->_yqRow = row;
    indexPath->_type = type;
    return indexPath;
}

@end


@interface YQExcelViewLayout () {
    CGFloat *heights;
    CGFloat *widths;
    
    CGFloat *originYs;
    CGFloat *originXs;
    
    BOOL isMalloced;
}

@property (assign, nonatomic) CGSize contentSize;


@end

@implementation YQExcelViewLayout

- (void)prepareLayout {
    [super prepareLayout];
    _contentSize = CGSizeMake(originXs[_columnCount - 1] + widths[_columnCount - 1], originYs[_rowCount - 1] + heights[_rowCount - 1]);
}

- (CGSize)collectionViewContentSize {
    return _contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(YQIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake(originXs[indexPath.yqColumn], originYs[indexPath.yqRow], widths[indexPath.yqColumn], heights[indexPath.yqRow]);
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForColumnTitleAtIndexPath:(YQIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat originX;
    CGFloat width;
    if (indexPath.yqColumn == 0) {
        originX = self.collectionView.contentOffset.x;
        width = _rowTitleWidth;
        attributes.zIndex = NSIntegerMax;
    } else {
        originX = originXs[indexPath.yqColumn - 1];
        width = widths[indexPath.yqColumn - 1];
        attributes.zIndex = NSIntegerMax - 1;
    }
    attributes.frame = CGRectMake(originX, self.collectionView.contentOffset.y, width, _columnTitleHeight);
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForRowTitleAtIndexPath:(YQIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake(self.collectionView.contentOffset.x, originYs[indexPath.yqRow], _rowTitleWidth , heights[indexPath.yqRow]);
    attributes.zIndex = NSIntegerMax - 2;
    return attributes;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray<UICollectionViewLayoutAttributes *> *array = [NSMutableArray array];
    //先确定边界
    CGFloat originY = rect.origin.y;
    NSInteger startRow = ceil((originY - _columnTitleHeight) / (_itemMinimumSize.height + self.minimumLineSpacing)) - 1;
    startRow = MAX(startRow, 0);
    while (startRow >= 0) {
        if (originYs[startRow] > originY) {
            startRow--;
        } else {
            break;
        }
    }
    startRow = MAX(startRow, 0);
    
    CGFloat originX = rect.origin.x;
    NSInteger startColumn = ceil((originX - _rowTitleWidth) / (_itemMinimumSize.width + self.minimumInteritemSpacing)) - 1;
    startColumn = MAX(startColumn, 0);
    while (startColumn >= 0) {
        if (originXs[startColumn] > originX) {
            startColumn--;
        } else {
            break;
        }
    }
    startColumn = MAX(startColumn, 0);
    //一般column少,取这个的最大值
    NSInteger endColumn = startColumn;
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    while (endColumn < _columnCount) {
        if (originXs[endColumn] < maxX) {
            endColumn++;
        } else {
            break;
        }
    }
    endColumn = MIN(endColumn, _columnCount - 1);
    NSInteger column = MAX(startColumn, 1);
    YQIndexPath *indexPath = [YQIndexPath indexPathWithColumn:0 row:0 type:IndexPathTypeColumnTitle referenceColumn:_columnCount referenceRow:_rowCount];
    [array addObject:[self layoutAttributesForColumnTitleAtIndexPath:indexPath]];
    while (column <= endColumn + 1) {
        YQIndexPath *indexPath = [YQIndexPath indexPathWithColumn:column row:0 type:IndexPathTypeColumnTitle referenceColumn:_columnCount referenceRow:_rowCount];
        [array addObject:[self layoutAttributesForColumnTitleAtIndexPath:indexPath]];
        column++;
    }
    
    NSInteger row = startRow;
    while (row < _rowCount) {
        if (originYs[row] > maxY) {
            break;
        } else {
            YQIndexPath *indexPath = [YQIndexPath indexPathWithColumn:0 row:row type:IndexPathTypeRowTitle referenceColumn:_columnCount referenceRow:_rowCount];
            [array addObject:[self layoutAttributesForRowTitleAtIndexPath:indexPath]];
            for (NSInteger column = startColumn; column <= endColumn; column++) {
                YQIndexPath *indexPath = [YQIndexPath indexPathWithColumn:column row:row type:IndexPathTypeNormal referenceColumn:_columnCount referenceRow:_rowCount];
                [array addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
            }
        }
        row++;
    }
    
    return array;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

#pragma mark set&get

- (void)setItemMinimumSize:(CGSize)itemMinimumSize {
    _itemMinimumSize = itemMinimumSize;
    if (isMalloced) {
        free(heights);
        free(widths);
    }
    heights = malloc(_rowCount * sizeof(CGFloat));
    widths = malloc(_columnCount * sizeof(CGFloat));
    originYs = malloc(_rowCount * sizeof(CGFloat));
    originXs = malloc(_columnCount * sizeof(CGFloat));
    
    CGFloat height = _columnTitleHeight;
    for (int i = 0; i < _rowCount; i++) {
        heights[i] = itemMinimumSize.height;
        originYs[i] = height;
        height += itemMinimumSize.height + self.minimumLineSpacing;
    }
    
    CGFloat width = _rowTitleWidth;
    for (int i = 0; i < _columnCount; i++) {
        widths[i] = itemMinimumSize.width;
        originXs[i] = width;
        width += itemMinimumSize.width + self.minimumInteritemSpacing;
    }
    isMalloced = YES;
}

@end
