//
//  BPUtilTests.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/30/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BPUtil.h"
@interface BPUtilTests : XCTestCase

@end

@implementation BPUtilTests

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

- (void) testCopySingleVectorCorrectly {
    Byte* input = calloc(sizeDimension*sizeDimension, sizeof(Byte));
    for (int i = 0; i < sizeDimension*sizeDimension; i++) {
        input[i] = i;
    }
    Byte* output = calloc(sizeDimension*sizeDimension, sizeof(Byte));
    [BPUtil copyVectorFrom:input toVector:output offset:0 sizeOfType:sizeof(Byte)];
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
    [BPUtil copyVectorFrom:input1 toVector:output offset:0 sizeOfType:sizeof(float)];
    [BPUtil copyVectorFrom:input2 toVector:output offset:1 sizeOfType:sizeof(float)];
    [BPUtil copyVectorFrom:input3 toVector:output offset:2 sizeOfType:sizeof(float)];
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
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"face_image" ofType:@"png"];
    UIImage *face = [UIImage imageWithContentsOfFile:imagePath];
    NSString *imagePath2 = [[NSBundle bundleForClass:[self class]] pathForResource:@"face_image2" ofType:@"png"];
    UIImage *face2 = [UIImage imageWithContentsOfFile:imagePath2];
    UIImage *grayed = [BPUtil grayscaledImageFromImage:[BPUtil resizedImageFromImage:face]];
    UIImage *grayed2 = [BPUtil grayscaledImageFromImage:[BPUtil resizedImageFromImage:face2]];
    vImage_Buffer faceBuffer = [BPUtil vImageFromUIImage:grayed];
    vImage_Buffer faceBuffer2 = [BPUtil vImageFromUIImage:grayed2];
    
    RawType* rawData = calloc(sizeDimension*sizeDimension*2, sizeof(RawType));
    [BPUtil copyVectorFrom:faceBuffer.data toVector:rawData offset:0 sizeOfType:sizeof(RawType)];
    [BPUtil copyVectorFrom:faceBuffer2.data toVector:rawData offset:1 sizeOfType:sizeof(RawType)];
    
    
    RawType* meanFace = calloc(sizeDimension*sizeDimension, sizeof(RawType));
    [BPUtil calculateMeanOfVectorFrom:rawData toVector:meanFace ofHeight:sizeDimension*sizeDimension ofWidth:2];

    Byte* meanFaceIntRaw = calloc(sizeDimension*sizeDimension, sizeof(Byte));
    
    float* rawDataF = calloc(sizeDimension*sizeDimension, sizeof(float));
    vDSP_vdpsp(meanFace, 1, rawDataF, 1, sizeDimension*sizeDimension);
    
    vImage_Buffer meanFaceFL;
    meanFaceFL.width = sizeDimension;
    meanFaceFL.height = sizeDimension;
    meanFaceFL.rowBytes = sizeDimension*sizeof(float);
    meanFaceFL.data = rawDataF;
    vImage_Buffer meanFaceInt;
    meanFaceInt.width = sizeDimension;
    meanFaceInt.height = sizeDimension;
    meanFaceInt.rowBytes = sizeDimension;
    meanFaceInt.data = meanFaceIntRaw;
    vImageConvert_PlanarFtoPlanar8(&meanFaceFL, &meanFaceInt, 1.f, 0, kvImageNoFlags);
    
    
    // Create a color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        free(meanFace);
    }
    
    // Create the bitmap context
    CGContextRef context = CGBitmapContextCreate (meanFaceIntRaw, sizeDimension, sizeDimension, 8, sizeDimension, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    if (context == NULL)
    {
        fprintf (stderr, "Error: Context not created!");
        free(meanFace);
        CGColorSpaceRelease(colorSpace );
    }
    
    // Convert to image
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    // Clean up
    CGColorSpaceRelease(colorSpace );
    free(CGBitmapContextGetData(context)); // frees bytes
    CGContextRelease(context);
    CFRelease(imageRef);
    
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
	// If you go to the folder below, you will find those pictures
	NSLog(@"%@",docDir);
    
	NSLog(@"saving png");
	NSString *pngFilePath = [NSString stringWithFormat:@"%@/meanface.png",docDir];
	NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
	BOOL yes = [data1 writeToFile:pngFilePath atomically:YES];
    
    
    //free(meanFace);
    free(rawData);
    [BPUtil cleanupvImage:faceBuffer2];
    [BPUtil cleanupvImage:faceBuffer];
}

