//
//  BPPersonTests.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/23/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BPPerson.h"
#import <UIKit/UIKit.h>
@interface BPPersonTests : XCTestCase
@property (nonatomic, retain) BPPerson* Robby;
@end

@implementation BPPersonTests

- (void)setUp
{
    [super setUp];
    self.Robby = [BPPerson personWithName:@"Robby Johnson"];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

-(void)testPersonCreation
{
    BPPerson *John = [BPPerson personWithName:@"John Smith"];
    XCTAssertNotNil(John, @"Person object should not be nil");
}

-(void)testPersonEquality
{
    BPPerson *John = [BPPerson personWithName:@"John Smith"];
    XCTAssertFalse([John isEqual:self.Robby], @"Two people are different objects");
    XCTAssertTrue([John isEqual:John], @"This is the same person and object");
}

- (void) testAddImageWithFace {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"face_image" ofType:@"png"];
    UIImage *face = [UIImage imageWithContentsOfFile:imagePath];
    XCTAssertTrue([self.Robby detectFaceAndAddImage:face], @"Face not detected");
}

- (void) testAddImageWithoutFace {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"car_image" ofType:@"png"];
    UIImage *car = [UIImage imageWithContentsOfFile:imagePath];
    XCTAssertFalse([self.Robby detectFaceAndAddImage:car], @"Face detected");
}
@end
