//
//  Tests.m
//  Tests
//
//  Created by Sumardi Shukor on 10/13/13.
//  Copyright (c) 2013 Software Machine Development. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PrayTime.h"

@interface Tests : XCTestCase {
    PrayTime *prayTime;
}

@end

@implementation Tests

// The setUp method is called automatically for each test-case method
// (methods whose name starts with 'test').
- (void)setUp
{
    [super setUp];

    prayTime = [[PrayTime alloc] init];
}

// This method is called after the invocation of each test method in the class.
- (void)tearDown
{
    [super tearDown];
}

- (void)testInstance
{
    XCTAssertNotNil(prayTime, @"Cannot find PrayTime instance");
}

@end
