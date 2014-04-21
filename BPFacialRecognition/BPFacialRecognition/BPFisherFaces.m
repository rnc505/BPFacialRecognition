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
#import "BPMatrix.h"
#pragma mark - Private Interface
@interface BPFisherFaces ()
@property (nonatomic, weak) id<BPFisherFacesDataSource> dataSource;
@property (nonatomic, retain) BPRecognizerCPUOperator *operator;
@property (nonatomic, retain) BPMatrix *meanImage;
@property (nonatomic, retain) BPMatrix *covarianceEigenvectors;
@property (nonatomic, retain) BPMatrix *largestEigenvectorsOfWork;
@property (nonatomic, retain) BPMatrix *projectedImages;

#pragma mark -  Private Recognizer Interface
-(BPMatrix*)projectImageToRecognize:(BPMatrix*)testImg withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
-(BPMatrix*)euclideanDistancesBetweenProjectedTestImage:(BPMatrix*)testImg projectedTrainingImages:(BPMatrix*)training withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;

#pragma mark - Private Trainer Interface
-(BPMatrix*)createImageMatrixWithNumberOfImages:(NSUInteger)numberOfImages;
-(BPMatrix*)normalizeImageMatrix:(BPMatrix*)matrix withNumberOfImages:(NSUInteger)numberOfImages;
-(BPMatrix*)createSurrogateCovarianceFromMatrix:(BPMatrix*)matrix withNumberOfImages:(NSUInteger)numberOfImages;
//-(void)calculateEigenvalues:(BPMatrix*)eigenvalues eigenvectors:(BPMatrix*)eigenvectors fromSymmetricInputMatrix:(BPMatrix*)matrix withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
-(BPMatrix*)calculateEigenvectorsFromSymmetricInputMatrix:(BPMatrix*)matrix fromCovarianceMatrix:(BPMatrix*)covariance withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
-(BPMatrix*)projectImageVectors:(BPMatrix*)matrix ontoEigenspace:(BPMatrix*)eigenspace withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople withEigenspaceDimensions:(CGSize)dimensions;
-(void)calculateMeanOfEachClassFromEigenspace:(BPMatrix*)eigenspace intoScatterWithinMatrix:(BPMatrix*)Sw intoScatterBetweenMatrix:(BPMatrix*)Sb withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
//-(void)calculateEigenvalue:(BPMatrix*)eigenvalues eigenvectors:(BPMatrix*)eigenvectors fromNonsymmetricInputMatrix:(BPMatrix*)matrix withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
//-(BPMatrix*)calculateEigenvectorsFromNonsymmetricInputMatrix:(BPMatrix*)matrix withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
-(BPMatrix*)calculateEigenvectorsFromScatterWithin:(BPMatrix*)Sw fromScatterBetween:(BPMatrix*)Sb withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;
-(BPMatrix*)projectImageVectors:(BPMatrix*)matrix ontoFisherLinearSpace:(BPMatrix*)fisherSpace withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople;

