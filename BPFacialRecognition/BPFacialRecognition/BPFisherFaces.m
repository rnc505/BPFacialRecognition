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
//@property (nonatomic, retain) BPMatrix *meanImage;
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
    
    BPMatrix* scatterWithin = [BPMatrix matrixWithDimensions:CGSizeMake((numberOfImages-numberOfPeople), (numberOfImages-numberOfPeople)) withPrimitiveSize:sizeof(RawType)];
    BPMatrix* scatterBetween = [BPMatrix matrixWithDimensions:CGSizeMake((numberOfImages-numberOfPeople), (numberOfImages-numberOfPeople)) withPrimitiveSize:sizeof(RawType)];
    
    
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
    
    BPMatrix* theImage = [BPMatrix matrixWithDimensions:CGSizeMake(1, kSizeDimension*kSizeDimension) withPrimitiveSize:sizeof(RawType)];
    
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
    vDSP_minvi([distances getData], 1, &minDist, &minIndex, distances.width);
    
//    free(distances); distances = NULL;
//    free(projectedImage); projectedImage = NULL;
//    free(imageData); projectedImage = NULL;
    //minIndex contains the index of the person who it is
    int * bleb = [_dataSource personImageIndexes];
    
    for (int i = 0; i < numberOfPeople; ++i) {
        int START_INCLUSIVE_BOUND = bleb[i];
        int END_INCLUSIVE_BOUND = bleb[i+1]-1;
        if((unsigned)(minIndex-START_INCLUSIVE_BOUND) <= (END_INCLUSIVE_BOUND-START_INCLUSIVE_BOUND)) {
            minIndex = i;
            break;
        }
    }
    BPPreRecognitionResult *result = [BPPreRecognitionResult new];
    result.position = minIndex;
    result.distance = minDist;
    free(bleb); bleb = NULL;
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
    
    if([retval width] != 1 || [retval height] != largestEigenvectorsOfWorkT.height) {
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
    
    BPMatrix* currentTraining = nil;//[BPMatrix matrixWithDimensions:CGSizeMake((numberOfPeople-1), 1) withPrimitiveSize:sizeof(RawType)];
    BPMatrix* tmpTest = nil;//[BPMatrix matrixWithDimensions:CGSizeMake((numberOfPeople-1), 1) withPrimitiveSize:sizeof(RawType)];
    BPMatrix* distances = [BPMatrix matrixWithDimensions:CGSizeMake(numberOfImages, 1) withPrimitiveSize:sizeof(RawType)];
    for (int i = 0; i < numberOfImages; ++i) {
        
//        [currentTraining zeroOutData];
//        RawType* cTPointer = [currentTraining getMutableData];
        currentTraining = [training getColumnAtIndex:i];
        tmpTest = [testImg duplicate];
//        [tmpTest zeroOutData];
//        RawType* tTPointer = [tmpTest getMutableData];
        
//        [_operator copyVector:[training getMutableData]+i*(numberOfPeople-1) toVector:cTPointer numberOfElements:numberOfPeople-1 sizeOfType:sizeof(RawType)];
//        [_operator copyVector:[testImg getMutableData] toVector:tTPointer numberOfElements:numberOfPeople-1 sizeOfType:sizeof(RawType)];
        
        [tmpTest subtractedBy:currentTraining];
        
//        [_operator subtractFloatVector:currentTraining fromFloatVector:tmpTest numberOfElements:numberOfPeople-1 freeInput:NO];
        
//        cblas_sscal((int)numberOfPeople-1u, 1.0 / cblas_snrm2((int)numberOfPeople - 1u, [tmpTest getData], 1), [tmpTest getMutableData], 1); // NORMALIZE VECTOR
//        
//        vDSP_vsq([tmpTest getData], 1, [tmpTest getMutableData], 1, numberOfPeople-1); // square each element
//        vDSP_sve([tmpTest getData], 1, (RawType*)[distances getMutableData]+i, numberOfPeople-1); // sum and add this euclidean distance to the array
        distances[i] = @([BPMatrix euclideanDistanceBetweenMatrixOne:tmpTest andMatrixTwo:currentTraining]);
    }
    
    return distances;
}
#pragma mark - Private Trainer Implementation

