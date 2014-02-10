//
//  BPRecognizerCPUOperatorTests.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 2/5/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BPRecognizerCPUOperator.h"
#import "UIImage+Utils.h"
@interface BPRecognizerOperatorTests : XCTestCase

@property (nonatomic, retain) BPRecognizerCPUOperator *operator;

@end

@implementation BPRecognizerOperatorTests

- (void)setUp
{
    [super setUp];
    self.operator = [BPRecognizerCPUOperator new];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void) testCopySingleVectorCorrectly {
    Byte* input = calloc(kSizeDimension*kSizeDimension, sizeof(Byte));
    for (int i = 0; i < kSizeDimension*kSizeDimension; i++) {
        input[i] = i;
    }
    Byte* output = calloc(kSizeDimension*kSizeDimension, sizeof(Byte));
    [_operator copyVector:input toVector:output numberOfElements:kSizeDimension*kSizeDimension sizeOfType:sizeof(Byte)];
    BOOL failed = NO;
    for (int i = 0; i < kSizeDimension*kSizeDimension; i++) {
        if(input[i] != output[i]) {
            failed = YES;
            break;
        }
    }
    XCTAssertTrue(!failed, @"vector copy incorrect");
}

- (void) testCopyMultipleVectorsCorrectly {
    float* input1 = calloc(kSizeDimension*kSizeDimension, sizeof(float));
    for (int i = 0; i < kSizeDimension*kSizeDimension; i++) {
        input1[i] = (float)i;
    }
    float* input2 = calloc(kSizeDimension*kSizeDimension, sizeof(float));
    for (int i = 0; i < kSizeDimension*kSizeDimension; i++) {
        input2[i] = (float)i*2;
    }
    float* input3 = calloc(kSizeDimension*kSizeDimension, sizeof(float));
    for (int i = 0; i < kSizeDimension*kSizeDimension; i++) {
        input3[i] = (float)i*3;
    }
    float* output = calloc(kSizeDimension*kSizeDimension*3, sizeof(float));
    [_operator copyVector:input1 toVector:output numberOfElements:kSizeDimension*kSizeDimension offset:0 sizeOfType:sizeof(float)];
    [_operator copyVector:input2 toVector:output numberOfElements:kSizeDimension*kSizeDimension offset:1 sizeOfType:sizeof(float)];
    [_operator copyVector:input3 toVector:output numberOfElements:kSizeDimension*kSizeDimension offset:2 sizeOfType:sizeof(float)];
    BOOL failed = NO;
    int i = 0;
    for (; i < kSizeDimension*kSizeDimension*3; i++) {
        if (i < kSizeDimension*kSizeDimension) {
            if(input1[i] != output[i]) {
                failed = YES;
                break;
            }
        } else
            if (i < kSizeDimension*kSizeDimension*2) {
                if(input2[i-kSizeDimension*kSizeDimension] != output[i]) {
                    failed = YES;
                    break;
                }
            } else
                if (i < kSizeDimension*kSizeDimension*3) {
                    if(input3[i-kSizeDimension*kSizeDimension-kSizeDimension*kSizeDimension] != output[i]) {
                        failed = YES;
                        break;
                    }
                }
    }
    XCTAssertTrue(!failed, @"vector copy incorrect");
}

- (void) testCalculatingMeanImage {
    UIImage *face1 = [[UIImage imageWithFilename:@"face_image" withExtension:@"png"] resizedAndGrayscaledSquareImageOfDimension:kSizeDimension];
    UIImage *face2 = [[UIImage imageWithFilename:@"face_image2" withExtension:@"png"] resizedAndGrayscaledSquareImageOfDimension:kSizeDimension];
    
    float* face1Buffer = [face1 vImageDataWithFloats];
    float* face2Buffer = [face2 vImageDataWithFloats];
    
    RawType* twoImages = calloc(kSizeDimension*kSizeDimension*2, sizeof(RawType));
    
    [_operator copyVector:face1Buffer toVector:twoImages numberOfElements:kSizeDimension*kSizeDimension offset:0 sizeOfType:sizeof(RawType)];
    [_operator copyVector:face2Buffer toVector:twoImages numberOfElements:kSizeDimension*kSizeDimension offset:1 sizeOfType:sizeof(RawType)];
    
    RawType* meanFace = calloc(kSizeDimension*kSizeDimension, sizeof(RawType));

    [_operator columnWiseMeanOfFloatMatrix:twoImages toFloatVector:meanFace columnHeight:kSizeDimension*kSizeDimension rowWidth:2 freeInput:YES];
    
    UIImage *outputImage = [UIImage imageWithRawFloatFloats:meanFace WithFloatAndOfSquareDimension:kSizeDimension];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
	// If you go to the folder below, you will find those pictures
	NSLog(@"%@",docDir);
    
	NSLog(@"saving png");
	NSString *pngFilePath = [NSString stringWithFormat:@"%@/meanface.png",docDir];
	NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(outputImage)];
	[data1 writeToFile:pngFilePath atomically:YES];
    
    free(meanFace);
}

