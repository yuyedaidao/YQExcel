//
//  ViewController.m
//  YQExcel
//
//  Created by Wang on 2017/5/16.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import "ViewController.h"
#import "YQExcelView.h"
#import "NormalCollectionCell.h"
#import "ColumnTitleCollectionCell.h"
#import "RowTitleCollectionCell.h"


@interface ViewController () <YQExcelViewDelegate, YQExcelViewDataSource>
@property (weak, nonatomic) IBOutlet YQExcelView *excelView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.excelView registerNib:[UINib nibWithNibName:NSStringFromClass([NormalCollectionCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([NormalCollectionCell class])];
    [self.excelView registerNib:[UINib nibWithNibName:NSStringFromClass([ColumnTitleCollectionCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([ColumnTitleCollectionCell class])];
    [self.excelView registerNib:[UINib nibWithNibName:NSStringFromClass([RowTitleCollectionCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([RowTitleCollectionCell class])];
    
    self.excelView.delegate = self;
    self.excelView.dataSource = self;
    
    [self.excelView reloadData];
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (YQExcelCount)itemCountInExcelView:(YQExcelView *)view {
    return YQExcelCountMake(30, 40);
}
- (__kindof UICollectionViewCell *)excelView:(YQExcelView *)view cellForItemAtIndexPath:(YQIndexPath *)indexPath {
    NormalCollectionCell *cell = [view dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NormalCollectionCell class]) forIndexPath:indexPath];
    cell.titleLabel.text = [NSString stringWithFormat:@"(%ld, %ld)", indexPath.yqColumn, indexPath.yqRow];
    return cell;
}


- (CGSize)itemMinimumSize:(YQExcelView *)view {
    return CGSizeMake(80, 60);
}
- (__kindof UICollectionViewCell *)excelView:(YQExcelView *)view columnTitleViewAtIndexPath:(nonnull YQIndexPath *)indexPath {
    ColumnTitleCollectionCell *cell = [view dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ColumnTitleCollectionCell class]) forIndexPath:indexPath];
    cell.titleLabel.text = [@(indexPath.yqColumn - 1) stringValue];
    return cell;
}
- (__kindof UICollectionViewCell *)excelView:(YQExcelView *)view rowTitleViewAtIndexPath:(nonnull YQIndexPath *)indexPath {
    RowTitleCollectionCell *cell = [view dequeueReusableCellWithReuseIdentifier:NSStringFromClass([RowTitleCollectionCell class]) forIndexPath:indexPath];
    cell.titleLabel.text = [@(indexPath.yqRow) stringValue];
    return cell;
}
- (CGFloat)lineSpacingInExcel:(YQExcelView *)view {
    return 10;
}
- (CGFloat)interitemSpacingInExcel:(YQExcelView *)view {
    return 0;
}
- (CGFloat)columnTitleHeightInExcel:(YQExcelView *)view {
    return 60;
}
- (CGFloat)rowTitleWidthInExcel:(YQExcelView *)view {
    return 60;
}

@end
