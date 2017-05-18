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
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) CADisplayLink *displayLink;

@property (assign, nonatomic) CGFloat xVelocityScale;
@property (assign, nonatomic) CGFloat yVelocityScale;

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
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.timer = ({
            NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
                CGPoint offset = self.collectionView.contentOffset;
                
                if (self.xVelocityScale != 0) {
                    offset.x += self.xVelocityScale * kVelocity;
                }
                if (self.yVelocityScale != 0) {
                    offset.y += self.yVelocityScale * kVelocity;
                }
                self.collectionView.contentOffset = offset;
            }];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            timer;
        });
//        [self.timer fire];
        
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(moveContentAction:)];
        self.displayLink.frameInterval = 3;
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    CGPoint location = [gesture locationOfTouch:0 inView:self.collectionView];
    YQIndexPath *indexPath = (YQIndexPath *)[self.collectionView indexPathForItemAtPoint:location];
    if (indexPath && indexPath.type == IndexPathTypeNormal) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        cell.backgroundColor = [UIColor grayColor];
    }
    CGPoint offset = self.collectionView.contentOffset;
    CGFloat deltaX = offset.x + CGRectGetWidth(self.collectionView.bounds) - location.x;
    CGFloat deltaY = offset.y + CGRectGetHeight(self.collectionView.bounds) - location.y;

    CGFloat gestureMargin = [UIScreen mainScreen].bounds.size.width * 0.3;
    if (deltaX < gestureMargin) {
        self.xVelocityScale = MAX((gestureMargin - deltaX) / gestureMargin, 0.2);
    } else {
        self.xVelocityScale = 0;
    }
    if (deltaY < gestureMargin) {
        self.yVelocityScale = MAX((gestureMargin - deltaY) / gestureMargin, 0.2);
    } else {
        self.yVelocityScale = 0;
    }
//    [self.collectionView setContentOffset:offset animated:YES];
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateFailed || gesture.state == UIGestureRecognizerStateCancelled) {
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        if (_displayLink) {
            [_displayLink invalidate];
        }
    }
}

- (void)moveContentAction:(id)sender {
    CGPoint offset = self.collectionView.contentOffset;
    
    if (self.xVelocityScale != 0) {
        offset.x += floor(self.xVelocityScale * kVelocity);
    }
    if (self.yVelocityScale != 0) {
        offset.y += floor(self.yVelocityScale * kVelocity);
    }

    self.collectionView.contentOffset = offset;

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