@end
#pragma mark - Public Implementation
@implementation BPFisherFaces
+(BPFisherFaces *)createFisherFaceAlgorithmWithDataSource:(id<BPFisherFacesDataSource>)dataSource {
    
    BPFisherFaces* algorithm = [BPFisherFaces new];
    [algorithm setDataSource:dataSource];
    [algorithm setOperator:[BPRecognizerCPUOperator new]];
    [algorithm setMeanImage:nil];
    [algorithm setCovarianceEigenvectors:nil];
    [algorithm setLargestEigenvectorsOfWork:nil];
    [algorithm setProjectedImages:nil];
    return algorithm;
    
}
-(void)train {
    NSUInteger numberOfImages = [_dataSource totalNumberOfImages];
    NSUInteger numberOfPeople = [_dataSource totalNumberOfPeople];
    /*
        Create sizeDimension*sizeDimension x numberOfImages matrix from all of the images. 
            -   Returns a raw byte array that we must take care of freeing.
     */
    BPMatrix* oneDVector = [self createImageMatrixWithNumberOfImages:numberOfImages];
    
    /*
        Normalize each sizeDimension*sizeDimension column of the matrix by calculating the mean of all numberOfImages columns and subtracting it from each column of the matrix
     */
    BPMatrix* mean = [self normalizeImageMatrix:oneDVector withNumberOfImages:numberOfImages];
    
    /*
        Create numberOfImages x numberOfImages matrix, by multiplying the matrix above's tranpose by itself untransposed (At x A). This is because the important eigenvalues of A x At are the eigenvalues of At x A. 
            -   Returns raw byte array that we must take care of freeing.
     */
    BPMatrix* surrogateCovariance = [self createSurrogateCovarianceFromMatrix:oneDVector withNumberOfImages:numberOfImages];
    
    /*
     
        Calculate eigenvalues and eigenvectors of the surrogateCovariance matrix. Only take the number of photos - number of people eigenvalues and corresponding eigenvectors. Return valvue is a kSizeDimension*kSizeDimesion x (Number Of images - Number of People).
            -   Returns raw byte array that we must take care of freeing.
     
     */
    
    BPMatrix* eigenvectors = [self calculateEigenvectorsFromSymmetricInputMatrix:oneDVector fromCovarianceMatrix:surrogateCovariance withNumberOfImages:numberOfImages withNumberOfPeople:numberOfPeople];
    
    
    /*
        Project image vectors onto the eigenspace. Return value is a (number of images - number of people) x number of Images
     */
    
    BPMatrix* PCA_Projection = [self projectImageVectors:oneDVector ontoEigenspace:eigenvectors withNumberOfImages:numberOfImages withNumberOfPeople:numberOfPeople withEigenspaceDimensions:CGSizeMake((numberOfImages - numberOfPeople), kSizeDimension*kSizeDimension)];
    
    
    /*
     
        Calculate the mean of each class (person) in the eigenspace. Need two matrices returned, both of which are (number of images - number of people) x (number of images - number of people). These matrices are the scatter within classes and between classes
     
     */
//    
//    RawType* scatterWithin __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&scatterWithin, kAlignment, (numberOfImages-numberOfPeople)*(numberOfImages-numberOfPeople)*sizeof(RawType)));
    
//    RawType *scatterWithin = calloc((numberOfImages-numberOfPeople)*(numberOfImages-numberOfPeople), sizeof(RawType));
    
//    RawType* scatterBetween __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&scatterBetween, kAlignment, (numberOfImages-numberOfPeople)*(numberOfImages-numberOfPeople)*sizeof(RawType)));
    
    BPMatrix* scatterWithin = nil;
    BPMatrix* scatterBetween = nil;
    
    
//    RawType *scatterBetween = calloc((numberOfImages-numberOfPeople)*(numberOfImages-numberOfPeople), sizeof(RawType));
    
    [self calculateMeanOfEachClassFromEigenspace:PCA_Projection intoScatterWithinMatrix:scatterWithin intoScatterBetweenMatrix:scatterBetween withNumberOfImages:numberOfImages withNumberOfPeople:numberOfPeople];
    /*
     
        Calculate Fisher's Linear Discriminant. Returns eigenvectors of J work Function = inv(Sw) * Sb
     
     */
    
    BPMatrix* J_Eigenvectors = [self calculateEigenvectorsFromScatterWithin:scatterWithin fromScatterBetween:scatterBetween withNumberOfImages:numberOfImages withNumberOfPeople:numberOfPeople];

    /*
     
        Project Images on to linear eigenspace.
     
     */
    
    
    BPMatrix* Projected_Images = [self projectImageVectors:PCA_Projection ontoFisherLinearSpace:J_Eigenvectors withNumberOfImages:numberOfImages withNumberOfPeople:numberOfPeople];
    
    
    _meanImage = mean;
    _covarianceEigenvectors = eigenvectors;
    _largestEigenvectorsOfWork = J_Eigenvectors;
    _projectedImages = Projected_Images;
    
    
//    free(Projected_Images); Projected_Images = NULL;
//    free(J_Eigenvectors); J_Eigenvectors = NULL;
//    free(scatterBetween); scatterBetween = NULL;
//    free(scatterWithin); scatterWithin = NULL;
//    free(PCA_Projection); PCA_Projection = NULL;
//    free(eigenvectors); eigenvectors = NULL;
//    free(surrogateCovariance); surrogateCovariance = NULL;
//    free(mean); mean = NULL;
//    free(oneDVector); oneDVector = NULL;
}

-(BPPreRecognitionResult*)recognizeImage:(UIImage *)image {
    NSInteger numberOfPeople = [_dataSource totalNumberOfPeople];
    RawType* imageDataRaw __attribute__((aligned(kAlignment))) = [[image resizedAndGrayscaledSquareImageOfDimension:kSizeDimension] vImageDataWithFloats];
    
    BPMatrix* theImage = [BPMatrix matrixWithDimensions:CGSizeMake(kSizeDimension, kSizeDimension) withPrimitiveSize:sizeof(RawType)];
    
    [_operator copyVector:imageDataRaw toVector:[theImage getMutableData] numberOfElements:kSizeDimension*kSizeDimension sizeOfType:sizeof(RawType)];
    
    /*
            Normalize the input image
     */
    
    [theImage subtractedBy:_meanImage];
    
//    [_operator subtractFloatVector:(RawType*)[_meanImage bytes] fromFloatVector:imageData numberOfElements:kSizeDimension*kSizeDimension freeInput:NO];
    
    /*
            Project the image to recognize and get the feature vector.
     */
    
    BPMatrix* projectedImage = [self projectImageToRecognize:theImage withNumberOfImages:[_dataSource totalNumberOfImages] withNumberOfPeople:numberOfPeople];
    
    /*
     
            Get the Euclidean distances between the test image and all of the training images
     */
    
    BPMatrix* distances __attribute__((aligned(kAlignment))) = [self euclideanDistancesBetweenProjectedTestImage:projectedImage projectedTrainingImages:_projectedImages withNumberOfImages:[_dataSource totalNumberOfImages] withNumberOfPeople:numberOfPeople];
    
    RawType minDist = 0.f; unsigned long minIndex = 0;
    vDSP_minvi([distances getData], 1, &minDist, &minIndex, numberOfPeople-1);
    
//    free(distances); distances = NULL;
//    free(projectedImage); projectedImage = NULL;
//    free(imageData); projectedImage = NULL;
    //minIndex contains the index of the person who it is
    BPPreRecognitionResult *result = [BPPreRecognitionResult new];
    result.position = minIndex;
    result.distance = minDist;
    return result;
}