-(BPMatrix*)createImageMatrixWithNumberOfImages:(NSUInteger)numberOfImages {
    
    BPMatrix* returnValue = [BPMatrix matrixWithDimensions:CGSizeMake(kSizeDimension*kSizeDimension,numberOfImages) withPrimitiveSize:sizeof(RawType)];
    
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
    return [returnValue transpose];
}
-(BPMatrix*)normalizeImageMatrix:(BPMatrix*)matrix withNumberOfImages:(NSUInteger)numberOfImages {
    
    BPMatrix* mean = [matrix meanOfRows];
    [matrix subtractedBy:[mean stretchByNumberOfRows:numberOfImages]];
//        [_operator subtractFloatVector:(void*)[mean getData] fromFloatVector:[matrix getMutableData]+i*matrix.height numberOfElements:matrix.height freeInput:NO];
        
        /**
         *   matrix subtracted by mean dupped
         *
         *  @param alignedkAlignment <#alignedkAlignment description#>
         *
         *  @return <#return value description#>
         */
        
    
    
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
    
//    [_operator clearFloatMatrix:outputEigenvectors numberOfElements:kSizeDimension*kSizeDimension*(numberOfImages-numberOfPeople)];
//    [_operator multiplyFloatMatrix:matrix withFloatMatrix:eigenvectors product:outputEigenvectors matrixOneColumnHeight:kSizeDimension*kSizeDimension matrixOneRowWidth:numberOfImages matrixTwoRowWidth:(numberOfImages-numberOfPeople) freeInputs:NO];
    BPMatrix* covarEigenvectors = [covariance eigenvectors];
    NSUInteger temp = covarEigenvectors.width;
    covarEigenvectors.width = covarEigenvectors.height;
    covarEigenvectors.height = temp;
    BPMatrix* outputEigenvectors = [[BPMatrix matrixWithMultiplicationOfMatrixOne:covarEigenvectors withMatrixTwo:[matrix transposedNew]] transpose];
    
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
     
     if ([projection width] != numberOfImages || [projection height] != (numberOfImages-numberOfPeople)) {
         @throw [NSString stringWithFormat:@"Projection dimensions are wrong. Dimensions: (%lu, %lu). Should be: (%lu, %lu)",(unsigned long)projection.width, (unsigned long)projection.height,(unsigned long)numberOfImages,(numberOfImages-numberOfPeople)];
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
    
//    Sb = [BPMatrix matrixWithDimensions:CGSizeMake((numberOfImages-numberOfPeople), (numberOfImages-numberOfPeople)) withPrimitiveSize:sizeof(RawType)];
//    Sw = [BPMatrix matrixWithDimensions:CGSizeMake((numberOfImages-numberOfPeople), (numberOfImages-numberOfPeople)) withPrimitiveSize:sizeof(RawType)];
    
//    RawType* eigenspaceMean __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&eigenspaceMean, kAlignment, (numberOfImages - numberOfPeople)*sizeof(RawType)));
    
//    RawType* eigenspaceMean = calloc(numberOfImages - numberOfPeople, sizeof(RawType));
//    [_operator columnWiseMeanOfFloatMatrix:eigenspace toFloatVector:eigenspaceMean columnHeight:(numberOfImages - numberOfPeople) rowWidth:numberOfImages freeInput:NO];
    
    BPMatrix* eigenspaceMean = [eigenspace meanOfRows];
    
    
//    RawType* innerMean __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&innerMean, kAlignment, (numberOfImages - numberOfPeople)*numberOfPeople*sizeof(RawType)));
    
//    RawType* innerMean = calloc((numberOfImages - numberOfPeople)*numberOfPeople, sizeof(RawType));
    
    
//    RawType* scatterBuffer __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&scatterBuffer, kAlignment, (numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople)*sizeof(RawType)));
//    RawType* scatterBuffer = calloc((numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople), sizeof(RawType));
    
    
//    RawType* intermediate __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&intermediate, kAlignment, (numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople)*sizeof(RawType)));
//    RawType* intermediate = calloc((numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople), sizeof(RawType));
    
//    RawType* multiplicationTemporary __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&multiplicationTemporary, kAlignment, (numberOfImages - numberOfPeople)*sizeof(RawType)));
//    RawType* multiplicationTemporary = calloc((numberOfImages - numberOfPeople), sizeof(RawType));
    
//    RawType* multiplicationTemporaryTranspose __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&multiplicationTemporaryTranspose, kAlignment, (numberOfImages - numberOfPeople)*sizeof(RawType)));
//    RawType* multiplicationTemporaryTranspose = calloc((numberOfImages - numberOfPeople), sizeof(RawType));
    
//    RawType* scatterBetweenBuffer __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&scatterBetweenBuffer, kAlignment, (numberOfImages - numberOfPeople)*sizeof(RawType)));
//    RawType* scatterBetweenBuffer = calloc(numberOfImages - numberOfPeople, sizeof(RawType));
    
//    NSArray* indices = [[NSArray alloc] initWithArray:[_dataSource personImageIndexes] copyItems:YES];
    
    BPMatrix* innerMean = nil;
    int *indices = [_dataSource personImageIndexes];
    for (int i = 0; i < numberOfPeople; ++i) {
//        [self zeroBuffer:scatterBuffer numberOfValues:(numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople)];
        

        int startIndex = indices[i];
        int endIndex = indices[i+1] - 1;
        innerMean = [[eigenspace getColumnsFromIndex:startIndex toIndex:endIndex] meanOfRows];
//        RawType* currentLocationInput __attribute__((aligned(kAlignment))) = [eigenspace getMutableData] + startIndex*(numberOfImages-numberOfPeople);
//        RawType* currentLocationOutput __attribute__((aligned(kAlignment))) = innerMean + startIndex;
//        [_operator columnWiseMeanOfFloatMatrix:currentLocationInput toFloatVector:currentLocationOutput columnHeight:(numberOfImages-numberOfPeople) rowWidth:(endIndex-startIndex)+1 freeInput:NO];
        BPMatrix* scatterBuffer = [BPMatrix matrixWithDimensions:CGSizeMake(numberOfImages-numberOfPeople, numberOfImages-numberOfPeople) withPrimitiveSize:sizeof(RawType)];
        for(int j = startIndex; j <= endIndex; ++j) {
            BPMatrix* A = [BPMatrix matrixWithSubtractionOfMatrixOne:[eigenspace getColumnAtIndex:j] byMatrixTwo:innerMean];
            BPMatrix* At = [A transposedNew];
            [scatterBuffer addBy:[A multiplyBy:At]];
            
//            [_operator copyVector:[eigenspace getMutableData]+j*(numberOfImages-numberOfPeople) toVector:multiplicationTemporary numberOfElements:(numberOfImages-numberOfPeople) offset:0 sizeOfType:sizeof(RawType)];
            
//            [_operator subtractFloatVector:currentLocationOutput fromFloatVector:multiplicationTemporary numberOfElements:(numberOfImages-numberOfPeople) freeInput:NO];
            
//            [_operator transposeFloatMatrix:multiplicationTemporary transposed:multiplicationTemporaryTranspose columnHeight:(numberOfImages-numberOfPeople) rowWidth:1 freeInput:NO];
            
//            [_operator multiplyFloatMatrix:multiplicationTemporary withFloatMatrix:multiplicationTemporary product:intermediate matrixOneColumnHeight:(numberOfImages-numberOfPeople) matrixOneRowWidth:1 matrixTwoRowWidth:(numberOfImages-numberOfPeople) freeInputs:NO];
            
//            [_operator addFloatMatrix:scatterBuffer toFloatMatrix:intermediate intoResultFloatMatrix:scatterBuffer columnHeight:(numberOfImages-numberOfPeople) rowWidth:(numberOfImages-numberOfPeople) freeInput:NO];
            
        }
        [Sw addBy:scatterBuffer];
        BPMatrix* Atemp = [BPMatrix matrixWithSubtractionOfMatrixOne:innerMean byMatrixTwo:eigenspaceMean];
        BPMatrix* AtempTranspose = [Atemp transposedNew];
        [Sb addBy:[Atemp multiplyBy:AtempTranspose]];
//        [_operator addFloatMatrix:[Sw getMutableData] toFloatMatrix:scatterBuffer intoResultFloatMatrix:[Sw getMutableData] columnHeight:(numberOfImages-numberOfPeople) rowWidth:(numberOfImages-numberOfPeople) freeInput:NO];
//        
//        [_operator copyVector:innerMean+i*(numberOfImages-numberOfPeople) toVector:scatterBetweenBuffer numberOfElements:(numberOfImages-numberOfPeople) offset:0 sizeOfType:sizeof(RawType)];
//        
//        [_operator subtractFloatVector:[eigenspaceMean getMutableData] fromFloatVector:scatterBetweenBuffer numberOfElements:(numberOfImages-numberOfPeople) freeInput:NO];
////        [_operator transposeFloatMatrix:multiplicationTemporary transposed:multiplicationTemporaryTranspose columnHeight:(numberOfImages-numberOfPeople) rowWidth:1 freeInput:NO];
//        
//        [_operator multiplyFloatMatrix:scatterBetweenBuffer withFloatMatrix:scatterBetweenBuffer product:intermediate matrixOneColumnHeight:(numberOfImages-numberOfPeople) matrixOneRowWidth:1 matrixTwoRowWidth:(numberOfImages-numberOfPeople) freeInputs:NO];
//        
//        [_operator addFloatMatrix:[Sb getMutableData] toFloatMatrix:intermediate intoResultFloatMatrix:[Sb getMutableData] columnHeight:(numberOfImages-numberOfPeople) rowWidth:(numberOfImages-numberOfPeople) freeInput:NO];
        
        
    }
    free(indices); indices = NULL;
//    free(scatterBetweenBuffer); scatterBetweenBuffer = NULL;
//    free(multiplicationTemporaryTranspose); multiplicationTemporaryTranspose = NULL;
//    free(multiplicationTemporary); multiplicationTemporary = NULL;
//    free(intermediate); intermediate = NULL;
//    free(scatterBuffer); scatterBuffer = NULL;
//    free(innerMean); innerMean = NULL;
//    free(eigenspaceMean); eigenspaceMean = NULL;
     
}

-(BPMatrix*)calculateEigenvectorsFromScatterWithin:(BPMatrix*)Sw fromScatterBetween:(BPMatrix*)Sb withNumberOfImages:(NSUInteger)numberOfImages withNumberOfPeople:(NSUInteger)numberOfPeople {
    
//    RawType* SwInverted __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&SwInverted, kAlignment, (numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople)*sizeof(RawType)));

//    BPMatrix* SwInverted = [[Sw duplicate] invertMatrix];
    
//    RawType* SwInverted = calloc((numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople), sizeof(RawType));
//    [_operator invertFloatMatrix:Sw intoResult:SwInverted matrixDimension:(numberOfImages - numberOfPeople) freeInput:NO];
    
//    RawType* JCostFunction __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&JCostFunction, kAlignment, (numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople)*sizeof(RawType)));
    
//    RawType* JCostFunction = calloc((numberOfImages - numberOfPeople)*(numberOfImages - numberOfPeople), sizeof(RawType));
    
//    BPMatrix* JCostFunction = [SwInverted multiplyBy:Sb];
//    [_operator multiplyFloatMatrix:[SwInverted getMutableData] withFloatMatrix:[Sb getMutableData] product:[JCostFunction getMutableData] matrixOneColumnHeight:(numberOfImages - numberOfPeople) matrixOneRowWidth:(numberOfImages - numberOfPeople) matrixTwoRowWidth:(numberOfImages - numberOfPeople) freeInputs:NO];
    
    
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
    
//    [JCostFunction eigendecomposeIsSymmetric:NO withNumberOfValues:Sb.width withNumberOfVectors:Sb.width*Sb.height];
    BPMatrix* blank = [BPMatrix eigendecomposeGeneralizedMatrixA:Sb andB:Sw WithNumberOfValues:Sb.width numberOfVector:Sb.width*Sb.height];
    
    /*
     
        Hardcoding Eigenvectors because I have no choice
     
     */
    
    /*
    BPMatrix *eigenvectors = [BPMatrix matrixWithDimensions:CGSizeMake(Sb.width, Sb.height) withPrimitiveSize:sizeof(RawType)];
    RawType* vec = [eigenvectors getMutableData];
    vec[0] = 2.342406355621914e+10;
    vec[1] = 1012070760.75349;
    vec[2] = -8852504538.15332;
	vec[3] = -16571672976.0930;
	vec[4] = -4997556659.79738;
	vec[5] = -8086306412.90286;
	vec[6] = -6263295436.04887;
	vec[7] = 6105172700.23371;
	vec[8] = 20696502622.9016;
	vec[9] = 30331030271.9451;
	vec[10] = 44381352331.7331;
	vec[11] = -2367487078864.30;
    
    vec[12] = -0.000323674226615023;
	vec[13] = 0.000434844943812085;
	vec[14] = 0.000114530948682257;
	vec[15] = -0.000537220944666837;
	vec[16]=0.00372161894733029;
	vec[17] =-0.000875598867337852;
	vec[18] = 0.00104432616168292;
	vec[19] = -0.000305771733796623;
	vec[20] = -0.000390894988839317;
	vec[21] = 0.000248709099390466;
	vec[22] = -0.000570063773447101;
	vec[23] = 0.000452901724063235;
    
    vec[24] = 0.000479719247938612;
	vec[25] = -0.000818450917341168;
	vec[26] = 0.000129368089869275;
	vec[27] = 0.000777591295346715;
	vec[28] = -0.000233581523776051;
	vec[29] = 9.86972979167819e-05;
	vec[30] = 0.00104759608685746;
	vec[31] = -0.00256997915580093;
	vec[32] = -0.000648280480529887;
	vec[33] = -0.000735409876085923;
	vec[34] = -0.000114035433315105;
	vec[35] = 0.00686089766095333;
    
    vec[36] = 0.000338982388898017;
	vec[37] = -0.000857686887681180;
	vec[38] = -0.000558106914138119;
	vec[39] = -0.00175628166100504;
	vec[40] = 8.37855496913980e-05;
	vec[41] = 0.000628903893150899;
	vec[42] = -0.000121817050462514;
	vec[43] = 0.000128109376521860;
	vec[44] = -0.000431964924788534;
	vec[45] = -0.000914303867114884;
	vec[46] = -8.12734516973942e-05;
	vec[47] = -0.00157133154367525;
    
    vec[48] = 0.000148615791563199;
	vec[49] = -0.000472355459990332;
	vec[50] = -0.00146018660203524;
	vec[51]= 0.000922212201100835;
	vec[52] = 0.000133329873216809;
	vec[53] = -4.97765502626685e-05;
	vec[54] = 0.000655982550105417;
	vec[55] = 0.000708796971889892;
	vec[56] = 0.000346565150580134;
	vec[57] = -0.000515753534046769;
	vec[58] = -0.000264588605685653;
	vec[59] = -0.00260968713567486;
    
    vec[60] = 6.38037191130314e-05;
	vec[61] = -0.000539834629873596;
	vec[62] = -3.13502466405225e-05;
	vec[63] = 4.60249328560143e-06;
	vec[64] = -0.000117487442270673;
	vec[65] = -0.00169217605377250;
	vec[66] = -0.000832657326964093;
	vec[67] = -2.76300999775567e-05;
	vec[68] = -0.000218355307193437;
	vec[69] = -0.000407630662560626;
	vec[70] = -0.000159770783273461;
	vec[71] = -0.000874163900290019;
    
    vec[72] = 0.000290122869256029;
	vec[73] = -0.000267866936853079;
	vec[74] = 3.76114462779830e-05;
	vec[75] = 0.000558016493671203;
	vec[76] = 0.000667129456719391;
	vec[77] = 0.000617835848865878;
	vec[78] = -0.00112983160654804;
	vec[79] = -0.000181806696718287;
	vec[80] = 0.000286498705016380;
	vec[81] = -0.000282553392234085;
	vec[82] = 0.000277658177709012;
	vec[83] = -0.000507782264045542;
    
    vec[84] = -0.000893501097496236;
	vec[85] = -0.000872877180977601;
	vec[86] = 0.000477848525232909;
	vec[87] = 8.72869963002210e-05;
	vec[88] = 3.28659400904578e-05;
	vec[89] = 0.000125847446656881;
	vec[90] = 0.000156801655534101;
	vec[91] = 0.000149428819922302;
	vec[92] = 0.000255779253716980;
	vec[93] = 2.19463058436402e-05;
	vec[94] = -2.94025473977293e-05;
	vec[95] = -0.00228840805022775;
    
    vec[96] = -0.000221429742628356;
	vec[97] =1.95307506502798e-06;
	vec[98] = -0.000463726312514796;
	vec[99] = -0.000351661514457880;
	vec[100] = 9.27302315383602e-06;
	vec[101] = -0.000194654638113111;
	vec[102] = -2.54519186819865e-05;
	vec[103] = -0.000431435717422131;
	vec[104] = 0.000816927605303753;
	vec[105] = 0.000223198766115186;
	vec[106] = 0.000509078964873603;
	vec[107] = 0.000829088216013279;
    
    vec[108] = 0.000404100210624987;
	vec[109] = -0.000107726388971600;
	vec[110] = 0.000379323130764059;
	vec[111] = 3.02892876317022e-06;
	vec[112] = 5.01735486158042e-05;
	vec[113] = -0.000117183484983712;
	vec[114] = 0.000276808819118633;
	vec[115] = 0.000240494874165065;
	vec[116] = 0.000241916189378251;
	vec[117] = -0.000229572438793323;
	vec[118] = 0.000423557682192454;
	vec[119] = 0.000681994082533405;
    
    vec[120] = -0.000143277521465926;
	vec[121] = 0.000339707281910491;
	vec[122] = 0.000147222046553262;
	vec[123] = -3.78255363269214e-05;
	vec[124] = -4.59673648951746e-05;
	vec[125] = 2.34790253620812e-06;
	vec[126] = 1.70614736149021e-06;
	vec[127] = -8.27563664007281e-05;
	vec[128] = 0.000336616014406881;
	vec[129] = -0.000515720075999663;
	vec[130] = -0.000340895904301979;
	vec[131] =-0.000687297209502579;
    
    vec[132] = -0.000352758930407817;
	vec[133] = 0.000207132717093317;
	vec[134] = -8.64119213342865e-05;
	vec[135] = 7.50976007279542e-05;
	vec[136] = 1.65728050232086e-05;
	vec[137] = -8.43027441365855e-06;
	vec[138] = 4.92303666913601e-06;
	vec[139] = 2.24407291785796e-05;
	vec[140] = -0.000310487698624997;
	vec[141] = -0.000309511237621283;
	vec[142] = 0.000504307047741810;
	vec[143] = 0.000698502239396761;*/
    
    return [[[blank eigenvectors] getColumnsFromIndex:(numberOfImages-numberOfPeople)-numberOfPeople+1 toIndex:numberOfImages-numberOfPeople-1] flippedL2R];
    
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
    
    BPMatrix *projectedImages = [BPMatrix matrixWithMultiplicationOfMatrixOne:fisherEigenvectorsTranspose withMatrixTwo:[matrix getColumnAtIndex:0]];
    
    for (int i = 1; i < matrix.width; ++i) {
        BPMatrix* temp =[ BPMatrix matrixWithMultiplicationOfMatrixOne:fisherEigenvectorsTranspose withMatrixTwo:[matrix getColumnAtIndex:i]];
        projectedImages = [BPMatrix concatMatrixOne:projectedImages withMatrixTwo:temp];
    }
    
//    BPMatrix* projectedImages = [BPMatrix matrixWithMultiplicationOfMatrixOne:fisherEigenvectorsTranspose withMatrixTwo:matrix];
//
//    if([projectedImages width] != numberOfImages || [projectedImages height] != numberOfPeople-1) {
//        @throw @"ProjectedImages dimensions are wrong";
//    }
    
//    free(fisherEigenvectorsTranspose); fisherEigenvectorsTranspose = NULL;
    return projectedImages;
    
}

@end
