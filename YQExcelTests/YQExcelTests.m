//
//  YQExcelTests.m
//  YQExcelTests
//
//  Created by Wang on 2017/5/16.
//  Copyright © 2017年 Wang. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface YQExcelTests : XCTestCase

@end

@implementation YQExcelTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


- (void)testRect {
    CGRect rect1 = CGRectMake(0, 0, 2, 2);
    CGRect rect2 = CGRectMake(0, 0, 1, 1);
    CGRect rect3 = CGRectMake(0, 0, -1, -1);
    CGRect rect4 = CGRectMake(-1, -1, -1, -1);
    CGRect rect5 = CGRectMake(1, 1, 0, 0);
    XCTAssertTrue(CGRectEqualToRect(CGRectIntersection(rect1, rect2), rect2));
    XCTAssertTrue(CGRectEqualToRect(CGRectIntersection(rect1, rect3), CGRectZero));
    XCTAssertTrue(CGRectEqualToRect(CGRectIntersection(rect1, rect4), CGRectNull));
    NSLog(@"intersection : %@", NSStringFromCGRect(CGRectIntersection(rect1, rect4)));
    
}

@end