#pragma mark - Private Recognizer Implementation


-(BPMatrix *)projectImageToRecognize:(BPMatrix *)testImg withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
//    RawType* LargestEigenvectorsTranspose __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&LargestEigenvectorsTranspose, kAlignment, (numberOfImages-numberOfPeople)*(numberOfPeople-1)*sizeof(RawType)));
    
    BPMatrix* largestEigenvectorsOfWorkT = [_largestEigenvectorsOfWork transposedNew];
    
//    [_operator transposeFloatMatrix:(RawType*)[_largestEigenvectorsOfWork bytes] transposed:LargestEigenvectorsTranspose columnHeight:(numberOfImages-numberOfPeople) rowWidth:(numberOfPeople-1) freeInput:NO];
    
//    RawType* CovarianceEigenvectorsTranspose __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&CovarianceEigenvectorsTranspose, kAlignment, (numberOfImages-numberOfPeople)*kSizeDimension*kSizeDimension*sizeof(RawType)));
    
//    [_operator transposeFloatMatrix:(RawType*)[_covarianceEigenvectors bytes] transposed:CovarianceEigenvectorsTranspose columnHeight:kSizeDimension*kSizeDimension rowWidth:(numberOfImages-numberOfPeople) freeInput:NO];
    
    BPMatrix* covarianceEigenvectorsT = [_covarianceEigenvectors transposedNew];
    
//    RawType* intermediateMultiplication __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&intermediateMultiplication, kAlignment, (numberOfImages-numberOfPeople)*kSizeDimension*kSizeDimension*sizeof(RawType)));
    
//    [_operator multiplyFloatMatrix:LargestEigenvectorsTranspose withFloatMatrix:CovarianceEigenvectorsTranspose product:intermediateMultiplication matrixOneColumnHeight:numberOfImages-numberOfPeople matrixOneRowWidth:numberOfPeople-1 matrixTwoRowWidth:kSizeDimension*kSizeDimension freeInputs:NO];
    
//    RawType* retVal __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&retVal, kAlignment, (numberOfImages-numberOfPeople)*sizeof(RawType)));
    
//    [_operator multiplyFloatMatrix:intermediateMultiplication withFloatMatrix:testImg product:retVal matrixOneColumnHeight:numberOfImages-numberOfPeople matrixOneRowWidth:kSizeDimension*kSizeDimension matrixTwoRowWidth:1 freeInputs:NO];
    
    BPMatrix* retval = [[largestEigenvectorsOfWorkT multiplyBy:covarianceEigenvectorsT] multiplyBy:testImg];
    
    if([retval width] != 1 || [retval height] != (numberOfImages - numberOfPeople)) {
        @throw @"retval incorrect size";
    }
    
    
//    free(intermediateMultiplication); intermediateMultiplication = NULL;
//    free(CovarianceEigenvectorsTranspose); CovarianceEigenvectorsTranspose = NULL;
//    free(LargestEigenvectorsTranspose); LargestEigenvectorsTranspose = NULL;
    
    return retval;
    
}

-(BPMatrix *)euclideanDistancesBetweenProjectedTestImage:(BPMatrix *)testImg projectedTrainingImages:(BPMatrix *)training withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
//    RawType* distances __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&distances, kAlignment, numberOfImages*sizeof(RawType)));
    
//    RawType* currentTraining __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&currentTraining, kAlignment, (numberOfImages-1)*sizeof(RawType)));
    
//    RawType* tmpTest __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&tmpTest, kAlignment, (numberOfPeople-1)*sizeof(RawType)));
    
    BPMatrix* currentTraining = [BPMatrix matrixWithDimensions:CGSizeMake((numberOfImages-1), 1) withPrimitiveSize:sizeof(RawType)];
    BPMatrix* tmpTest = [BPMatrix matrixWithDimensions:CGSizeMake((numberOfPeople-1), 1) withPrimitiveSize:sizeof(RawType)];
    BPMatrix* distances = [BPMatrix matrixWithDimensions:CGSizeMake(numberOfImages, 1) withPrimitiveSize:sizeof(RawType)];
    for (int i = 0; i < numberOfImages; ++i) {
        
        [currentTraining zeroOutData];
        RawType* cTPointer = [currentTraining getMutableData];
        
        [tmpTest zeroOutData];
        RawType* tTPointer = [tmpTest getMutableData];
        
        [_operator copyVector:[training getMutableData]+i*(numberOfPeople-1) toVector:cTPointer numberOfElements:numberOfPeople-1 sizeOfType:sizeof(RawType)];
        [_operator copyVector:[testImg getMutableData] toVector:tTPointer numberOfElements:numberOfPeople-1 sizeOfType:sizeof(RawType)];
        
        [tmpTest subtractedBy:currentTraining];
        
//        [_operator subtractFloatVector:currentTraining fromFloatVector:tmpTest numberOfElements:numberOfPeople-1 freeInput:NO];
        
        cblas_sscal((int)numberOfPeople-1u, 1.0 / cblas_snrm2((int)numberOfPeople - 1u, [tmpTest getData], 1), [tmpTest getMutableData], 1); // NORMALIZE VECTOR
        
        vDSP_vsq([tmpTest getData], 1, [tmpTest getMutableData], 1, numberOfPeople-1); // square each element
        vDSP_sve([tmpTest getData], 1, [distances getMutableData]+i, numberOfPeople-1); // sum and add this euclidean distance to the array
    }
    
    return distances;
}
#pragma mark - Private Trainer Implementation

