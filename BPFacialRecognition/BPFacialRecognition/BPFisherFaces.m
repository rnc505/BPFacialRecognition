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
@property (nonatomic, retain) NSData *meanImage;
@property (nonatomic, retain) NSData *covarianceEigenvectors;
@property (nonatomic, retain) NSData *largestEigenvectorsOfWork;
@property (nonatomic, retain) NSData *projectedImages;


-(RawType*)createImageMatrixWithNumberOfImages:(NSUInteger)numberOfImages;
-(RawType*)normalizeImageMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages;
-(RawType*)createSurrogateCovarianceFromMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages;
-(void)calculateEigenvalues:(RawType*)eigenvalues eigenvectors:(RawType*)eigenvectors fromSymmetricInputMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
-(RawType*)calculateEigenvectorsFromSymmetricInputMatrix:(RawType*)matrix fromCovarianceMatrix:(RawType*)covariance withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
-(RawType*)projectImageVectors:(RawType*)matrix ontoEigenspace:(RawType*)eigenspace withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople withEigenspaceDimensions:(CGSize)dimensions;
-(void)calculateMeanOfEachClassFromEigenspace:(RawType*)eigenspace intoScatterWithinMatrix:(RawType*)Sw intoScatterBetweenMatrix:(RawType*)Sb withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
-(void)calculateEigenvalue:(RawType*)eigenvalues eigenvectors:(RawType*)eigenvectors fromNonsymmetricInputMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
-(RawType*)calculateEigenvectorsFromNonsymmetricInputMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
-(RawType*)calculateEigenvectorsFromScatterWithin:(RawType*)Sw fromScatterBetween:(RawType*)Sb withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
-(RawType*)projectImageVectors:(float*)matrix ontoFisherLinearSpace:(float*)fisherSpace withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
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
    RawType* mean = [self normalizeImageMatrix:oneDVector withNumberOfImages:numberOfImages];
    
    /*
        Create numberOfImages x numberOfImages matrix, by multiplying the matrix above's tranpose by itself untransposed (At x A). This is because the important eigenvalues of A x At are the eigenvalues of At x A. 
            -   Returns raw byte array that we must take care of freeing.
     */
    RawType* surrogateCovariance = [self createSurrogateCovarianceFromMatrix:oneDVector withNumberOfImages:numberOfImages];
    
    /*
     
        Calculate eigenvalues and eigenvectors of the surrogateCovariance matrix. Only take the number of photos - number of people eigenvalues and corresponding eigenvectors. Return valvue is a kSizeDimension*kSizeDimesion x (Number Of images - Number of People).
            -   Returns raw byte array that we must take care of freeing.
     
     */
    
    RawType* eigenvectors = [self calculateEigenvectorsFromSymmetricInputMatrix:oneDVector fromCovarianceMatrix:surrogateCovariance withNumberOfImages:numberOfImages withNumberOfPeople:[_dataSource totalNumberOfPeople]];
    
    
    /*
        Project image vectors onto the eigenspace. Return value is a (number of images - number of people) x number of Images
     */
    
    RawType* PCA_Projection = [self projectImageVectors:oneDVector ontoEigenspace:eigenvectors withNumberOfImages:numberOfImages withNumberOfPeople:[_dataSource totalNumberOfPeople] withEigenspaceDimensions:CGSizeMake((numberOfImages - [_dataSource totalNumberOfPeople]), kSizeDimension*kSizeDimension)];
    
    
    /*
     
        Calculate the mean of each class (person) in the eigenspace. Need two matrices returned, both of which are (number of images - number of people) x (number of images - number of people). These matrices are the scatter within classes and between classes
     
     */
    
    RawType *scatterWithin = calloc((numberOfImages-[_dataSource totalNumberOfPeople])*(numberOfImages-[_dataSource totalNumberOfPeople]), sizeof(RawType));
    RawType *scatterBetween = calloc((numberOfImages-[_dataSource totalNumberOfPeople])*(numberOfImages-[_dataSource totalNumberOfPeople]), sizeof(RawType));
    
    [self calculateMeanOfEachClassFromEigenspace:PCA_Projection intoScatterWithinMatrix:scatterWithin intoScatterBetweenMatrix:scatterBetween withNumberOfImages:numberOfImages withNumberOfPeople:[_dataSource totalNumberOfPeople]];
    
    /*
     
        Calculate Fisher's Linear Discriminant. Returns eigenvectors of J work Function = inv(Sw) * Sb
     
     */
    
    RawType* J_Eigenvectors = [self calculateEigenvectorsFromScatterWithin:scatterWithin fromScatterBetween:scatterBetween withNumberOfImages:numberOfImages withNumberOfPeople:[_dataSource totalNumberOfPeople]];

    /*
     
        Project Images on to linear eigenspace.
     
     */
    
    
    RawType* Projected_Images = [self projectImageVectors:PCA_Projection ontoFisherLinearSpace:J_Eigenvectors withNumberOfImages:numberOfImages withNumberOfPeople:[_dataSource totalNumberOfPeople]];
    
    
    _meanImage = [NSData dataWithBytes:mean length:sizeof(RawType)*kSizeDimension*kSizeDimension];
    _covarianceEigenvectors = [NSData dataWithBytes:eigenvectors length:sizeof(RawType)*kSizeDimension*kSizeDimension*(numberOfImages-[_dataSource totalNumberOfPeople])];
    _largestEigenvectorsOfWork = [NSData dataWithBytes:J_Eigenvectors length:sizeof(RawType)*(numberOfImages-[_dataSource totalNumberOfPeople])*([_dataSource totalNumberOfPeople] - 1)];
    _projectedImages = [NSData dataWithBytes:Projected_Images length:([_dataSource totalNumberOfPeople] - 1)*numberOfImages];
    
    
    free(Projected_Images);
    free(J_Eigenvectors);
    free(scatterBetween);
    free(scatterWithin);
    free(PCA_Projection);
    free(eigenvectors);
    free(surrogateCovariance);
    free(mean);
    free(oneDVector);
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
-(RawType*)normalizeImageMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages {
    RawType* mean = (RawType*) calloc(kSizeDimension*kSizeDimension, sizeof(float));
    [_operator columnWiseMeanOfFloatMatrix:matrix toFloatVector:mean columnHeight:kSizeDimension*kSizeDimension rowWidth:numberOfImages freeInput:NO];
    for (int i = 0; i < numberOfImages; ++i) {
        [_operator subtractFloatVector:mean fromFloatVector:(matrix+i*kSizeDimension*kSizeDimension) numberOfElements:kSizeDimension*kSizeDimension freeInput:NO];
    }
    return mean;
}
-(RawType*)createSurrogateCovarianceFromMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages {
    RawType* surrogate = (RawType*) calloc(numberOfImages*numberOfImages, sizeof(float));
    RawType* matrixTranspose = calloc(kSizeDimension*kSizeDimension*numberOfImages, sizeof(RawType));
    [_operator transposeFloatMatrix:matrix transposed:matrixTranspose columnHeight:kSizeDimension*kSizeDimension rowWidth:numberOfImages freeInput:NO];
    [_operator multiplyFloatMatrix:matrixTranspose withFloatMatrix:matrix product:surrogate matrixOneColumnHeight:numberOfImages matrixOneRowWidth:kSizeDimension*kSizeDimension matrixTwoRowWidth:numberOfImages freeInputs:NO];
    free(matrixTranspose);
    return surrogate;
}

