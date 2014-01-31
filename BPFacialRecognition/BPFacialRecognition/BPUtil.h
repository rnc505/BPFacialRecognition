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

@interface BPUtil : NSObject

+(UIImage*)resizedImageFromImage:(UIImage*)image;
+(UIImage *)grayscaledImageFromImage:(UIImage *)image;
+(vImage_Buffer)vImageFromUIImage:(UIImage*)image;
+(void)cleanupvImage:(vImage_Buffer)vImage;

+(void)copyVectorFrom:(Byte*)input toVector:(Byte*)output offset:(NSInteger)offset;
+(void)calculateMeanOfVectorFrom:(Byte*)input toVector:(Byte*)output ofHeight:(NSUInteger)height ofWidth:(NSUInteger)width;
@end
