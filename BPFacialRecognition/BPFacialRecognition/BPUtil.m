//
//  BPUtil.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/30/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import "BPUtil.h"

@implementation BPUtil
+(UIImage *)resizedImageFromImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)grayscaledImageFromImage:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
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

+(vImage_Buffer)vImageFromUIImage:(UIImage *)image {
    vImage_Buffer returnValue;
    
    CGSize size = image.size;
    
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
    CGContextDrawImage(context, rect, image.CGImage);
    Byte *byteData = CGBitmapContextGetData (context);
    CGContextRelease(context);
    
    NSData *data = [NSData dataWithBytes:byteData length:(size.width * size.height * 1)];
    free(bitmapData);
    
    Byte* vImageData = calloc([data length], sizeof(Byte));
    [BPUtil copyVectorFrom:(void*)data.bytes toVector:vImageData offset:0];
    returnValue.data = vImageData;
    returnValue.width = image.size.width;
    returnValue.height = image.size.height;
    returnValue.rowBytes = image.size.width;
    return returnValue; // returns in the Planar_8 format -- single channel, unsigned 8-bit ints
}

+(void)cleanupvImage:(vImage_Buffer)rawData {
    free(rawData.data);
}

+(void)copyVectorFrom:(Byte*)input toVector:(Byte*)output offset:(NSInteger)offset {
    memcpy(output+(sizeDimension*sizeDimension*offset*sizeof(Byte)), input, sizeDimension*sizeDimension);
}
+(void)calculateMeanOfVectorFrom:(Byte *)input toVector:(Byte *)output ofHeight:(NSUInteger)height ofWidth:(NSUInteger)width{
    float* inbuffer = calloc(height*width, sizeof(float));
    float* outbuffer = calloc(height, sizeof(float));
    vDSP_vfltu8(input, 1, inbuffer, 1, width*height);
    for (int i = 0; i < height; ++i) {
        vDSP_meanv(inbuffer + i, height, outbuffer+i, width);
    }
    vDSP_vfixru8(outbuffer, 1, output, sizeof(Byte), height);
}

@end
