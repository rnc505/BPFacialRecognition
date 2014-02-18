//
//  BPRecognitionResultTests.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/23/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BPRecognitionResult.h"
#import "BPPerson.h"
#import "Defines.h"

@interface BPRecognitionResultTests : XCTestCase

@property (nonatomic, retain) BPPerson* person;
@property (nonatomic, retain) BPRecognitionResult* result;
@property (nonatomic, assign) double confidence;

@end

@implementation BPRecognitionResultTests

- (void)setUp
{
    [super setUp];
    self.person = [BPPerson personWithName:@"Robby Johnson"];
    self.result = [BPRecognitionResult resultWithPerson:self.person withConfidence:100.0];
    self.confidence = 100;
                   
}

- (void)tearDown
{
    [super tearDown];
}
#ifdef NON_IMAGE_TESTS
-(void)testResultCreation
{
    XCTAssertNotNil(self.result, @"Result object should not be nil");
}
#endif
#ifdef NON_IMAGE_TESTS
- (void) testPerson {
    XCTAssertNotNil([self.result person], @"Passed person shouldn't be nil");
    XCTAssertTrue([self.person isEqual:[self.result person]], @"People should be equal");
}
#endif
#ifdef NON_IMAGE_TESTS
- (void) testConfidence {
    XCTAssertEqual(self.confidence, [self.result confidence], @"Confidence values should be equal");
}
#endif

@end
