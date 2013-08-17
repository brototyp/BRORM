//
//  BRSegmentedStringTest.m
//  BROrm
//
//  Created by Cornelius Horstmann on 23.06.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BRSegmentedString.h"

@interface BRSegmentedStringTest : XCTestCase

@end

@implementation BRSegmentedStringTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSplitStringForOrAndAnd
{
    NSArray *segments;
    
    segments = [BRSegmentedString splitStringForOr:@"(a or b) or c"];
    XCTAssertEqualObjects(segments[0], @"(a or b)", @"");
    
    segments = [BRSegmentedString splitStringForAnd:@"a or b or c and d and e"];
    XCTAssertEqualObjects(segments[0], @"a or b or c", @"");
    
    segments = [BRSegmentedString splitStringForOr:@"(a or b or c)"];
    XCTAssertEqualObjects(segments[0], @"a", @"");
}

- (void)testObject
{
    BRSegmentedString *sest = [[BRSegmentedString alloc] initWithString:@"(a|b)&a|b|c"];
    XCTAssertEqual(sest.type, BRNodeTypeOr, @"");
    XCTAssertEqual(sest.left.type, BRNodeTypeAnd, @"");
    XCTAssertEqual(sest.left.left.type, BRNodeTypeOr, @"");
    XCTAssertEqual(sest.left.left.left.type, BRNodeTypeValue, @"");
    XCTAssertEqual(sest.left.left.right.type, BRNodeTypeValue, @"");
    XCTAssertEqual(sest.right.type, BRNodeTypeOr, @"");
    XCTAssertEqual(sest.right.left.type, BRNodeTypeValue, @"");
    XCTAssertEqual(sest.right.right.type, BRNodeTypeValue, @"");
}

@end