-(BPMatrix*)createImageMatrixWithNumberOfImages:(NSUInteger)numberOfImages {
    
    BPMatrix* returnValue = [BPMatrix matrixWithDimensions:CGSizeMake(numberOfImages, kSizeDimension*kSizeDimension) withPrimitiveSize:sizeof(RawType)];
    
    RawType* retVal __attribute__((aligned(kAlignment))) = [returnValue getMutableData];
    //check_alloc_error(posix_memalign((void**)&retVal, kAlignment, kSizeDimension * kSizeDimension * numberOfImages*sizeof(RawType)));
    
//    RawType* retVal = (RawType*) calloc(kSizeDimension * kSizeDimension * numberOfImages, sizeof(float));
    int currentPosition = 0;
    NSArray* totalImageSet = [_dataSource totalImageSet];
    for (UIImage* img in totalImageSet) {
        RawType* vImg __attribute__((aligned(kAlignment))) = [img vImageDataWithFloats];
        [_operator copyVector:vImg toVector:retVal numberOfElements:kSizeDimension*kSizeDimension offset:currentPosition sizeOfType:sizeof(RawType)];
        ++currentPosition;
        free(vImg); vImg = NULL;
    }
    return returnValue;
}
-(BPMatrix*)normalizeImageMatrix:(BPMatrix*)matrix withNumberOfImages:(NSUInteger)numberOfImages {
    
    BPMatrix* mean = [matrix meanOfRows];
    for (int i = 0; i < numberOfImages; ++i) {
//        [matrix subtractedBy:mean];
        [_operator subtractFloatVector:(void*)[mean getData] fromFloatVector:[matrix getMutableData]+i*matrix.height numberOfElements:matrix.height freeInput:NO];
    }
    
//    RawType* mean __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&mean, kAlignment, kSizeDimension*kSizeDimension*sizeof(float)));
////    RawType* mean = (RawType*) calloc(kSizeDimension*kSizeDimension, sizeof(float));
//    [_operator columnWiseMeanOfFloatMatrix:matrix toFloatVector:mean columnHeight:kSizeDimension*kSizeDimension rowWidth:numberOfImages freeInput:NO];
//    for (int i = 0; i < numberOfImages; ++i) {
//        [_operator subtractFloatVector:mean fromFloatVector:(matrix+i*kSizeDimension*kSizeDimension) numberOfElements:kSizeDimension*kSizeDimension freeInput:NO];
//    }
    return mean;
}
-(BPMatrix*)createSurrogateCovarianceFromMatrix:(BPMatrix*)matrix withNumberOfImages:(NSUInteger)numberOfImages {
//    RawType* surrogate __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&surrogate, kAlignment, numberOfImages*numberOfImages*sizeof(float)));

    
    
//    RawType* surrogate = (RawType*) calloc(numberOfImages*numberOfImages, sizeof(float));
//    
//    RawType* matrixTranspose __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&matrixTranspose, kAlignment, kSizeDimension*kSizeDimension*numberOfImages*sizeof(RawType)));
    
    BPMatrix *matrixTransposed = [matrix transposedNew];
    
//    RawType* matrixTranspose = calloc(kSizeDimension*kSizeDimension*numberOfImages, sizeof(RawType));
//    [_operator transposeFloatMatrix:matrix transposed:matrixTranspose columnHeight:kSizeDimension*kSizeDimension rowWidth:numberOfImages freeInput:NO];
//    [_operator multiplyFloatMatrix:matrixTranspose withFloatMatrix:matrix product:surrogate matrixOneColumnHeight:numberOfImages matrixOneRowWidth:kSizeDimension*kSizeDimension matrixTwoRowWidth:numberOfImages freeInputs:NO];
    
    BPMatrix *surrogate = [BPMatrix matrixWithMultiplicationOfMatrixOne:matrixTransposed withMatrixTwo:matrix];
    
    if([surrogate width] != numberOfImages || [surrogate height] != numberOfImages) {
        @throw @"surrogate is wrong size!";
    }
    
    //[BPMatrix matrixWithDimensions:CGSizeMake(numberOfImages, numberOfImages) withPrimitiveSize:sizeof(RawType)];
//    free(matrixTranspose); matrixTranspose = NULL;
    return surrogate;
}