- (void) testSubtractMeanFromVector {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"face_image" ofType:@"png"];
    UIImage *face = [UIImage imageWithContentsOfFile:imagePath];
    NSString *imagePath2 = [[NSBundle bundleForClass:[self class]] pathForResource:@"face_image2" ofType:@"png"];
    UIImage *face2 = [UIImage imageWithContentsOfFile:imagePath2];
    UIImage *grayed = [BPUtil grayscaledImageFromImage:[BPUtil resizedImageFromImage:face]];
    UIImage *grayed2 = [BPUtil grayscaledImageFromImage:[BPUtil resizedImageFromImage:face2]];
    vImage_Buffer faceBuffer = [BPUtil vImageFromUIImage:grayed];
    vImage_Buffer faceBuffer2 = [BPUtil vImageFromUIImage:grayed2];
    
    RawType* rawData = calloc(sizeDimension*sizeDimension*2, sizeof(RawType));
    [BPUtil copyVectorFrom:faceBuffer.data toVector:rawData offset:0 sizeOfType:sizeof(RawType)];
    [BPUtil copyVectorFrom:faceBuffer2.data toVector:rawData offset:1 sizeOfType:sizeof(RawType)];
    
    
    RawType* meanFace = calloc(sizeDimension*sizeDimension, sizeof(RawType));
    [BPUtil calculateMeanOfVectorFrom:rawData toVector:meanFace ofHeight:sizeDimension*sizeDimension ofWidth:2];
    [BPUtil subtractMean:meanFace fromVector:rawData withNumberOfImages:2];
    
    Byte* meanFaceIntRaw = calloc(sizeDimension*sizeDimension, sizeof(Byte));
    
    float* rawDataF = calloc(sizeDimension*sizeDimension, sizeof(float));
    vDSP_vdpsp(rawData, 1, rawDataF, 1, sizeDimension*sizeDimension);
    
    vImage_Buffer normalizedFaceFL;
    normalizedFaceFL.width = sizeDimension;
    normalizedFaceFL.height = sizeDimension;
    normalizedFaceFL.rowBytes = sizeDimension*sizeof(float);
    normalizedFaceFL.data = rawDataF;
    vImage_Buffer normalizedFaceInt;
    normalizedFaceInt.width = sizeDimension;
    normalizedFaceInt.height = sizeDimension;
    normalizedFaceInt.rowBytes = sizeDimension;
    normalizedFaceInt.data = meanFaceIntRaw;
    vImageConvert_PlanarFtoPlanar8(&normalizedFaceFL, &normalizedFaceInt, 1.f, -1.f, kvImageNoFlags);
    
    
    
    // Create a color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        free(meanFace);
    }
    
    // Create the bitmap context
    CGContextRef context = CGBitmapContextCreate (meanFaceIntRaw, sizeDimension, sizeDimension, 8, sizeDimension, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    if (context == NULL)
    {
        fprintf (stderr, "Error: Context not created!");
        free(meanFace);
        CGColorSpaceRelease(colorSpace );
    }
    
    // Convert to image
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    // Clean up
    CGColorSpaceRelease(colorSpace );
    free(CGBitmapContextGetData(context)); // frees bytes
    CGContextRelease(context);
    CFRelease(imageRef);
    
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
	// If you go to the folder below, you will find those pictures
	NSLog(@"%@",docDir);
    
	NSLog(@"saving png");
	NSString *pngFilePath = [NSString stringWithFormat:@"%@/normalizedface.png",docDir];
	NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
	BOOL yes = [data1 writeToFile:pngFilePath atomically:YES];
    
    
    free(meanFace);
    //free(rawData);
    [BPUtil cleanupvImage:faceBuffer2];
    [BPUtil cleanupvImage:faceBuffer];
}

- (void) testAtransposeTimesA {
    RawType* A = calloc(sizeDimension*sizeDimension, sizeof(RawType));
    RawType* output = calloc(1, sizeof(RawType));
    for (int i = 0; i < sizeDimension*sizeDimension; ++i) {
        A[i] = ((RawType)(i%255))/255;
    }
    RawType answer = 0.f;
    for(int i = 0; i< sizeDimension*sizeDimension; ++i) {
        answer += (((RawType)(i%255))/255)*(((RawType)(i%255))/255);
    }
    [BPUtil calculateAtransposeTimesAFromVector:A toOutputVector:output withNumberOfImages:1];
    XCTAssertEqualWithAccuracy(answer, *output, (1/255.0)*(1/255.0),@"At x A doesn't work");
}

- (void) testEigenvectorsInfo {
    int N = 5, LDA = 5, LDVL = 5, LDVR = 5;
    long n = N, lda = LDA, ldvl = LDVL, ldvr = LDVR, info, lwork;
    float wkopt;
    float* work;
    /* Local arrays */
    float wr[N], wi[N], vl[LDVL*N], vr[LDVR*N];
    float a[25] = {
        -1.01f,  3.98f,  3.30f,  4.43f,  7.31f,
        0.86f,  0.53f,  8.26f,  4.96f, -6.43f,
        -4.60f, -7.04f, -3.89f, -7.66f, -6.16f,
        3.31f,  5.29f,  8.20f, -7.33f,  2.47f,
        -4.81f,  3.55f, -1.51f,  6.18f,  5.58f
    };
    lwork = -1;
    sgeev_( "Vectors", "Vectors", &n, a, &lda, wr, wi, vl, &ldvl, vr, &ldvr,
          &wkopt, &lwork, &info );
    lwork = (int)wkopt;
    work = (float*)malloc( lwork*sizeof(float) );
    sgeev_( "Vectors", "Vectors", &n, a, &lda, wr, wi, vl, &ldvl, vr, &ldvr,
          work, &lwork, &info );
    /* Check for convergence */
    if( info > 0 ) {
        printf( "The algorithm failed to compute eigenvalues.\n" );
    }
}

//-(void)testCalculateEigenvectors {
//    RawType* A = calloc(9, sizeof(RawType));
//    RawType* eigenvectors = calloc(3, sizeof(RawType));
//    RawType* eigenvalues = calloc(9, sizeof(RawType));
//    for (int i = 1; i <= 9; ++i) {
//        A[i-1] = (RawType)i;
//    }
//    [BPUtil calculateEigenvectors:eigenvectors eigenvalues:eigenvalues fromVector:A withNumberOfImages:3];
//}

@end
