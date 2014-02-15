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

void print_matrix( char* desc, int m, int n, float* a, int lda ) {
    int i, j;
    printf( "\n %s\n", desc );
    for( i = 0; i < m; i++ ) {
        for( j = 0; j < n; j++ ) printf( "\t%6.6f", a[i+j*lda] );
        printf( "\n" );
    }
}

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

//- (void) testResize {
//    UIImage *face1 = [[UIImage imageWithFilename:@"face_image" withExtension:@"png"] resizedSquareImageOfDimension:kSizeDimension];
//    UIImage *face2 = [[UIImage imageWithFilename:@"face_image2" withExtension:@"png"] resizedSquareImageOfDimension:kSizeDimension];
//    
//    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//	// If you go to the folder below, you will find those pictures
//	NSLog(@"%@",docDir);
//    
//	NSLog(@"saving png");
//	NSString *pngFilePath1 = [NSString stringWithFormat:@"%@/normalizedface1.jpg",docDir];
//    NSString *pngFilePath2 = [NSString stringWithFormat:@"%@/normalizedface2.jpg",docDir];
//    
//    
//    
//    
//	NSData *data1 = [NSData dataWithData:UIImageJPEGRepresentation(face1, 1.f)];
//    NSData *data2 = [NSData dataWithData:UIImageJPEGRepresentation(face2, 1.f)];
//    BOOL yes;
//	yes = [data1 writeToFile:pngFilePath1 atomically:YES];
//    yes = [data2 writeToFile:pngFilePath2 atomically:YES];
//}

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
    RawType* Atranspose = calloc(kSizeDimension*kSizeDimension, sizeof(RawType));

    RawType* output = calloc(1, sizeof(RawType));
    
    for (int i = 0; i < kSizeDimension*kSizeDimension; ++i) {
        int j = 1;
        if(i % 7 == 0){
            j = -1;
        }
        A[i] = j*((RawType)(i%255))/255;
    }
    double answer = 0.f;
    for(int i = 0; i< kSizeDimension*kSizeDimension; ++i) {
        answer += (((double)(i%255))/255)*(((double)(i%255))/255);
    }
    [_operator transposeFloatMatrix:A transposed:Atranspose columnHeight:kSizeDimension*kSizeDimension rowWidth:1 freeInput:NO];
    //
    // Transposing A not necessary since the matrix representation is
    // one long vector anyway
    [_operator multiplyFloatMatrix:Atranspose withFloatMatrix:A product:output matrixOneColumnHeight:1 matrixOneRowWidth:kSizeDimension*kSizeDimension matrixTwoRowWidth:1 freeInputs:YES];
    XCTAssertEqualWithAccuracy(answer, *output, .5,@"At x A doesn't work");
    
    free(output);
}

- (void) testEigendecompose {
    int num = 5, important = 3;
    RawType* A = calloc(num*num, sizeof(RawType));
    for (int i = 0; i < num*num; ++i) {
        if(i % 6 == 0) {
            A[i] = 1;
        } else if(i < 5) {
            A[i] = i+1;
        } else if(i%5 == 0) {
            A[i] = i/5 + 1;
        } else if(i == 7 || i == 11) {
            A[i] = 5;
        } else if(i == 8 || i == 16) {
            A[i] = 6;
        } else if(i == 9 || i == 13 || i == 17 || i == 21) {
            A[i] = 7;
        } else if(i == 14 || i == 19 || i == 22 || i == 23) {
            A[i] = 9;
        }
    }
    /*
        A looks like:
            
            1  2  3  4  5
            2  1  5  6  7
            3  5  1  7  9
            4  6  7  1  9
            5  7  9  9  1
     */
    RawType eigenvalues[important], eigenvectors[num*important];
    [_operator eigendecomposeSymmetricFloatMatrix:A intoEigenvalues:eigenvalues eigenvectors:eigenvectors numberOfImportantValues:important matrixDimension:num freeInput:NO];
    
    /*
        Eigenvalues of A:
            -8.983462   -6.298213   -3.923724   -0.669999   24.875397
     
        Eigenvectors of A: (column = vectors of that eigenvalue
            -0.136710   0.146243    0.233637    0.906761    -0.288307
            -0.165157   0.247793    0.770830    -0.392025   -0.404301
            -0.409521   0.513044    -0.572755   -0.145950   -0.468752
            -0.308341   -0.808276   -0.088973   -0.049377   -0.491184
            0.831416    0.026215    -0.123574   -0.018976   -0.540768
     
     */
    
    
    /* Print eigenvalues */
//   print_matrix( "Selected eigenvalues", 1, important, eigenvalues, 1 );
    /* Print eigenvectors */
//   print_matrix( "Selected eigenvectors (stored columnwise)", num, important, eigenvectors, num );
}

- (void) testEigenvalueCalculationOfFaces {
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
    
    RawType* AtransposeTIMESA = calloc(2*2,sizeof(RawType));
    
    RawType* twoImagesTranspose = calloc(kSizeDimension*kSizeDimension*2, sizeof(RawType));
    [_operator transposeFloatMatrix:twoImages transposed:twoImagesTranspose columnHeight:kSizeDimension*kSizeDimension rowWidth:2 freeInput:NO];
    
    [_operator multiplyFloatMatrix:twoImagesTranspose withFloatMatrix:twoImages product:AtransposeTIMESA matrixOneColumnHeight:2 matrixOneRowWidth:kSizeDimension*kSizeDimension matrixTwoRowWidth:2 freeInputs:NO];
    
    RawType eigenvalues[2], eigenvectors[4];
    
    [_operator eigendecomposeSymmetricFloatMatrix:AtransposeTIMESA intoEigenvalues:eigenvalues eigenvectors:eigenvectors numberOfImportantValues:2 matrixDimension:2 freeInput:NO];
//    print_matrix( "Selected eigenvalues", 1, 2, eigenvalues, 1 );
    /* Print eigenvectors */
//    print_matrix( "Selected eigenvectors (stored columnwise)", 2, 2, eigenvectors, 2 );
}

- (void) testEnumeration {
    NSArray *array = @[@"One",@"Two",@"Three"];
    int i = 0;
    for (NSString *str in array) {
        switch (i) {
            case 0:
                XCTAssertEqualObjects(@"One", str, @"strings not equal");
                break;
                
            case 1:
                XCTAssertEqualObjects(@"Two", str, @"strings not equal");
                break;
                
            case 2:
                XCTAssertEqualObjects(@"Three", str, @"strings not equal");
                break;
            default:
                break;
        }
        ++i;
    }
}

- (void) testFloatToNSDataAndBackConversion {
    float* array = calloc(10, sizeof(float));
    for(int i = 0; i < 10; ++i) {
        array[i] = powf(2.5f, i);
    }
    NSData *data = [NSData dataWithBytes:array length:sizeof(float)*10];
    float *oldArray = (float*)[data bytes];
    for (int i = 0; i < 10; ++i) {
        XCTAssertEqual(powf(2.5f, i), oldArray[i], @"should be equal");
    }
}


@end