-(BPMatrix*)calculateEigenvectorsFromSymmetricInputMatrix:(BPMatrix*)matrix fromCovarianceMatrix:(BPMatrix*)covariance withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
//    RawType* eigenvalues __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&eigenvalues, kAlignment, (numberOfImages-numberOfPeople)*sizeof(RawType)));
    
//    RawType* eigenvalues = calloc(numberOfImages-numberOfPeople, sizeof(RawType));
    
//    RawType* eigenvectors __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&eigenvectors, kAlignment, (numberOfImages-numberOfPeople)*numberOfImages*sizeof(RawType)));
    
//    RawType* eigenvectors = calloc((numberOfImages-numberOfPeople)*numberOfImages, sizeof(RawType));
    
    
    
//    [_operator transposeFloatMatrix:covariance transposed:covariance columnHeight:numberOfImages rowWidth:numberOfImages freeInput:NO];
//   THIS WASN'T HERE BEFORe [_operator eigendecomposeSymmetricFloatMatrix:matrix intoEigenvalues:eigenvalues eigenvectors:eigenvectors numberOfImportantValues:(numberOfImages-numberOfPeople) matrixDimension:numberOfImages freeInput:NO];
//    [self calculateEigenvalues:eigenvalues eigenvectors:eigenvectors fromSymmetricInputMatrix:covariance withNumberOfImages:numberOfImages withNumberOfPeople:numberOfPeople];
    
    [covariance eigendecomposeIsSymmetric:YES withNumberOfValues:(numberOfImages-numberOfPeople) withNumberOfVectors:(numberOfImages-numberOfPeople)*numberOfImages];
    
//    RawType* outputEigenvectors __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&outputEigenvectors, kAlignment, kSizeDimension*kSizeDimension*(numberOfImages-numberOfPeople)*sizeof(RawType)));
    
//    RawType* outputEigenvectors = calloc(kSizeDimension*kSizeDimension*(numberOfImages-numberOfPeople), sizeof(RawType));
    
<<<<<<< Updated upstream
//    [_operator clearFloatMatrix:outputEigenvectors numberOfElements:kSizeDimension*kSizeDimension*(numberOfImages-numberOfPeople)];
//    [_operator multiplyFloatMatrix:matrix withFloatMatrix:eigenvectors product:outputEigenvectors matrixOneColumnHeight:kSizeDimension*kSizeDimension matrixOneRowWidth:numberOfImages matrixTwoRowWidth:(numberOfImages-numberOfPeople) freeInputs:NO];
=======
    [_operator clearFloatMatrix:outputEigenvectors numberOfElements:kSizeDimension*kSizeDimension*(numberOfImages-numberOfPeople)];
    [_operator multiplyFloatMatrix:matrix
 withFloatMatrix:eigenvectors product:outputEigenvectors matrixOneColumnHeight:kSizeDimension*kSizeDimension matrixOneRowWidth:numberOfImages matrixTwoRowWidth:(numberOfImages-numberOfPeople) freeInputs:NO];
    free(eigenvalues); eigenvalues = NULL;
    free(eigenvectors); eigenvectors = NULL;
    return outputEigenvectors;
>>>>>>> Stashed changes
    
    BPMatrix* outputEigenvectors = [BPMatrix matrixWithMultiplicationOfMatrixOne:matrix withMatrixTwo:[covariance eigenvectors]];
    
    if([outputEigenvectors width] != (numberOfImages-numberOfPeople) || [outputEigenvectors height] != (kSizeDimension*kSizeDimension)) {
        @throw @"Dimensions of output eigenvectors are wrong";
    }
    
//    free(eigenvalues); eigenvalues = NULL;
//    free(eigenvectors); eigenvectors = NULL;
    return outputEigenvectors;
    
}

//-(void)calculateEigenvalues:(RawType*)eigenvalues eigenvectors:(RawType*)eigenvectors fromSymmetricInputMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
//    
//    [_operator eigendecomposeSymmetricFloatMatrix:matrix intoEigenvalues:eigenvalues eigenvectors:eigenvectors numberOfImportantValues:(numberOfImages-numberOfPeople) matrixDimension:numberOfImages freeInput:NO];
//    
//}

