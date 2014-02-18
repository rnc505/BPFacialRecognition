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

#import "Defines.h"
#import <XCTest/XCTest.h>
#import "BPFacialRecognizer.h"
#import "BPPerson.h"
#import "UIImage+Utils.h"
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

#ifdef IMAGE_TESTS
- (void) testTrainingCompilesTest {
    BOOL failure = NO;
    
    BPPerson *Jack = [BPPerson personWithName:@"Jack"];
    failure = [Jack detectFaceAndAddImage:[UIImage imageWithFilename:@"1" withExtension:@"png"]];
    failure = [Jack detectFaceAndAddImage:[UIImage imageWithFilename:@"2" withExtension:@"png"]];
    
    BPPerson *Fred = [BPPerson personWithName:@"Fred"];
    failure = [Fred detectFaceAndAddImage:[UIImage imageWithFilename:@"3" withExtension:@"png"]];
    failure = [Fred detectFaceAndAddImage:[UIImage imageWithFilename:@"4" withExtension:@"png"]];
    
    BPPerson *James = [BPPerson personWithName:@"James"];
    failure = [James detectFaceAndAddImage:[UIImage imageWithFilename:@"5" withExtension:@"png"]];
    failure = [James detectFaceAndAddImage:[UIImage imageWithFilename:@"6" withExtension:@"png"]];
    
    BPPerson *Han = [BPPerson personWithName:@"Han"];
    failure = [Han detectFaceAndAddImage:[UIImage imageWithFilename:@"7" withExtension:@"png"]];
    failure = [Han detectFaceAndAddImage:[UIImage imageWithFilename:@"8" withExtension:@"png"]];
    
    BPPerson *Jane = [BPPerson personWithName:@"Jane"];
    failure = [Jane detectFaceAndAddImage:[UIImage imageWithFilename:@"9" withExtension:@"png"]];
    failure = [Jane detectFaceAndAddImage:[UIImage imageWithFilename:@"10" withExtension:@"png"]];
    
    BPPerson *Alfred = [BPPerson personWithName:@"Alfred"];
    failure = [Alfred detectFaceAndAddImage:[UIImage imageWithFilename:@"11" withExtension:@"png"]];
    failure = [Alfred detectFaceAndAddImage:[UIImage imageWithFilename:@"12" withExtension:@"png"]];
    
    BPPerson *Jamal = [BPPerson personWithName:@"Jamal"];
    failure = [Jamal detectFaceAndAddImage:[UIImage imageWithFilename:@"13" withExtension:@"png"]];
    failure = [Jamal detectFaceAndAddImage:[UIImage imageWithFilename:@"14" withExtension:@"png"]];
    
    BPPerson *Vlad = [BPPerson personWithName:@"Vlad"];
    failure = [Vlad detectFaceAndAddImage:[UIImage imageWithFilename:@"15" withExtension:@"png"]];
    failure = [Vlad detectFaceAndAddImage:[UIImage imageWithFilename:@"16" withExtension:@"png"]];
    
    BPPerson *Mitch = [BPPerson personWithName:@"Mitch"];
    failure = [Mitch detectFaceAndAddImage:[UIImage imageWithFilename:@"17" withExtension:@"png"]];
    failure = [Mitch detectFaceAndAddImage:[UIImage imageWithFilename:@"18" withExtension:@"png"]];
    
    BPPerson *SilentBob = [BPPerson personWithName:@"Silent Bob"];
    failure = [SilentBob detectFaceAndAddImage:[UIImage imageWithFilename:@"19" withExtension:@"png"]];
    failure = [SilentBob detectFaceAndAddImage:[UIImage imageWithFilename:@"20" withExtension:@"png"]];
    
    [self.recognizer addNewPerson:Jack];
    [self.recognizer addNewPerson:Fred];
    [self.recognizer addNewPerson:James];
    [self.recognizer addNewPerson:Han];
    [self.recognizer addNewPerson:Jane];
    [self.recognizer addNewPerson:Alfred];
    [self.recognizer addNewPerson:Jamal];
    [self.recognizer addNewPerson:Vlad];
    [self.recognizer addNewPerson:Mitch];
    [self.recognizer addNewPerson:SilentBob];
    
    [self.recognizer train];
    
}
#endif

