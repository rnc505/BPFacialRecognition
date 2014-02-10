//
//  UIImage+Utils.h
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/30/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utilities)
+(UIImage*)imageWithFilename:(NSString*)filename withExtension:(NSString*)fileExtension;
-(UIImage*)grayscaledImage;
-(UIImage*)resizedSquareImageOfDimension:(NSUInteger)dimension;
-(UIImage*)resizedAndGrayscaledSquareImageOfDimension:(NSUInteger)dimension;
-(void*)vImageDataWithFloats;
+(UIImage*)imageWithRawFloatFloats:(float*)rawBytesSF WithFloatAndOfSquareDimension:(NSUInteger)dimension;

@end