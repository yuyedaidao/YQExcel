//
//  YQExcelViewLayout.h
//  YQExcel
//
//  Created by Wang on 2017/5/16.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, IndexPathType) {
    IndexPathTypeNormal,
    IndexPathTypeRowTitle,
    IndexPathTypeColumnTitle,
};


NS_ASSUME_NONNULL_BEGIN

@interface YQIndexPath : NSIndexPath
+ (instancetype)indexPathWithColumn:(NSUInteger)column row:(NSUInteger)row type:(IndexPathType)type referenceColumn:(NSUInteger)referenceColumn referenceRow:(NSUInteger)referenceRow;
@property (assign, nonatomic, readonly) NSUInteger yqColumn;
@property (assign, nonatomic, readonly) NSUInteger yqRow;
@property (assign, nonatomic, readonly) IndexPathType type;
- (BOOL)isEqualLocation:(YQIndexPath *)another;

@end

NS_ASSUME_NONNULL_END

@interface YQExcelViewLayout : UICollectionViewLayout

@property (assign, nonatomic) CGFloat minimumLineSpacing;
@property (assign, nonatomic) CGFloat minimumInteritemSpacing;
@property (assign, nonatomic) CGFloat columnTitleHeight;
@property (assign, nonatomic) CGFloat rowTitleWidth;
@property (assign, nonatomic) CGSize itemMinimumSize;
@property (assign, nonatomic) NSInteger columnCount;
@property (assign, nonatomic) NSInteger rowCount;

@end
