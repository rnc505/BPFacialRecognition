//
//  BPUtil.h
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/30/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>

#define sizeDimension 512
#define imageSize (CGSize){sizeDimension, sizeDimension}
#define RawType double
@interface BPUtil : NSObject

+(UIImage*)resizedImageFromImage:(UIImage*)image;
+(UIImage *)grayscaledImageFromImage:(UIImage *)image;
+(vImage_Buffer)vImageFromUIImage:(UIImage*)image;
+(void)cleanupvImage:(vImage_Buffer)vImage;

+(void)copyVectorFrom:(void*)input toVector:(void*)output offset:(NSInteger)offset sizeOfType:(NSUInteger)size;
+(void)calculateMeanOfVectorFrom:(RawType*)input toVector:(RawType*)output ofHeight:(NSUInteger)height ofWidth:(NSUInteger)width;
+(void)subtractMean:(RawType*)mean fromVector:(RawType*)vector withNumberOfImages:(NSInteger)num;
+(void)calculateAtransposeTimesAFromVector:(RawType*)input toOutputVector:(RawType*)output withNumberOfImages:(NSUInteger)num;
+(void)calculateEigenvectors:(RawType*)eigenvectors eigenvalues:(RawType*)eigenvalues fromVector:(RawType*)vector withNumberOfImages:(NSUInteger)num;
@end
