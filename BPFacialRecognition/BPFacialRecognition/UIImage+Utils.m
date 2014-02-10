//
//  UIImage+Utils.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/30/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import "UIImage+Utils.h"
#import "BPRecognizerCPUOperator.h"
@implementation UIImage (Utilities)
+(UIImage*)imageWithFilename:(NSString*)filename withExtension:(NSString*)fileExtension {
    NSString *imagePath = [[NSBundle bundleForClass:[BPRecognizerCPUOperator class]] pathForResource:filename ofType:fileExtension];
    return [UIImage imageWithContentsOfFile:imagePath];
}
-(UIImage*)grayscaledImage {
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, self.size.width, self.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [self CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}
-(UIImage*)resizedSquareImageOfDimension:(NSUInteger)dimension {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(dimension, dimension), NO, 1.0);
    [self drawInRect:CGRectMake(0, 0, dimension, dimension)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(UIImage*)resizedAndGrayscaledSquareImageOfDimension:(NSUInteger)dimension {
    return [[self resizedSquareImageOfDimension:dimension]grayscaledImage];
}

-(void*)vImageDataWithFloats {
    vImage_Buffer intermediate, returnValue;
    
    CGSize size = self.size;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
    }
    
    void *bitmapData = malloc(size.width * size.height);
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Error: Memory not allocated!");
        CGColorSpaceRelease(colorSpace);
    }
    
    CGContextRef context = CGBitmapContextCreate (bitmapData, size.width, size.height, 8, size.width * 1, colorSpace, kCGBitmapByteOrderDefault);
    CGColorSpaceRelease(colorSpace );
    if (context == NULL)
    {
        fprintf (stderr, "Error: Context not created!");
        free (bitmapData);
    }
    
    CGRect rect = (CGRect){.size = size};
    CGContextDrawImage(context, rect, self.CGImage);
    Byte *byteData = CGBitmapContextGetData (context);
    CGContextRelease(context);
    
    NSData *data = [NSData dataWithBytes:byteData length:(size.width * size.height * 1)];
    free(bitmapData);
    
    Byte* intermediateData = calloc([data length], sizeof(Byte));
    float* returnData = calloc([data length], sizeof(float));
    
    BPRecognizerCPUOperator *operator = [BPRecognizerCPUOperator new];
    
//    [BPUtil copyVectorFrom:(void*)data.bytes toVector:intermediateData offset:0 sizeOfType:sizeof(Byte)];
    [operator copyVector:(void*)data.bytes toVector:intermediateData numberOfElements:kSizeDimension*kSizeDimension  sizeOfType:sizeof(Byte)];
    
    intermediate.data = intermediateData; returnValue.data = returnData;
    intermediate.width = returnValue.width = self.size.width;
    intermediate.height = returnValue.height = self.size.height;
    intermediate.rowBytes = returnValue.rowBytes = self.size.width;
    returnValue.rowBytes *= sizeof(float);
    vImageConvert_Planar8toPlanarF(&intermediate, &returnValue, 1.f, 0.f, kvImageNoFlags);
    //float* returnDataD = calloc([data length], sizeof(float));
    //vDSP_vspdp(returnData, 1, returnDataD, 1, [data length]);
    //returnValue.rowBytes = sizeof(float);
    //returnValue.data = returnData;
    
    //free(byteData);
    free(intermediateData);
    //free(returnData);
    
    
    return returnData; // returns in the PlanarF format -- single channel, 32-floating points, range 0 - 255

}
+(UIImage*)imageWithRawFloatFloats:(float*)rawBytesSF WithFloatAndOfSquareDimension:(NSUInteger)dimension {
    
    Byte* rawBytesInt = calloc(kSizeDimension*kSizeDimension, sizeof(Byte));
    
    //float* rawBytesSF = calloc(dimension*dimension, sizeof(float));
    //vDSP_vdpsp(rawBytesDF, 1, rawBytesSF, 1, dimension*dimension);
    
    vImage_Buffer tempBufferSF;
    tempBufferSF.width = kSizeDimension;
    tempBufferSF.height = kSizeDimension;
    tempBufferSF.rowBytes = kSizeDimension*sizeof(float);
    tempBufferSF.data = rawBytesSF;
    vImage_Buffer tempBufferInt;
    tempBufferInt.width = kSizeDimension;
    tempBufferInt.height = kSizeDimension;
    tempBufferInt.rowBytes = kSizeDimension;
    tempBufferInt.data = rawBytesInt;
    vImageConvert_PlanarFtoPlanar8(&tempBufferSF, &tempBufferInt, 1.f, -1.f, kvImageNoFlags);
    
    
    
    // Create a color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");\
    }
    
    // Create the bitmap context
    CGContextRef context = CGBitmapContextCreate (rawBytesInt, kSizeDimension, kSizeDimension, 8, kSizeDimension, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    if (context == NULL)
    {
        fprintf (stderr, "Error: Context not created!");
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
    
    return image;
}
@end
