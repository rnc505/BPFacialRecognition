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
    vImage_Buffer intermediate, returnValue;
    
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
    
    Byte* intermediateData = calloc([data length], sizeof(Byte));
    float* returnData = calloc([data length], sizeof(float));
    [BPUtil copyVectorFrom:(void*)data.bytes toVector:intermediateData offset:0 sizeOfType:sizeof(Byte)];
    intermediate.data = intermediateData; returnValue.data = returnData;
    intermediate.width = returnValue.width = image.size.width;
    intermediate.height = returnValue.height = image.size.height;
    intermediate.rowBytes = returnValue.rowBytes = image.size.width;
    returnValue.rowBytes *= 4;
    vImageConvert_Planar8toPlanarF(&intermediate, &returnValue, 255.f, 0.f, kvImageNoFlags);
    return returnValue; // returns in the PlanarF format -- single channel, 32-floating points, range 0 - 255
}

+(void)cleanupvImage:(vImage_Buffer)rawData {
    free(rawData.data);
}

+(void)copyVectorFrom:(void*)input toVector:(void*)output offset:(NSInteger)offset sizeOfType:(NSUInteger)size{
    memcpy(output+(sizeDimension*sizeDimension*offset*size), input, sizeDimension*sizeDimension*size);
}
+(void)calculateMeanOfVectorFrom:(RawType *)input toVector:(RawType *)output ofHeight:(NSUInteger)height ofWidth:(NSUInteger)width{
    //float* inbuffer = calloc(height*width, sizeof(float));
    //float* outbuffer = calloc(height, sizeof(float));
    //vDSP_vfltu8(input, 1, inbuffer, 1, width*height);
    for (int i = 0; i < height; ++i) {
        vDSP_meanv(input + i, height, output+i, width);
    }
    //vDSP_vfixru8(outbuffer, 1, output, 1, height);
    //free(outbuffer);
    //free(inbuffer);
}
+(void)subtractMean:(RawType *)mean fromVector:(RawType *)vector withNumberOfImages:(NSInteger)num {
    //float *inbuffer = calloc(sizeDimension*sizeDimension*(num+1), sizeof(float));
    //vDSP_vfltu8(mean, 1, inbuffer, 1, sizeDimension*sizeDimension);
    //vDSP_vfltu8(vector, 1, inbuffer+sizeDimension*sizeDimension, 1, sizeDimension*sizeDimension*num);
    for (int i = 0; i < num; i++) {
        //vDSP_vsub(inbuffer, 1, inbuffer+i*sizeDimension*sizeDimension, 1, inbuffer+i*sizeDimension*sizeDimension, 1, sizeDimension*sizeDimension);
        vDSP_vsub(mean, 1, vector+i*sizeDimension*sizeDimension, 1, vector+i*sizeDimension*sizeDimension, 1, sizeDimension*sizeDimension);
    }
    //vDSP_vfixru8(inbuffer+sizeDimension*sizeDimension,1,vector,1,sizeDimension*sizeDimension*num);
    //free(inbuffer);
}

+(void)calculateAtransposeTimesAFromVector:(RawType *)input toOutputVector:(RawType *)output withNumberOfImages:(NSUInteger)num {
    float* inputTranspose = calloc(sizeDimension*sizeDimension*num, sizeof(float));
    //float* A = calloc(sizeDimension*sizeDimension*num, sizeof(float));
    //float* outbuff = calloc(num*num, sizeof(float));
    //vDSP_vfltu8(input, 1, A, 1, sizeDimension*sizeDimension*num);
    vDSP_mtrans(input, 1, inputTranspose, 1, num, sizeDimension*sizeDimension);
    vDSP_mmul(inputTranspose, 1, input, 1, output, 1, num, num, sizeDimension*sizeDimension);
    //vDSP_vfixru8(outbuff, 1, output, 1, num*num); // MUST TEST
    free(inputTranspose);
}

@end