- (void) testKeyValueCodingSumTest {
    
    BOOL failure;
    BPPerson *Jack = [BPPerson personWithName:@"Jack"];
    failure = [Jack detectFaceAndAddImage:[UIImage imageWithFilename:@"1" withExtension:@"png"]];
    failure = [Jack detectFaceAndAddImage:[UIImage imageWithFilename:@"2" withExtension:@"png"]];
    
    BPPerson *Fred = [BPPerson personWithName:@"Fred"];
    failure = [Fred detectFaceAndAddImage:[UIImage imageWithFilename:@"3" withExtension:@"png"]];
    failure = [Fred detectFaceAndAddImage:[UIImage imageWithFilename:@"4" withExtension:@"png"]];
    
    BPPerson *James = [BPPerson personWithName:@"James"];
    failure = [James detectFaceAndAddImage:[UIImage imageWithFilename:@"5" withExtension:@"png"]];
    failure = [James detectFaceAndAddImage:[UIImage imageWithFilename:@"6" withExtension:@"png"]];
    
    BPPerson *Han = [BPPerson personWithName:@"Han"];
    failure = [Han detectFaceAndAddImage:[UIImage imageWithFilename:@"7" withExtension:@"png"]];
    failure = [Han detectFaceAndAddImage:[UIImage imageWithFilename:@"8" withExtension:@"png"]];
    
    BPPerson *Jane = [BPPerson personWithName:@"Jane"];
    failure = [Jane detectFaceAndAddImage:[UIImage imageWithFilename:@"9" withExtension:@"png"]];
    failure = [Jane detectFaceAndAddImage:[UIImage imageWithFilename:@"10" withExtension:@"png"]];
    
    BPPerson *Alfred = [BPPerson personWithName:@"Alfred"];
    failure = [Alfred detectFaceAndAddImage:[UIImage imageWithFilename:@"11" withExtension:@"png"]];
    failure = [Alfred detectFaceAndAddImage:[UIImage imageWithFilename:@"12" withExtension:@"png"]];
    
    BPPerson *Jamal = [BPPerson personWithName:@"Jamal"];
    failure = [Jamal detectFaceAndAddImage:[UIImage imageWithFilename:@"13" withExtension:@"png"]];
    failure = [Jamal detectFaceAndAddImage:[UIImage imageWithFilename:@"14" withExtension:@"png"]];
    
    BPPerson *Vlad = [BPPerson personWithName:@"Vlad"];
    failure = [Vlad detectFaceAndAddImage:[UIImage imageWithFilename:@"15" withExtension:@"png"]];
    failure = [Vlad detectFaceAndAddImage:[UIImage imageWithFilename:@"16" withExtension:@"png"]];
    
    BPPerson *Mitch = [BPPerson personWithName:@"Mitch"];
    failure = [Mitch detectFaceAndAddImage:[UIImage imageWithFilename:@"17" withExtension:@"png"]];
    failure = [Mitch detectFaceAndAddImage:[UIImage imageWithFilename:@"18" withExtension:@"png"]];
    
    BPPerson *SilentBob = [BPPerson personWithName:@"Silent Bob"];
    failure = [SilentBob detectFaceAndAddImage:[UIImage imageWithFilename:@"19" withExtension:@"png"]];
    failure = [SilentBob detectFaceAndAddImage:[UIImage imageWithFilename:@"20" withExtension:@"png"]];
    
    NSArray *array = @[Jack, Fred, James, Han, Alfred, Jamal, Jane, Vlad, Mitch, SilentBob];
    NSUInteger sum = [[array valueForKeyPath:@"@sum.count"]unsignedIntegerValue];
    XCTAssertEqual(20u, sum, @"failed summing");//, <#format...#>
}

@end
