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

typedef unsigned char Byte;

+(UIImage*)resizedImageFromImage:(UIImage*)image;
+(UIImage *)grayscaledImageFromImage:(UIImage *)image;
+(vImage_Buffer)vImageFromUIImage:(UIImage*)image;
+(void)cleanupvImage:(vImage_Buffer)vImage;

@end
