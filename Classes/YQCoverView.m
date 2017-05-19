//
//  YQCoverView.m
//  YQExcel
//
//  Created by Wang on 2017/5/19.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import "YQCoverView.h"

@implementation YQCoverView


- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, self.bounds);
    CGContextSetLineWidth(context, 2);
    CGFloat lengths[2] = {10, 10};
    CGContextSetLineDash(context, 0, lengths, 2);
    if (_edgeColor) {
        [_edgeColor setStroke];
    } else {
        [UIColor colorWithRed:80 / 255.0f green:157 / 255.0f blue:234 / 255.0f alpha:1];
    }
    CGContextStrokePath(context);

}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setEdgeColor:(UIColor *)edgeColor {
    if (_edgeColor != edgeColor) {
        _edgeColor = edgeColor;
        [self setNeedsDisplay];
    }
}

@end