-(BPMatrix*)projectImageVectors:(BPMatrix*)matrix ontoEigenspace:(BPMatrix*)eigenspace withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople withEigenspaceDimensions:(CGSize)dimensions
 {
//     RawType* projection __attribute__((aligned(kAlignment))) = NULL;
//     check_alloc_error(posix_memalign((void**)&projection, kAlignment, (numberOfImages-numberOfPeople)*numberOfImages*sizeof(RawType)));
     
//    RawType* projection = calloc((numberOfImages - numberOfPeople)*numberOfImages, sizeof(RawType));
     
//     RawType* eigenspaceTranspose __attribute__((aligned(kAlignment))) = NULL;
//     check_alloc_error(posix_memalign((void**)&eigenspaceTranspose, kAlignment, dimensions.width*dimensions.height*sizeof(RawType)));
     
//     RawType* eigenspaceTranspose = calloc(dimensions.width * dimensions.height, sizeof(RawType));
     
     BPMatrix* eigenspaceTranspose = [eigenspace transposedNew];
     
//     [_operator transposeFloatMatrix:eigenspace transposed:eigenspaceTranspose columnHeight:dimensions.height rowWidth:dimensions.width freeInput:NO];
     
//     [_operator multiplyFloatMatrix:eigenspaceTranspose withFloatMatrix:matrix product:projection matrixOneColumnHeight:dimensions.width matrixOneRowWidth:kSizeDimension*kSizeDimension matrixTwoRowWidth:numberOfImages freeInputs:NO];
     
     BPMatrix* projection = [BPMatrix matrixWithMultiplicationOfMatrixOne:eigenspaceTranspose withMatrixTwo:matrix];
     
     if ([projection width] != numberOfImages || [projection height] != kSizeDimension*kSizeDimension) {
         @throw @"Projection dimensions are wrong";
     }
     
//     free(eigenspaceTranspose); eigenspaceTranspose = NULL;
     return projection;
}

//-(void)calculateEigenvalue:(RawType*)eigenvalues eigenvectors:(RawType*)eigenvectors fromNonsymmetricInputMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
//    
//    [_operator eigendecomposeFloatMatrix:matrix intoEigenvalues:eigenvalues eigenvectors:eigenvectors numberOfImportantValues:(numberOfImages-numberOfPeople) matrixDimension:(numberOfImages-numberOfPeople) freeInput:NO];
//}

//-(RawType*)calculateEigenvectorsFromNonsymmetricInputMatrix:(RawType*)matrix withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
//    
//    RawType* eigenvalues __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&eigenvalues, kAlignment, (numberOfImages-numberOfPeople)*sizeof(RawType)));
//    
////    RawType* eigenvalues = calloc(numberOfImages-numberOfPeople, sizeof(RawType));
//    
//    RawType* eigenvectors __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&eigenvectors, kAlignment, (numberOfImages-numberOfPeople)*(numberOfImages-numberOfPeople)*sizeof(RawType)));
//    
//    RawType* matrixT __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&matrixT, kAlignment, (numberOfImages-numberOfPeople)*(numberOfImages-numberOfPeople)*sizeof(RawType)));
//    
//                      
////    RawType* eigenvectors = calloc((numberOfImages-numberOfPeople)*(numberOfImages-numberOfPeople), sizeof(RawType));
//    [self calculateEigenvalue:eigenvalues eigenvectors:eigenvectors fromNonsymmetricInputMatrix:matrixT withNumberOfImages:numberOfImages withNumberOfPeople:numberOfPeople];
//    free(eigenvalues); eigenvalues = NULL;
//    return eigenvectors;
//    
//}

-(void)zeroBuffer:(RawType*)buffer numberOfValues:(NSUInteger)num {
    [_operator clearFloatMatrix:buffer numberOfElements:num];
}

-(void)calculateMeanOfEachClassFromEigenspace:(BPMatrix*)eigenspace intoScatterWithinMatrix:(BPMatrix*)Sw intoScatterBetweenMatrix:(BPMatrix*)Sb withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
    Sb = [BPMatrix matrixWithDimensions:CGSizeMake((numberOfImages-numberOfPeople), (numberOfImages-numberOfPeople)) withPrimitiveSize:sizeof(RawType)];
    Sw = [BPMatrix matrixWithDimensions:CGSizeMake((numberOfImages-numberOfPeople), (numberOfImages-numberOfPeople)) withPrimitiveSize:sizeof(RawType)];
    
//    RawType* eigenspaceMean __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&eigenspaceMean, kAlignment, (numberOfImages - numberOfPeople)*sizeof(RawType)));
    
//    RawType* eigenspaceMean = calloc(numberOfImages - numberOfPeople, sizeof(RawType));
//    [_operator columnWiseMeanOfFloatMatrix:eigenspace toFloatVector:eigenspaceMean columnHeight:(numberOfImages - numberOfPeople) rowWidth:numberOfImages freeInput:NO];
    
    BPMatrix* eigenspaceMean = [eigenspace meanOfRows];
    
    
    RawType* innerMean __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&innerMean, kAlignment, (numberOfImages - numberOfPeople)*numberOfPeople*sizeof(RawType)));
    
//    RawType* innerMean = calloc((numberOfImages - numberOfPeople)*numberOfPeople, sizeof(RawType));
    
    
    RawType* scatterBuffer __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&scatterBuffer, kAlignment, (numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople)*sizeof(RawType)));
//    RawType* scatterBuffer = calloc((numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople), sizeof(RawType));
    
    
    RawType* intermediate __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&intermediate, kAlignment, (numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople)*sizeof(RawType)));
