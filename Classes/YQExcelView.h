//
//  YQExcelView.h
//  YQExcel
//
//  Created by Wang on 2017/5/16.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQExcelViewLayout.h"

typedef struct {
    NSInteger column;
    NSInteger row;
}YQExcelCount;

UIKIT_STATIC_INLINE YQExcelCount YQExcelCountMake(NSInteger column, NSInteger row) {
    YQExcelCount count;
    count.row = row;
    count.column = column;
    return count;
}

NS_ASSUME_NONNULL_BEGIN

UIKIT_STATIC_INLINE NSRange ColumnRangeFromIndexPaths(YQIndexPath *one, YQIndexPath *another) {
    NSInteger start = MIN(one.yqColumn, another.yqColumn);
    NSInteger end = MAX(one.yqColumn, another.yqColumn);
    return NSMakeRange(start, end - start + 1);
}

UIKIT_STATIC_INLINE NSRange RowRangeFromIndexPaths(YQIndexPath *one, YQIndexPath *another) {
    NSInteger start = MIN(one.yqRow, another.yqRow);
    NSInteger end = MAX(one.yqRow, another.yqRow);
    return NSMakeRange(start, end - start + 1);
}

@class YQExcelView;
@protocol YQExcelViewDataSource <NSObject>

- (YQExcelCount)itemCountInExcelView:(YQExcelView *)view;
- (__kindof UICollectionViewCell *)excelView:(YQExcelView *)view cellForItemAtIndexPath:(YQIndexPath *)indexPath;

@end


@protocol YQExcelViewDelegate <NSObject>

- (CGSize)itemMinimumSize:(YQExcelView *)view;
- (__kindof UICollectionViewCell *)excelView:(YQExcelView *)view columnTitleViewAtIndexPath:(YQIndexPath *)indexPath;
- (__kindof UICollectionViewCell *)excelView:(YQExcelView *)view rowTitleViewAtIndexPath:(YQIndexPath *)indexPath;
- (CGFloat)lineSpacingInExcel:(YQExcelView *)view;
- (CGFloat)interitemSpacingInExcel:(YQExcelView *)view;
- (CGFloat)columnTitleHeightInExcel:(YQExcelView *)view;
- (CGFloat)rowTitleWidthInExcel:(YQExcelView *)view;

- (void)excelView:(YQExcelView *)view didSelectItemAtIndexPath:(YQIndexPath *)indexPath;
- (void)excelView:(YQExcelView *)view willUnCoverItemsOfIndexPaths:(NSArray<YQIndexPath *> *)indexPaths source:(YQIndexPath *)source end:(YQIndexPath *)end;




@end
NS_ASSUME_NONNULL_END

NS_ASSUME_NONNULL_BEGIN
@interface YQExcelView : UIView

@property (strong, nonatomic, readonly) UICollectionView *collectionView;
@property (weak, nonatomic) IBInspectable id<YQExcelViewDataSource> dataSource;
@property (weak, nonatomic) IBInspectable id<YQExcelViewDelegate> delegate;
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(nullable UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;
- (void)reloadData;
- (void)updateWidth:(CGFloat)width forRange:(NSRange)range;
- (void)updateHeight:(CGFloat)height forRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END