- (void) testSubtractMeanFromVector {
    UIImage *face1 = [[UIImage imageWithFilename:@"face_image" withExtension:@"png"] resizedAndGrayscaledSquareImageOfDimension:kSizeDimension];
    UIImage *face2 = [[UIImage imageWithFilename:@"face_image2" withExtension:@"png"] resizedAndGrayscaledSquareImageOfDimension:kSizeDimension];
    
    float* face1Buffer = [face1 vImageDataWithFloats];
    float* face2Buffer = [face2 vImageDataWithFloats];
    
    RawType* twoImages = calloc(kSizeDimension*kSizeDimension*2, sizeof(RawType));
    
    [_operator copyVector:face1Buffer toVector:twoImages numberOfElements:kSizeDimension*kSizeDimension offset:0 sizeOfType:sizeof(RawType)];
    [_operator copyVector:face2Buffer toVector:twoImages numberOfElements:kSizeDimension*kSizeDimension offset:1 sizeOfType:sizeof(RawType)];
    
    RawType* meanFace = calloc(kSizeDimension*kSizeDimension, sizeof(RawType));
    
    [_operator columnWiseMeanOfFloatMatrix:twoImages toFloatVector:meanFace columnHeight:kSizeDimension*kSizeDimension rowWidth:2 freeInput:NO];
    [_operator subtractFloatVector:meanFace fromFloatVector:twoImages numberOfElements:kSizeDimension*kSizeDimension freeInput:NO];
    [_operator subtractFloatVector:meanFace fromFloatVector:(twoImages+kSizeDimension*kSizeDimension) numberOfElements:kSizeDimension*kSizeDimension freeInput:YES];
    
    UIImage *outputImage1 = [UIImage imageWithRawFloatFloats:twoImages WithFloatAndOfSquareDimension:kSizeDimension];
    UIImage *outputImage2 = [UIImage imageWithRawFloatFloats:(twoImages+kSizeDimension*kSizeDimension) WithFloatAndOfSquareDimension:kSizeDimension];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
	// If you go to the folder below, you will find those pictures
	NSLog(@"%@",docDir);
    
	NSLog(@"saving png");
	NSString *pngFilePath1 = [NSString stringWithFormat:@"%@/normalizedface1.png",docDir];
    NSString *pngFilePath2 = [NSString stringWithFormat:@"%@/normalizedface2.png",docDir];

	NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(outputImage1)];
    NSData *data2 = [NSData dataWithData:UIImagePNGRepresentation(outputImage2)];
    BOOL yes;
	yes = [data1 writeToFile:pngFilePath1 atomically:YES];
    yes = [data2 writeToFile:pngFilePath2 atomically:YES];
    
    free(twoImages);
}

- (void) testAtransposeTimesA {
    RawType* A = calloc(kSizeDimension*kSizeDimension, sizeof(RawType));
    //RawType* Atranspose = calloc(kSizeDimension*kSizeDimension, sizeof(RawType));

    RawType* output = calloc(1, sizeof(RawType));
    for (int i = 0; i < kSizeDimension*kSizeDimension; ++i) {
        A[i] = ((RawType)(i%255))/255;
    }
    double answer = 0.f;
    for(int i = 0; i< kSizeDimension*kSizeDimension; ++i) {
        answer += (((double)(i%255))/255)*(((double)(i%255))/255);
    }
    //[_operator transposeFloatMatrix:A transposed:Atranspose columnHeight:kSizeDimension rowWidth:1 freeInput:NO];
    //
    // Transposing A not necessary since the matrix representation is
    // one long vector anyway
    [_operator multiplyFloatMatrix:A withFloatMatrix:A product:output matrixOneColumnHeight:1 matrixOneRowWidth:kSizeDimension*kSizeDimension matrixTwoRowWidth:1 freeInputs:YES];
    XCTAssertEqualWithAccuracy(answer, *output, .5,@"At x A doesn't work");
    
    free(output);
}



@end