//    RawType* intermediate = calloc((numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople), sizeof(RawType));
    
    RawType* multiplicationTemporary __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&multiplicationTemporary, kAlignment, (numberOfImages - numberOfPeople)*sizeof(RawType)));
//    RawType* multiplicationTemporary = calloc((numberOfImages - numberOfPeople), sizeof(RawType));
    
    RawType* multiplicationTemporaryTranspose __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&multiplicationTemporaryTranspose, kAlignment, (numberOfImages - numberOfPeople)*sizeof(RawType)));
//    RawType* multiplicationTemporaryTranspose = calloc((numberOfImages - numberOfPeople), sizeof(RawType));
    
    RawType* scatterBetweenBuffer __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&scatterBetweenBuffer, kAlignment, (numberOfImages - numberOfPeople)*sizeof(RawType)));
//    RawType* scatterBetweenBuffer = calloc(numberOfImages - numberOfPeople, sizeof(RawType));
    
//    NSArray* indices = [[NSArray alloc] initWithArray:[_dataSource personImageIndexes] copyItems:YES];
    int *indices = [_dataSource personImageIndexes];
    for (int i = 0; i < numberOfPeople; ++i) {
        [self zeroBuffer:scatterBuffer numberOfValues:(numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople)];

        int startIndex = indices[i];
        int endIndex = indices[i+1] - 1;
        RawType* currentLocationInput __attribute__((aligned(kAlignment))) = [eigenspace getMutableData] + startIndex*(numberOfImages-numberOfPeople);
        RawType* currentLocationOutput __attribute__((aligned(kAlignment))) = innerMean + startIndex;
        [_operator columnWiseMeanOfFloatMatrix:currentLocationInput toFloatVector:currentLocationOutput columnHeight:(numberOfImages-numberOfPeople) rowWidth:(endIndex-startIndex)+1 freeInput:NO];
        for(int j = startIndex; j <= endIndex; ++j) {
            [_operator copyVector:[eigenspace getMutableData]+j*(numberOfImages-numberOfPeople) toVector:multiplicationTemporary numberOfElements:(numberOfImages-numberOfPeople) offset:0 sizeOfType:sizeof(RawType)];
            
            [_operator subtractFloatVector:currentLocationOutput fromFloatVector:multiplicationTemporary numberOfElements:(numberOfImages-numberOfPeople) freeInput:NO];
            
//            [_operator transposeFloatMatrix:multiplicationTemporary transposed:multiplicationTemporaryTranspose columnHeight:(numberOfImages-numberOfPeople) rowWidth:1 freeInput:NO];
            
            [_operator multiplyFloatMatrix:multiplicationTemporary withFloatMatrix:multiplicationTemporary product:intermediate matrixOneColumnHeight:(numberOfImages-numberOfPeople) matrixOneRowWidth:1 matrixTwoRowWidth:(numberOfImages-numberOfPeople) freeInputs:NO];
            
            [_operator addFloatMatrix:scatterBuffer toFloatMatrix:intermediate intoResultFloatMatrix:scatterBuffer columnHeight:(numberOfImages-numberOfPeople) rowWidth:(numberOfImages-numberOfPeople) freeInput:NO];
            
        }
        [_operator addFloatMatrix:[Sw getMutableData] toFloatMatrix:scatterBuffer intoResultFloatMatrix:[Sw getMutableData] columnHeight:(numberOfImages-numberOfPeople) rowWidth:(numberOfImages-numberOfPeople) freeInput:NO];
        
        [_operator copyVector:innerMean+i*(numberOfImages-numberOfPeople) toVector:scatterBetweenBuffer numberOfElements:(numberOfImages-numberOfPeople) offset:0 sizeOfType:sizeof(RawType)];
        
        [_operator subtractFloatVector:[eigenspaceMean getMutableData] fromFloatVector:scatterBetweenBuffer numberOfElements:(numberOfImages-numberOfPeople) freeInput:NO];
//        [_operator transposeFloatMatrix:multiplicationTemporary transposed:multiplicationTemporaryTranspose columnHeight:(numberOfImages-numberOfPeople) rowWidth:1 freeInput:NO];
        
        [_operator multiplyFloatMatrix:scatterBetweenBuffer withFloatMatrix:scatterBetweenBuffer product:intermediate matrixOneColumnHeight:(numberOfImages-numberOfPeople) matrixOneRowWidth:1 matrixTwoRowWidth:(numberOfImages-numberOfPeople) freeInputs:NO];
        
        [_operator addFloatMatrix:[Sb getMutableData] toFloatMatrix:intermediate intoResultFloatMatrix:[Sb getMutableData] columnHeight:(numberOfImages-numberOfPeople) rowWidth:(numberOfImages-numberOfPeople) freeInput:NO];
        
        
    }
    free(indices); indices = NULL;
    free(scatterBetweenBuffer); scatterBetweenBuffer = NULL;
    free(multiplicationTemporaryTranspose); multiplicationTemporaryTranspose = NULL;
    free(multiplicationTemporary); multiplicationTemporary = NULL;
    free(intermediate); intermediate = NULL;
    free(scatterBuffer); scatterBuffer = NULL;
    free(innerMean); innerMean = NULL;
