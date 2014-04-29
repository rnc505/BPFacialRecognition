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
#import "BPRecognizerCPUOperator.h"
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

#ifdef  IMAGE_TESTS
-(void)testRecognizeDummyData {
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
    
    BPRecognitionResult* result1 = [self.recognizer recognizeUnknownPerson:[UIImage imageWithFilename:@"test1" withExtension:@"png"]];
    XCTAssertEqualObjects(Jack, [result1 person], @"People don't equal");
    
    BPRecognitionResult* resultA = [self.recognizer recognizeUnknownPerson:[UIImage imageWithFilename:@"1" withExtension:@"png"]];
    XCTAssertEqualObjects(Jack, [resultA person], @"People don't equal");
    
    
    
    BPRecognitionResult* result2 = [self.recognizer recognizeUnknownPerson:[UIImage imageWithFilename:@"test2" withExtension:@"png"]];
    XCTAssertEqualObjects(Fred, [result2 person], @"People don't equal");
    BPRecognitionResult* result3 = [self.recognizer recognizeUnknownPerson:[UIImage imageWithFilename:@"test3" withExtension:@"png"]];
    XCTAssertEqualObjects(James, [result3 person], @"People don't equal");
    BPRecognitionResult* result4 = [self.recognizer recognizeUnknownPerson:[UIImage imageWithFilename:@"test4" withExtension:@"png"]];
    XCTAssertEqualObjects(Han, [result4 person], @"People don't equal");
    BPRecognitionResult* result5 = [self.recognizer recognizeUnknownPerson:[UIImage imageWithFilename:@"test5" withExtension:@"png"]];
    XCTAssertEqualObjects(Jane, [result5 person], @"People don't equal");
    BPRecognitionResult* result6 = [self.recognizer recognizeUnknownPerson:[UIImage imageWithFilename:@"test6" withExtension:@"png"]];
    XCTAssertEqualObjects(Alfred, [result6 person], @"People don't equal");
    BPRecognitionResult* result7 = [self.recognizer recognizeUnknownPerson:[UIImage imageWithFilename:@"test7" withExtension:@"png"]];
    XCTAssertEqualObjects(Jamal, [result7 person], @"People don't equal");
    BPRecognitionResult* result8 = [self.recognizer recognizeUnknownPerson:[UIImage imageWithFilename:@"test8" withExtension:@"png"]];
    XCTAssertEqualObjects(Vlad, [result8 person], @"People don't equal");
    BPRecognitionResult* result9 = [self.recognizer recognizeUnknownPerson:[UIImage imageWithFilename:@"test9" withExtension:@"png"]];
    XCTAssertEqualObjects(Mitch, [result9 person], @"People don't equal");
    BPRecognitionResult* result10 = [self.recognizer recognizeUnknownPerson:[UIImage imageWithFilename:@"test10" withExtension:@"png"]];
    XCTAssertEqualObjects(SilentBob, [result10 person], @"People don't equal");
    NSLog(@" ");
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
    XCTAssertEqual(20u, sum, @"failed summing");//,
}

- (void)testExportData {
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
    
    BPRecognizerCPUOperator* _operator = [BPRecognizerCPUOperator new];
    
    RawType* retVal __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&retVal, kAlignment, kSizeDimension * kSizeDimension * [self.recognizer totalNumberOfImages]*sizeof(RawType)));
    int currentPosition = 0;
    for (UIImage* img in [self.recognizer totalImageSet]) {
        RawType* vImg __attribute__((aligned(kAlignment))) = [img vImageDataWithFloats];
        [_operator copyVector:vImg toVector:retVal numberOfElements:kSizeDimension*kSizeDimension offset:currentPosition sizeOfType:sizeof(RawType)];
        ++currentPosition;
        free(vImg); vImg = NULL;
    }

    

    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
	// If you go to the folder below, you will find those pictures
	NSLog(@"%@",docDir);
    
	NSLog(@"saving png");
	NSString *pngFilePath1 = [NSString stringWithFormat:@"%@/rawData.txt",docDir];
//    NSString *pngFilePath2 = [NSString stringWithFormat:@"%@/normalizedface2.txt",docDir];
    
    NSMutableString *outputString = [NSMutableString new];
    RawType *tempPointer = retVal;
    NSUInteger numImg = [self.recognizer totalNumberOfImages];
    for(int j = 0; j < numImg; ++j) {
        for (int i = 0; i < kSizeDimension*kSizeDimension; ++i) {
            [outputString appendFormat:@"%.14f ",*(tempPointer++)];
        }
        [outputString appendString:@"\n"];
    }
    
//    [outputString appendString:@"\n"];
    
    
//	NSData *data1 = [NSData dataWithBytes:retVal length:kSizeDimension*kSizeDimension*[self.recognizer totalNumberOfImages]*sizeof(RawType)];
//    NSData *data2 = [NSData dataWithData:UIImagePNGRepresentation(outputImage2)];
    BOOL yes; NSError *err;
//    [outputString writeToFile: atomically: encoding: error:err]
	yes = [outputString writeToFile:pngFilePath1 atomically:YES encoding:NSASCIIStringEncoding error:&err];
//    yes = [data2 writeToFile:pngFilePath2 atomically:YES];

}

@end
