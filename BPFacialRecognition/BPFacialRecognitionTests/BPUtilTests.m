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
    [BPUtil copyVectorFrom:input toVector:output offset:0];
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
    Byte* input1 = calloc(sizeDimension*sizeDimension, sizeof(Byte));
    for (int i = 0; i < sizeDimension*sizeDimension; i++) {
        input1[i] = i;
    }
    Byte* input2 = calloc(sizeDimension*sizeDimension, sizeof(Byte));
    for (int i = 0; i < sizeDimension*sizeDimension; i++) {
        input2[i] = i*2;
    }
    Byte* input3 = calloc(sizeDimension*sizeDimension, sizeof(Byte));
    for (int i = 0; i < sizeDimension*sizeDimension; i++) {
        input3[i] = i*3;
    }
    Byte* output = calloc(sizeDimension*sizeDimension*3, sizeof(Byte));
    [BPUtil copyVectorFrom:input1 toVector:output offset:0];
    [BPUtil copyVectorFrom:input2 toVector:output offset:1];
    [BPUtil copyVectorFrom:input3 toVector:output offset:2];
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
    
    Byte* rawData = calloc(sizeDimension*sizeDimension*2, sizeof(Byte));
    [BPUtil copyVectorFrom:faceBuffer.data toVector:rawData offset:0];
    [BPUtil copyVectorFrom:faceBuffer2.data toVector:rawData offset:1];
    
    
    Byte* meanFace = calloc(sizeDimension*sizeDimension, sizeof(Byte));
    [BPUtil calculateMeanOfVectorFrom:rawData toVector:meanFace ofHeight:sizeDimension*sizeDimension ofWidth:2];

    
    // Create a color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        free(meanFace);
    }
    
    // Create the bitmap context
    CGContextRef context = CGBitmapContextCreate (meanFace, sizeDimension, sizeDimension, 8, sizeDimension, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
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
    
    
    free(meanFace);
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
    
    Byte* rawData = calloc(sizeDimension*sizeDimension*2, sizeof(Byte));
    [BPUtil copyVectorFrom:faceBuffer.data toVector:rawData offset:0];
    [BPUtil copyVectorFrom:faceBuffer2.data toVector:rawData offset:1];
    
    
    Byte* meanFace = calloc(sizeDimension*sizeDimension, sizeof(Byte));
    [BPUtil calculateMeanOfVectorFrom:rawData toVector:meanFace ofHeight:sizeDimension*sizeDimension ofWidth:2];
    [BPUtil subtractMean:meanFace fromVector:rawData withNumberOfImages:2];
    
    // Create a color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        free(meanFace);
    }
    
    // Create the bitmap context
    CGContextRef context = CGBitmapContextCreate (rawData, sizeDimension, sizeDimension, 8, sizeDimension, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
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
    free(rawData);
    [BPUtil cleanupvImage:faceBuffer2];
    [BPUtil cleanupvImage:faceBuffer];
    
    
    
    
}
@end