//    free(eigenspaceMean); eigenspaceMean = NULL;
}

-(BPMatrix*)calculateEigenvectorsFromScatterWithin:(BPMatrix*)Sw fromScatterBetween:(BPMatrix*)Sb withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
//    RawType* SwInverted __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&SwInverted, kAlignment, (numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople)*sizeof(RawType)));

    BPMatrix* SwInverted = [[Sw duplicate] invertMatrix];
    
//    RawType* SwInverted = calloc((numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople), sizeof(RawType));
//    [_operator invertFloatMatrix:Sw intoResult:SwInverted matrixDimension:(numberOfImages - numberOfPeople) freeInput:NO];
    
//    RawType* JCostFunction __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&JCostFunction, kAlignment, (numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople)*sizeof(RawType)));
    
//    RawType* JCostFunction = calloc((numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople), sizeof(RawType));
    
    BPMatrix* JCostFunction = [SwInverted multiplyBy:Sb];
    [_operator multiplyFloatMatrix:[SwInverted getMutableData] withFloatMatrix:[Sb getMutableData] product:[JCostFunction getMutableData] matrixOneColumnHeight:(numberOfImages - numberOfPeople) matrixOneRowWidth:(numberOfImages - numberOfPeople) matrixTwoRowWidth:(numberOfImages - numberOfPeople) freeInputs:NO];
    
    
//    BPMatrix* 
    
//    RawType* eigenvectors = [self calculateEigenvectorsFromNonsymmetricInputMatrix:JCostFunction withNumberOfImages:numberOfImages withNumberOfPeople:numberOfPeople];
    
//    RawType* outputEigenvectors __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&outputEigenvectors, kAlignment, (numberOfImages-numberOfPeople)*(numberOfPeople-1)*sizeof(RawType)));
    
//    RawType *outputEigenvectors = calloc((numberOfImages-numberOfPeople)*(numberOfPeople-1), sizeof(RawType));
    
//    NSUInteger inputOffset = ((numberOfImages-numberOfPeople)-(numberOfPeople))*(numberOfImages-numberOfPeople)*sizeof(RawType);
    
    
//    memcpy(outputEigenvectors, eigenvectors+inputOffset, (numberOfImages-numberOfPeople)*(numberOfPeople-1)*sizeof(RawType));
    
//    for (int i = ((numberOfImages-numberOfPeople)-(numberOfPeople-1)); i < (numberOfImages-numberOfPeople); ++i) {
//        for (int j = 0; j < (numberOfImages-numberOfPeople)*(numberOfImages-numberOfPeople); j+=(numberOfImages-numberOfPeople)) {
//            
////            outputEigenvectors[i+j] = eigenvectors[i+j];
//            
//        }
//    }
    
//    free(eigenvectors); eigenvectors = NULL;
//    free(JCostFunction); JCostFunction = NULL;
//    free(SwInverted); SwInverted = NULL;
    
    return [JCostFunction eigenvectors];
    
}

-(BPMatrix*)projectImageVectors:(BPMatrix*)matrix ontoFisherLinearSpace:(BPMatrix*)fisherSpace withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
//    RawType* fisherEigenvectorsTranspose __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&fisherEigenvectorsTranspose, kAlignment, (numberOfPeople-1)*(numberOfImages-numberOfPeople)*sizeof(RawType)));
    
//    RawType* fisherEigenvectorsTranspose = calloc((numberOfPeople-1)*(numberOfImages-numberOfPeople), sizeof(RawType));
    
    BPMatrix* fisherEigenvectorsTranspose = [fisherSpace transposedNew];
    
//    [_operator transposeFloatMatrix:fisherSpace transposed:fisherEigenvectorsTranspose columnHeight:(numberOfImages-numberOfPeople) rowWidth:(numberOfPeople-1) freeInput:NO];
    
//    RawType* projectedImages __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&projectedImages, kAlignment, (numberOfPeople-1)*numberOfImages*sizeof(RawType)));
    
//    RawType* projectedImages = calloc((numberOfPeople-1)*numberOfImages, sizeof(RawType));
    
//    [_operator multiplyFloatMatrix:fisherEigenvectorsTranspose withFloatMatrix:matrix product:projectedImages matrixOneColumnHeight:(numberOfPeople-1) matrixOneRowWidth:(numberOfImages-numberOfPeople) matrixTwoRowWidth:numberOfImages freeInputs:NO];
    
    BPMatrix* projectedImages = [BPMatrix matrixWithMultiplicationOfMatrixOne:fisherEigenvectorsTranspose withMatrixTwo:matrix];
    
    if([projectedImages width] != numberOfImages || [projectedImages height] != numberOfPeople-1) {
        @throw @"ProjectedImages dimensions are wrong";
    }
    
//    free(fisherEigenvectorsTranspose); fisherEigenvectorsTranspose = NULL;
    return projectedImages;
    
}

@end
