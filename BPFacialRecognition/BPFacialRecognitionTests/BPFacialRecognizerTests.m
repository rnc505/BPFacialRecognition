//
//  BPFacialRecognitionTests.m
//  BPFacialRecognitionTests
//
//  Created by Robby Cohen on 1/22/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

/*
 +(BPFacialRecognizer*)newRecognizer;
 -(void)addNewPerson:(BPPerson*)person;
 -(void)train;
 -(BPRecognitionResult*)recognizeUnknownPerson:(UIImage*)image;
 -(BOOL)doesUnknownImage:(UIImage*)image matchPerson:(BPPerson*)person;
 -(NSSet*)peopleInRecognizer;

 */

#import <XCTest/XCTest.h>
#import "BPFacialRecognizer.h"
#import "BPPerson.h"
@interface BPFacialRecognizerTests : XCTestCase
@property (nonatomic, retain) BPFacialRecognizer* recognizer;
@end

@implementation BPFacialRecognizerTests

- (void)setUp
{
    [super setUp];
    self.recognizer = [BPFacialRecognizer newRecognizer];
}

- (void)tearDown
{
    [super tearDown];
}

- (void) testRecognizerCreation {
    XCTAssertNotNil(self.recognizer, @"Recognizer should not be nil");
}

- (void) testAddNewPerson {
    BPPerson *John = [BPPerson personWithName:@"John Smith"];
    [self.recognizer addNewPerson:John];
    XCTAssertTrue([[self.recognizer peopleInRecognizer] containsObject:John], @"John not in recognizer");
}

- (void) testRecognizeUnknownPerson {
    
}


@end