-(RawType*)calculateEigenvectorsFromSymmetricInputMatrix:(RawType*)matrix fromCovarianceMatrix:(RawType*)covariance withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
    RawType* eigenvalues = calloc(numberOfImages-numberOfPeople, sizeof(RawType));
    RawType* eigenvectors = calloc((numberOfImages-numberOfPeople)*numberOfImages, sizeof(RawType));
    
    [self calculateEigenvalues:eigenvalues eigenvectors:eigenvectors fromSymmetricInputMatrix:covariance withNumberOfImages:numberOfImages withNumberOfPeople:numberOfPeople];
    
    RawType* outputEigenvectors = calloc(kSizeDimension*kSizeDimension*(numberOfImages-numberOfPeople), sizeof(RawType));
    
    [_operator multiplyFloatMatrix:matrix withFloatMatrix:eigenvectors product:outputEigenvectors matrixOneColumnHeight:kSizeDimension*kSizeDimension matrixOneRowWidth:numberOfImages matrixTwoRowWidth:(numberOfImages-numberOfPeople) freeInputs:NO];
    free(eigenvalues); free(eigenvectors);
    return outputEigenvectors;
    
}

-(void)calculateEigenvalues:(RawType*)eigenvalues eigenvectors:(RawType*)eigenvectors fromSymmetricInputMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
    [_operator eigendecomposeSymmetricFloatMatrix:matrix intoEigenvalues:eigenvalues eigenvectors:eigenvectors numberOfImportantValues:(numberOfImages-numberOfPeople) matrixDimension:numberOfImages freeInput:NO];
    
}

