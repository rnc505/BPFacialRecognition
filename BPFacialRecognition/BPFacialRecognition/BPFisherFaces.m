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
-(void)calculateEigenvalues:(RawType*)eigenvalues eigenvectors:(RawType*)eigenvectors fromInputMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
-(RawType*)calculateEigenvectorsFromInputMatrix:(RawType*)matrix fromCovarianceMatrix:(RawType*)covariance withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;

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
    
    /*
     
        Calculate eigenvalues and eigenvectors of the surrogateCovariance matrix. Only take the number of photos - number of people eigenvalues and corresponding eigenvectors.
     
     */
    
    RawType* eigenvectors = [self calculateEigenvectorsFromInputMatrix:oneDVector fromCovarianceMatrix:surrogateCovariance withNumberOfImages:numberOfImages withNumberOfPeople:[_dataSource totalNumberOfPeople]];
    
    
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
    RawType* matrixTranspose = calloc(kSizeDimension*kSizeDimension*numberOfImages, sizeof(RawType));
    [_operator transposeFloatMatrix:matrix transposed:matrixTranspose columnHeight:kSizeDimension*kSizeDimension rowWidth:numberOfImages freeInput:NO];
    [_operator multiplyFloatMatrix:matrixTranspose withFloatMatrix:matrix product:surrogate matrixOneColumnHeight:numberOfImages matrixOneRowWidth:kSizeDimension*kSizeDimension matrixTwoRowWidth:numberOfImages freeInputs:NO];
    free(matrixTranspose);
    return surrogate;
}

-(RawType*)calculateEigenvectorsFromInputMatrix:(RawType*)matrix fromCovarianceMatrix:(RawType*)covariance withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
    RawType* eigenvalues = calloc(numberOfImages-numberOfPeople, sizeof(RawType));
    RawType* eigenvectors = calloc((numberOfImages-numberOfPeople)*numberOfImages, sizeof(RawType));
    
    [self calculateEigenvalues:eigenvalues eigenvectors:eigenvectors fromInputMatrix:covariance withNumberOfImages:numberOfImages withNumberOfPeople:numberOfPeople];
    
    RawType* outputEigenvectors = calloc(kSizeDimension*kSizeDimension*(numberOfImages-numberOfPeople), sizeof(RawType));
    
    [_operator multiplyFloatMatrix:matrix withFloatMatrix:eigenvectors product:outputEigenvectors matrixOneColumnHeight:kSizeDimension*kSizeDimension matrixOneRowWidth:numberOfImages matrixTwoRowWidth:(numberOfImages-numberOfPeople) freeInputs:NO];
    free(eigenvalues); free(eigenvectors);
    return outputEigenvectors;
    
}

-(void)calculateEigenvalues:(RawType*)eigenvalues eigenvectors:(RawType*)eigenvectors fromInputMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
    [_operator eigendecomposeFloatMatrix:matrix intoEigenvalues:eigenvalues eigenvectors:eigenvectors numberOfImportantValues:(numberOfImages-numberOfPeople) matrixDimension:numberOfImages freeInput:NO];
    
    
    
}
@end
