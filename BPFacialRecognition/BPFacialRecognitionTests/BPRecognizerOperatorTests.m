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
    Byte* input = calloc(sizeDimension*sizeDimension, sizeof(Byte));
    for (int i = 0; i < sizeDimension*sizeDimension; i++) {
        input[i] = i;
    }
    Byte* output = calloc(sizeDimension*sizeDimension, sizeof(Byte));
    [_operator copyVector:input toVector:output numberOfElements:sizeDimension*sizeDimension sizeOfType:sizeof(Byte)];
    BOOL failed = NO;
    for (int i = 0; i < sizeDimension*sizeDimension; i++) {
        if(input[i] != output[i]) {
            failed = YES;
            break;
        }
    }
    XCTAssertTrue(!failed, @"vector copy incorrect");
}

- (void) testCopyMultipleVectorsCorrectly {
    float* input1 = calloc(sizeDimension*sizeDimension, sizeof(float));
    for (int i = 0; i < sizeDimension*sizeDimension; i++) {
        input1[i] = (float)i;
    }
    float* input2 = calloc(sizeDimension*sizeDimension, sizeof(float));
    for (int i = 0; i < sizeDimension*sizeDimension; i++) {
        input2[i] = (float)i*2;
    }
    float* input3 = calloc(sizeDimension*sizeDimension, sizeof(float));
    for (int i = 0; i < sizeDimension*sizeDimension; i++) {
        input3[i] = (float)i*3;
    }
    float* output = calloc(sizeDimension*sizeDimension*3, sizeof(float));
    [_operator copyVector:input1 toVector:output numberOfElements:sizeDimension*sizeDimension offset:0 sizeOfType:sizeof(float)];
    [_operator copyVector:input2 toVector:output numberOfElements:sizeDimension*sizeDimension offset:1 sizeOfType:sizeof(float)];
    [_operator copyVector:input3 toVector:output numberOfElements:sizeDimension*sizeDimension offset:2 sizeOfType:sizeof(float)];
    BOOL failed = NO;
    int i = 0;
    for (; i < sizeDimension*sizeDimension*3; i++) {
        if (i < sizeDimension*sizeDimension) {
            if(input1[i] != output[i]) {
                failed = YES;
                break;
            }
        } else
            if (i < sizeDimension*sizeDimension*2) {
                if(input2[i-sizeDimension*sizeDimension] != output[i]) {
                    failed = YES;
                    break;
                }
            } else
                if (i < sizeDimension*sizeDimension*3) {
                    if(input3[i-sizeDimension*sizeDimension-sizeDimension*sizeDimension] != output[i]) {
                        failed = YES;
                        break;
                    }
                }
    }
    XCTAssertTrue(!failed, @"vector copy incorrect");
}

- (void) testCalculatingMeanImage {
    UIImage *face1 = [[UIImage imageWithFilename:@"face_image" withExtension:@"png"] resizedAndGrayscaledSquareImageOfDimension:sizeDimension];
    UIImage *face2 = [[UIImage imageWithFilename:@"face_image2" withExtension:@"png"] resizedAndGrayscaledSquareImageOfDimension:sizeDimension];
    
    double* face1Buffer = [face1 vImageDataWithDoubles];
    double* face2Buffer = [face2 vImageDataWithDoubles];
    
    RawType* twoImages = calloc(sizeDimension*sizeDimension*2, sizeof(RawType));
    
    [_operator copyVector:face1Buffer toVector:twoImages numberOfElements:sizeDimension*sizeDimension offset:0 sizeOfType:sizeof(RawType)];
    [_operator copyVector:face2Buffer toVector:twoImages numberOfElements:sizeDimension*sizeDimension offset:1 sizeOfType:sizeof(RawType)];
    
    RawType* meanFace = calloc(sizeDimension*sizeDimension, sizeof(RawType));

    [_operator columnWiseMeanOfDoubleMatrix:twoImages toDoubleVector:meanFace columnHeight:sizeDimension*sizeDimension rowWidth:2 freeInput:YES];
    
    UIImage *outputImage = [UIImage imageWithRawDoubleFloats:meanFace WithDoubleAndOfSquareDimension:sizeDimension];
    
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
    UIImage *face1 = [[UIImage imageWithFilename:@"face_image" withExtension:@"png"] resizedAndGrayscaledSquareImageOfDimension:sizeDimension];
    UIImage *face2 = [[UIImage imageWithFilename:@"face_image2" withExtension:@"png"] resizedAndGrayscaledSquareImageOfDimension:sizeDimension];
    
    double* face1Buffer = [face1 vImageDataWithDoubles];
    double* face2Buffer = [face2 vImageDataWithDoubles];
    
    RawType* twoImages = calloc(sizeDimension*sizeDimension*2, sizeof(RawType));
    
    [_operator copyVector:face1Buffer toVector:twoImages numberOfElements:sizeDimension*sizeDimension offset:0 sizeOfType:sizeof(RawType)];
    [_operator copyVector:face2Buffer toVector:twoImages numberOfElements:sizeDimension*sizeDimension offset:1 sizeOfType:sizeof(RawType)];
    
    RawType* meanFace = calloc(sizeDimension*sizeDimension, sizeof(RawType));
    
    [_operator columnWiseMeanOfDoubleMatrix:twoImages toDoubleVector:meanFace columnHeight:sizeDimension*sizeDimension rowWidth:2 freeInput:NO];
    [_operator subtractDoubleVector:meanFace fromDoubleVector:twoImages numberOfElements:sizeDimension*sizeDimension freeInput:NO];
    [_operator subtractDoubleVector:meanFace fromDoubleVector:(twoImages+sizeDimension*sizeDimension) numberOfElements:sizeDimension*sizeDimension freeInput:YES];
    
    UIImage *outputImage1 = [UIImage imageWithRawDoubleFloats:twoImages WithDoubleAndOfSquareDimension:sizeDimension];
    UIImage *outputImage2 = [UIImage imageWithRawDoubleFloats:(twoImages+sizeDimension*sizeDimension) WithDoubleAndOfSquareDimension:sizeDimension];
    
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
    RawType* A = calloc(sizeDimension*sizeDimension, sizeof(RawType));
    //RawType* Atranspose = calloc(sizeDimension*sizeDimension, sizeof(RawType));

    RawType* output = calloc(1, sizeof(RawType));
    for (int i = 0; i < sizeDimension*sizeDimension; ++i) {
        A[i] = ((RawType)(i%255))/255;
    }
    RawType answer = 0.f;
    for(int i = 0; i< sizeDimension*sizeDimension; ++i) {
        answer += (((RawType)(i%255))/255)*(((RawType)(i%255))/255);
    }
    //[_operator transposeDoubleMatrix:A transposed:Atranspose columnHeight:sizeDimension rowWidth:1 freeInput:NO];
    //
    // Transposing A not necessary since the matrix representation is
    // one long vector anyway
    [_operator multiplyDoubleMatrix:A withDoubleMatrix:A product:output matrixOneColumnHeight:1 matrixOneRowWidth:sizeDimension*sizeDimension matrixTwoRowWidth:1 freeInputs:YES];
    XCTAssertEqualWithAccuracy(answer, *output, (1/255.0)*(1/255.0),@"At x A doesn't work");
    
    free(output);
}


@end