-(RawType*)projectImageVectors:(RawType*)matrix ontoEigenspace:(RawType*)eigenspace withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople withEigenspaceDimensions:(CGSize)dimensions
 {
    
    RawType* projection = calloc((numberOfImages - numberOfPeople)*numberOfImages, sizeof(RawType));
     RawType* eigenspaceTranspose = calloc(dimensions.width * dimensions.height, sizeof(RawType));
     
     [_operator transposeFloatMatrix:eigenspace transposed:eigenspaceTranspose columnHeight:dimensions.height rowWidth:dimensions.width freeInput:NO];
     
     [_operator multiplyFloatMatrix:eigenspaceTranspose withFloatMatrix:matrix product:projection matrixOneColumnHeight:dimensions.width matrixOneRowWidth:kSizeDimension*kSizeDimension matrixTwoRowWidth:numberOfImages freeInputs:NO];
     
     free(eigenspaceTranspose);
     return projection;
}

-(void)calculateEigenvalue:(RawType*)eigenvalues eigenvectors:(RawType*)eigenvectors fromNonsymmetricInputMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
    [_operator eigendecomposeFloatMatrix:matrix intoEigenvalues:eigenvalues eigenvectors:eigenvectors numberOfImportantValues:(numberOfImages-numberOfPeople) matrixDimension:(numberOfImages-numberOfPeople) freeInput:NO];
}

-(RawType*)calculateEigenvectorsFromNonsymmetricInputMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
    RawType* eigenvalues = calloc(numberOfImages-numberOfPeople, sizeof(RawType));
    RawType* eigenvectors = calloc((numberOfImages-numberOfPeople)*(numberOfImages-numberOfPeople), sizeof(RawType));
    [self calculateEigenvalue:eigenvalues eigenvectors:eigenvectors fromNonsymmetricInputMatrix:matrix withNumberOfImages:numberOfImages withNumberOfPeople:numberOfPeople];
    free(eigenvalues);
    return eigenvectors;
    
}

-(void)zeroBuffer:(RawType*)buffer numberOfValues:(NSUInteger)num {
    [_operator clearFloatMatrix:buffer numberOfElements:num];
}

-(void)calculateMeanOfEachClassFromEigenspace:(RawType*)eigenspace intoScatterWithinMatrix:(RawType*)Sw intoScatterBetweenMatrix:(RawType*)Sb withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
    RawType* eigenspaceMean = calloc(numberOfImages - numberOfPeople, sizeof(RawType));
    [_operator columnWiseMeanOfFloatMatrix:eigenspace toFloatVector:eigenspaceMean columnHeight:(numberOfImages - numberOfPeople) rowWidth:numberOfImages freeInput:NO];
    
    RawType* innerMean = calloc((numberOfImages - numberOfPeople)*numberOfPeople, sizeof(RawType));
    
    RawType* scatterBuffer = calloc((numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople), sizeof(RawType));
    RawType* intermediate = calloc((numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople), sizeof(RawType));
    RawType* multiplicationTemporary = calloc((numberOfImages - numberOfPeople), sizeof(RawType));
    RawType* multiplicationTemporaryTranspose = calloc((numberOfImages - numberOfPeople), sizeof(RawType));
    RawType* scatterBetweenBuffer = calloc(numberOfImages - numberOfPeople, sizeof(RawType));
    
    NSArray* indices = [_dataSource personImageIndexes];
    for (int i = 0; i < numberOfPeople; ++i) {
        
        int startIndex = [indices[i] unsignedIntegerValue];
        int endIndex = [indices[i+1] unsignedIntegerValue] - 1;
        RawType* currentLocationInput = eigenspace + startIndex*(numberOfImages-numberOfPeople)*numberOfImages;
        RawType* currentLocationOutput = innerMean + startIndex*(numberOfImages-numberOfPeople);
        [_operator columnWiseMeanOfFloatMatrix:currentLocationInput toFloatVector:currentLocationOutput columnHeight:(numberOfImages-numberOfPeople) rowWidth:(endIndex-startIndex) freeInput:NO];
        for(int j = startIndex; j <= endIndex; ++j) {
            [_operator copyVector:eigenspace+j*(numberOfImages-numberOfPeople) toVector:multiplicationTemporary numberOfElements:(numberOfImages-numberOfPeople) offset:0 sizeOfType:sizeof(RawType)];
            
            [_operator subtractFloatVector:currentLocationOutput fromFloatVector:multiplicationTemporary numberOfElements:(numberOfImages-numberOfPeople) freeInput:NO];
            
//            [_operator transposeFloatMatrix:multiplicationTemporary transposed:multiplicationTemporaryTranspose columnHeight:(numberOfImages-numberOfPeople) rowWidth:1 freeInput:NO];
            
            [_operator multiplyFloatMatrix:multiplicationTemporary withFloatMatrix:multiplicationTemporary product:intermediate matrixOneColumnHeight:(numberOfImages-numberOfPeople) matrixOneRowWidth:1 matrixTwoRowWidth:(numberOfImages-numberOfPeople) freeInputs:NO];
            
            [_operator addFloatMatrix:scatterBuffer toFloatMatrix:intermediate intoResultFloatMatrix:scatterBuffer columnHeight:(numberOfImages-numberOfPeople) rowWidth:(numberOfImages-numberOfPeople) freeInput:NO];
            
        }
        [_operator addFloatMatrix:Sw toFloatMatrix:scatterBuffer intoResultFloatMatrix:Sw columnHeight:(numberOfImages-numberOfPeople) rowWidth:(numberOfImages-numberOfPeople) freeInput:NO];
        
        [_operator copyVector:innerMean+i*(numberOfImages-numberOfPeople) toVector:scatterBetweenBuffer numberOfElements:(numberOfImages-numberOfPeople) offset:0 sizeOfType:sizeof(RawType)];
        
        [_operator subtractFloatVector:eigenspaceMean fromFloatVector:scatterBetweenBuffer numberOfElements:(numberOfImages-numberOfPeople) freeInput:NO];
//        [_operator transposeFloatMatrix:multiplicationTemporary transposed:multiplicationTemporaryTranspose columnHeight:(numberOfImages-numberOfPeople) rowWidth:1 freeInput:NO];
        
        [_operator multiplyFloatMatrix:scatterBetweenBuffer withFloatMatrix:scatterBetweenBuffer product:intermediate matrixOneColumnHeight:(numberOfImages-numberOfPeople) matrixOneRowWidth:1 matrixTwoRowWidth:(numberOfImages-numberOfPeople) freeInputs:NO];
        
        [_operator addFloatMatrix:Sb toFloatMatrix:intermediate intoResultFloatMatrix:Sb columnHeight:(numberOfImages-numberOfPeople) rowWidth:(numberOfImages-numberOfPeople) freeInput:NO];
        
        [self zeroBuffer:scatterBuffer numberOfValues:(numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople)];
        
    }
    
    free(scatterBetweenBuffer);
    free(multiplicationTemporaryTranspose);
    free(multiplicationTemporary);
    free(intermediate);
    free(scatterBuffer);
    free(innerMean);
    free(eigenspaceMean);
}

