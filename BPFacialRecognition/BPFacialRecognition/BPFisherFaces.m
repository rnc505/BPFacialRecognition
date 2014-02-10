//
//  BPFisherFaces.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 2/9/14.
//  Copyright (c) 2014 BP. All rights reserved.
//


#import "BPFisherFaces.h"
#import <UIKit/UIKit.h>
#import "BPRecognizerCPUOperator.h"
#import "UIImage+Utils.h"
@interface BPFisherFaces ()
@property (nonatomic, weak) id<BPFisherFacesDataSource> dataSource;
@property (nonatomic, retain) BPRecognizerCPUOperator *operator;
-(RawType*)createImageMatrixWithNumberOfImages:(NSUInteger)numberOfImages;
-(void)normalizeImageMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages;
-(RawType*)createSurrogateCovarianceFromMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages;
@end

@implementation BPFisherFaces
+(BPFisherFaces *)createFisherFaceAlgorithmWithDataSource:(id<BPFisherFacesDataSource>)dataSource {
    
    BPFisherFaces* algorithm = [BPFisherFaces new];
    [algorithm setDataSource:dataSource];
    [algorithm setOperator:[BPRecognizerCPUOperator new]];
    return algorithm;
    
}
-(void)train {
    NSUInteger numberOfImages = [_dataSource totalNumberOfImages];
    
    /*
        Create sizeDimension*sizeDimension x numberOfImages matrix from all of the images. 
            -   Returns a raw byte array that we must take care of freeing.
     */
    RawType* oneDVector = [self createImageMatrixWithNumberOfImages:numberOfImages];
    
    /*
        Normalize each sizeDimension*sizeDimension column of the matrix by calculating the mean of all numberOfImages columns and subtracting it from each column of the matrix
     */
    [self normalizeImageMatrix:oneDVector withNumberOfImages:numberOfImages];
    
    /*
        Create numberOfImages x numberOfImages matrix, by multiplying the matrix above's tranpose by itself untransposed (At x A). This is because the important eigenvalues of A x At are the eigenvalues of At x A. 
            -   Returns raw byte array that we must take care of freeing.
     */
    RawType* surrogateCovariance = [self createSurrogateCovarianceFromMatrix:oneDVector withNumberOfImages:numberOfImages];
}

-(BPRecognitionResult *)recognizeImage:(UIImage *)image {
    
    return nil;
}

-(RawType*)createImageMatrixWithNumberOfImages:(NSUInteger)numberOfImages {
    RawType* retVal = (RawType*) calloc(kSizeDimension * kSizeDimension * numberOfImages, sizeof(float));
    int currentPosition = 0;
    for (UIImage* img in [_dataSource totalImageSet]) {
        float* vImg = [img vImageDataWithFloats];
        [_operator copyVector:vImg toVector:retVal numberOfElements:kSizeDimension*kSizeDimension offset:currentPosition sizeOfType:sizeof(RawType)];
        ++currentPosition;
        free(vImg);
    }
    return retVal;
}
-(void)normalizeImageMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages {
    RawType* mean = (RawType*) calloc(kSizeDimension*kSizeDimension, sizeof(float));
    [_operator columnWiseMeanOfFloatMatrix:matrix toFloatVector:mean columnHeight:kSizeDimension*kSizeDimension rowWidth:numberOfImages freeInput:NO];
    for (int i = 0; i < numberOfImages; ++i) {
        [_operator subtractFloatVector:mean fromFloatVector:(matrix+i*kSizeDimension*kSizeDimension) numberOfElements:kSizeDimension*kSizeDimension freeInput:NO];
    }

}
-(RawType*)createSurrogateCovarianceFromMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages {
    RawType* surrogate = (RawType*) calloc(numberOfImages*numberOfImages, sizeof(float));
    
    [_operator multiplyFloatMatrix:matrix withFloatMatrix:matrix product:surrogate matrixOneColumnHeight:numberOfImages matrixOneRowWidth:kSizeDimension*kSizeDimension matrixTwoRowWidth:numberOfImages freeInputs:NO];
    return surrogate;
}
@end