-(RawType*)calculateEigenvectorsFromScatterWithin:(RawType*)Sw fromScatterBetween:(RawType*)Sb withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
    RawType* SwInverted = calloc((numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople), sizeof(RawType));
    [_operator invertFloatMatrix:Sw intoResult:SwInverted matrixDimension:(numberOfImages - numberOfPeople) freeInput:NO];
    
    RawType* JCostFunction = calloc((numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople), sizeof(RawType));
    [_operator multiplyFloatMatrix:SwInverted withFloatMatrix:Sb product:JCostFunction matrixOneColumnHeight:(numberOfImages - numberOfPeople) matrixOneRowWidth:(numberOfImages - numberOfPeople) matrixTwoRowWidth:(numberOfImages - numberOfPeople) freeInputs:NO];
    
    
    RawType* eigenvectors = [self calculateEigenvectorsFromNonsymmetricInputMatrix:JCostFunction withNumberOfImages:numberOfImages withNumberOfPeople:numberOfPeople];
    
    RawType *outputEigenvectors = calloc((numberOfImages-numberOfPeople)*(numberOfPeople-1), sizeof(RawType));
    
    for (int i = ((numberOfImages-numberOfPeople)-(numberOfPeople-1)); i < (numberOfImages-numberOfPeople); ++i) {
        for (int j = 0; j < (numberOfImages-numberOfPeople)*(numberOfImages-numberOfPeople); j+=(numberOfImages-numberOfPeople)) {
            
            outputEigenvectors[i+j] = eigenvectors[i+j];
            
        }
    }
    
    free(eigenvectors);
    free(JCostFunction);
    free(SwInverted);
    
    return outputEigenvectors;
    
}

-(RawType*)projectImageVectors:(float*)matrix ontoFisherLinearSpace:(float*)fisherSpace withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
    RawType* fisherEigenvectorsTranspose = calloc((numberOfPeople-1)*(numberOfImages-numberOfPeople), sizeof(RawType));
    
    [_operator transposeFloatMatrix:fisherSpace transposed:fisherEigenvectorsTranspose columnHeight:(numberOfImages-numberOfPeople) rowWidth:(numberOfPeople-1) freeInput:NO];
    
    RawType* projectedImages = calloc((numberOfPeople-1)*numberOfImages, sizeof(RawType));
    
    [_operator multiplyFloatMatrix:fisherEigenvectorsTranspose withFloatMatrix:matrix product:projectedImages matrixOneColumnHeight:(numberOfPeople-1) matrixOneRowWidth:(numberOfImages-numberOfPeople) matrixTwoRowWidth:numberOfImages freeInputs:NO];
    
    free(fisherEigenvectorsTranspose);
    return projectedImages;
    
}

@end
