//
//  BPMatrix.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 3/28/14.
//  Copyright (c) 2014 BP. All rights reserved.
//
#define swap(a, b) {a^=b;b^=a;a^=b;}
#import "BPMatrix.h"
#import "BPEigen.h"
#import "BPRecognizerCPUOperator.h"
@interface BPMatrix()
@property(nonatomic, retain) NSMutableData* data;
@property(nonatomic, retain) BPRecognizerCPUOperator *operator;
//@property (nonatomic, readwrite) NSUInteger width;
//@property (nonatomic, readwrite) NSUInteger height;
@property (nonatomic, retain, readwrite) BPMatrix* eigenvalues;
@property (nonatomic, retain, readwrite) BPMatrix* eigenvectors;
-(id)initWithWidth:(NSUInteger)width withHeight:(NSUInteger)height withPrimitiveSize:(NSUInteger)size;
-(id)initWithWidth:(NSUInteger)width withHeight:(NSUInteger)height withPrimitiveSize:(NSUInteger)size withMemory:(void*)memory;
-(void*)allocateNewMemoryOfDimension:(CGSize)dimensions ofPrimitiveSize:(NSUInteger)size;
+(void*)allocateNewMemoryOfDimension:(CGSize)dimensions ofPrimitiveSize:(NSUInteger)size;

-(BPMatrix*)_internalTranspose;
@end
@implementation BPMatrix

-(BPMatrix *)eigenvalues {
    if(!_eigenvalues) {
        [NSException raise:@"Eigenvalues null" format:@"You must call an eigendecompose function before trying to access eigenvalues"];
    }
    return _eigenvalues;
}
-(BPMatrix *)eigenvectors {
    if(!_eigenvectors) {
        [NSException raise:@"Eigenvectors null" format:@"You must call an eigendecompose function before trying to access eigenvalues"];
    }
    return _eigenvectors;
}

-(id)initWithWidth:(NSUInteger)width withHeight:(NSUInteger)height withPrimitiveSize:(NSUInteger)size {
    return [self initWithWidth:width withHeight:height withPrimitiveSize:size withMemory:[self allocateNewMemoryOfDimension:CGSizeMake(width, height) ofPrimitiveSize:size]];
    }

-(id)initWithWidth:(NSUInteger)width withHeight:(NSUInteger)height withPrimitiveSize:(NSUInteger)size withMemory:(void *)memory {
    if(self = [super init]) {
        _width = width;
        _height = height;
        _size = size;
        _data = [NSMutableData dataWithBytesNoCopy:memory length:_width*_height*_size freeWhenDone:YES];
        _operator = [BPRecognizerCPUOperator new];
        _eigenvalues = nil;
        _eigenvectors = nil;
    }
    return self;
}

+(id)matrixWithDimensions:(CGSize)dimension withPrimitiveSize:(NSUInteger)size {
    return [[BPMatrix alloc] initWithWidth:dimension.width withHeight:dimension.height withPrimitiveSize:size];
}
-(const void *)getData {
    return [_data bytes];
}
-(void *)getMutableData {
    return [_data mutableBytes];
}

-(BPMatrix *)transposedNew {
    void* newMemory = [self allocateNewMemoryOfDimension:CGSizeMake(_height, _width) ofPrimitiveSize:_size];
    [_operator transposeFloatMatrix:(void*)[self getData] transposed:newMemory columnHeight:_height rowWidth:_width freeInput:NO];
    return [[BPMatrix alloc] initWithWidth:_height withHeight:_width withPrimitiveSize:_size withMemory:newMemory];
}

-(BPMatrix*)transpose {
    [self _internalTranspose];
    swap(_width, _height);
    return self;
}

-(BPMatrix*)_internalTranspose {
    void* newMemory = [self allocateNewMemoryOfDimension:CGSizeMake(_height, _width) ofPrimitiveSize:_size];
    [_operator transposeFloatMatrix:(void*)[self getData] transposed:newMemory columnHeight:_height rowWidth:_width freeInput:NO];
    _data = [NSMutableData dataWithBytesNoCopy:newMemory length:_height*_width*_size freeWhenDone:YES];
    return self;
}

-(void *)allocateNewMemoryOfDimension:(CGSize)dimensions ofPrimitiveSize:(NSUInteger)size {
    void* uninitMem __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&uninitMem, kAlignment,dimensions.height*dimensions.width*size));
    return uninitMem;
}
+(void *)allocateNewMemoryOfDimension:(CGSize)dimensions ofPrimitiveSize:(NSUInteger)size {
    void* uninitMem __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&uninitMem, kAlignment,dimensions.height*dimensions.width*size));
    return uninitMem;
}


-(BPMatrix*)duplicate {
    void* mem = [self allocateNewMemoryOfDimension:CGSizeMake(_width, _height) ofPrimitiveSize:_size];
    [_operator copyVector:(void*)[self getData] toVector:mem numberOfElements:_height*_width sizeOfType:_size];
    return [[BPMatrix alloc] initWithWidth:_width withHeight:_height withPrimitiveSize:_size withMemory:mem];
}

+(BPMatrix*)matrixWithMultiplicationOfMatrixOne:(BPMatrix *)matrixOne withMatrixTwo:(BPMatrix *)matrixTwo {
    return [[matrixOne duplicate] multiplyBy:matrixTwo];
}

-(BPMatrix*)multiplyBy:(BPMatrix *)rightMatrix {
    if([self width] != [rightMatrix height]) {
        [NSException raise:@"Dimension mismatch" format:@"Width of receiver must match height of rightMatrix. Receiver: (%lu, %lu), rightMatrix: (%lu, %lu)", (unsigned long)[self width], (unsigned long)[self height], (unsigned long)[rightMatrix width], (unsigned long)[rightMatrix height]];
    }
    void* newMem = [self allocateNewMemoryOfDimension:CGSizeMake(_height, [rightMatrix width]) ofPrimitiveSize:_size];
    [_operator multiplyFloatMatrix:(void*)[self getData] withFloatMatrix:(void*)[rightMatrix getData] product:newMem matrixOneColumnHeight:_height matrixOneRowWidth:_width matrixTwoRowWidth:[rightMatrix width] freeInputs:NO];
    _width = [rightMatrix width];
    _data = [NSMutableData dataWithBytesNoCopy:newMem length:_height*_width*_size freeWhenDone:YES];
    return self;
}

+(BPMatrix*)matrixWithSubtractionOfMatrixOne:(BPMatrix*)matrixOne byMatrixTwo:(BPMatrix*)matrixTwo {
    return [[matrixOne duplicate] subtractedBy:matrixTwo];
}
+(BPMatrix*)matrixWithAdditionOfMatrixOne:(BPMatrix*)matrixOne WithMatrixTwo:(BPMatrix*)matrixTwo {
    return [[matrixOne duplicate] addBy:matrixTwo];
}
-(BPMatrix*)meanOfRows {
    void* newMemory = [self allocateNewMemoryOfDimension:CGSizeMake(1, _height) ofPrimitiveSize:_size];
    [_operator columnWiseMeanOfFloatMatrix:(void*)[self getData] toFloatVector:newMemory columnHeight:_height rowWidth:_width freeInput:NO];
    return [[BPMatrix alloc] initWithWidth:1 withHeight:_height withPrimitiveSize:_size withMemory:newMemory];
}
-(BPMatrix*)subtractedBy:(BPMatrix*)rightMatrix {
    if([self width] != [rightMatrix width] || [self height] != [rightMatrix height]) {
        [NSException raise:@"Dimension mismatch" format:@"Dimensions weren't the same. Receiver: (%lu, %lu), rightMatrix: (%lu, %lu).", (unsigned long)[self width], (unsigned long)[self height], (unsigned long)[rightMatrix width], (unsigned long)[rightMatrix height]];
    }
    [_operator subtractFloatVector:(void*)[rightMatrix getData] fromFloatVector:[self getMutableData] numberOfElements:_height*_width freeInput:NO];
    return self;
}
-(BPMatrix*)eigendecomposeIsSymmetric:(BOOL)isSymmetric withNumberOfValues:(NSUInteger)eigenval withNumberOfVectors:(NSUInteger)eigenvec{
    
    if([self width] != [self height]) {
        [NSException raise:@"Dimension mismatch" format:@"Only square matrices can be eigendecomposed. Dimensions: (%lu, %lu).", (unsigned long)[self width], (unsigned long)[self height]];
    }
    
    void *newEigenvalues = [self allocateNewMemoryOfDimension:CGSizeMake(eigenval, 1) ofPrimitiveSize:_size];
    void *newEigenvectors = [self allocateNewMemoryOfDimension:CGSizeMake(eigenval, eigenvec/eigenval) ofPrimitiveSize:_size];
    if(isSymmetric) {
        // into newEigenvalues = [smallest, 2nd smallest,..., largest]
        // into newEigenvectors = [smallestEV1, smallestEV2,...smallestEVn, 2nd smallestEV1, 2nd smallestEV2,... 2nd smallestEVn,... largestEV1, largestEV2,...largestEVn]
        [_operator eigendecomposeSymmetricFloatMatrix:(void*)[[self duplicate] getMutableData] intoEigenvalues:newEigenvalues eigenvectors:newEigenvectors numberOfImportantValues:eigenval matrixDimension:eigenvec/eigenval freeInput:NO];
    } else {
        [self _internalTranspose];
        [_operator eigendecomposeFloatMatrix:(void*)[[self duplicate] getMutableData] intoEigenvalues:newEigenvalues eigenvectors:newEigenvectors numberOfImportantValues:eigenval matrixDimension:eigenvec/eigenval freeInput:NO];
        [self _internalTranspose];
    }
    [self setEigenvalues:[[BPMatrix alloc] initWithWidth:eigenval withHeight:1 withPrimitiveSize:_size withMemory:newEigenvalues]];
    BPMatrix* tempVec =[[BPMatrix alloc] initWithWidth:eigenval withHeight:eigenvec/eigenval withPrimitiveSize:_size withMemory:newEigenvectors];
    [self setEigenvectors:tempVec];
    return self;
}

+(BPMatrix *)eigendecomposeGeneralizedMatrixA:(BPMatrix*)A andB:(BPMatrix*)B WithNumberOfValues:(NSUInteger)numValues numberOfVector:(NSUInteger)numVectors {
    
    if([A width] != [A height]) {
        [NSException raise:@"Dimension mismatch" format:@"Only square matrices can be eigendecomposed. Dimensions: (%lu, %lu).", (unsigned long)[A width], (unsigned long)[A height]];
    }
    if([B width] != [B height]) {
        [NSException raise:@"Dimension mismatch" format:@"Only square matrices can be eigendecomposed. Dimensions: (%lu, %lu).", (unsigned long)[B width], (unsigned long)[B height]];
    }
    
    BPMatrix *Atransposed = [A transposedNew];
    BPMatrix *Btransposed = [B transposedNew];
    void *newEigenvalues = [BPMatrix allocateNewMemoryOfDimension:CGSizeMake(numValues, 1) ofPrimitiveSize:sizeof(RawType)];
    void *newEigenvectors = [BPMatrix allocateNewMemoryOfDimension:CGSizeMake(numValues, numVectors/numValues) ofPrimitiveSize:sizeof(RawType)];
    
    [[Atransposed operator] eigendecomposeGeneralizedMatricesA:[Atransposed getMutableData] andB:[Btransposed getMutableData] intoEigenvalues:newEigenvalues eigenvectors:newEigenvectors numberOfImportantValues:numValues maxtrixDimension:numVectors/numValues freeInput:NO];
//    [BPEigen eigendecomposeGeneralizedMatricesA:A andB:B intoEigenvalues:newEigenvalues eigenvectors:newEigenvectors numberOfImportantValues:numValues maxtrixDimension:numVectors/numValues freeInput:NO];
    
    BPMatrix *retVal = [BPMatrix matrixWithDimensions:CGSizeMake(1, 1) withPrimitiveSize:sizeof(RawType)];
    [retVal setEigenvalues:[[BPMatrix alloc] initWithWidth:numValues withHeight:1 withPrimitiveSize:sizeof(RawType) withMemory:newEigenvalues]];
    [retVal setEigenvectors:[[[BPMatrix alloc] initWithWidth:numValues withHeight:numVectors/numValues withPrimitiveSize:sizeof(RawType) withMemory:newEigenvectors]transposedNew]];
    return retVal;
    
}

-(BPMatrix*)addBy:(BPMatrix*)rightMatrix {
    if([self width] != [rightMatrix width] || [self height] != [rightMatrix height]) {
        [NSException raise:@"Dimension mismatch" format:@"Dimensions weren't the same. Receiver: (%lu, %lu), rightMatrix: (%lu, %lu).", (unsigned long)[self width], (unsigned long)[self height], (unsigned long)[rightMatrix width], (unsigned long)[rightMatrix height]];
    }
    [_operator addFloatMatrix:(void*)[self getData] toFloatMatrix:(void*)[rightMatrix getData] intoResultFloatMatrix:(void*)[self getMutableData] columnHeight:_height rowWidth:_width freeInput:NO];
    return self;
}
-(BPMatrix*)zeroOutData {
    [_operator clearFloatMatrix:[self getMutableData] numberOfElements:_width*_height];
    return self;
}
-(BPMatrix*)invertMatrix {
    if([self width] != [self height]) {
        [NSException raise:@"Dimension mismatch" format:@"Only square matrices can be inverted. Dimensions: (%lu, %lu).", (unsigned long)[self width], (unsigned long)[self height]];
    }
    [_operator invertFloatMatrix:(void*)[self getData] intoResult:(void*)[self getMutableData] matrixDimension:_width freeInput:NO];
    return self;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return [NSNumber numberWithFloat:*(((float*)[self getMutableData]+idx))];
}
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    ((float*)[self getMutableData])[idx] = [obj floatValue];
}

+(BPMatrix *)null {
    return [BPMatrix matrixWithDimensions:CGSizeMake(1, 1) withPrimitiveSize:sizeof(RawType)];
}

-(BPMatrix*)getColumnAtIndex:(NSUInteger)index {
    if(index >= _width) {
        [NSException raise:@"Index out of Bounds" format:@"Tried to access Matrix Column at index %lu, but width is only %lu",index,_width];
    }
    BPMatrix* column = [BPMatrix matrixWithDimensions:CGSizeMake(1, _height) withPrimitiveSize:_size];
    RawType* columnP = [column getMutableData];
    const RawType* selfData = [_data bytes];
//    [_operator copyVector:(void*)(selfData+index) toVector:columnP numberOfElements:_width offset:_width  sizeOfType:sizeof(RawType)];
    for (int i = 0; i < _height; ++i) {
        columnP[i] = selfData[index + i*_width];
    }
    return column;
}
-(BPMatrix*)getRowAtIndex:(NSUInteger)index {
    if(index >= _height) {
        [NSException raise:@"Index out of Bounds" format:@"Tried to access Matrix Row at index %lu, but height is only %lu",index,_height];
    }
    BPMatrix* row = [BPMatrix matrixWithDimensions:CGSizeMake(_width, 1) withPrimitiveSize:_size];
    RawType* rowP = [row getMutableData];
    const RawType* selfData = [_data bytes];
    [_operator copyVector:(void*)(selfData+index*_width) toVector:rowP numberOfElements:_width  sizeOfType:sizeof(RawType)];
    
    
//    for (int i = 0; i < _width; ++i) {
//        rowP[i] = selfData[i + index*_width];
//    }
    return row;
}
+(RawType)euclideanDistanceBetweenMatrixOne:(BPMatrix*)matrixOne andMatrixTwo:(BPMatrix*)matrixTwo {
    
    if(matrixOne.width != matrixTwo.width || matrixOne.height != matrixTwo.height) {
        [NSException raise:@"Dimension Mismatch" format:@"Matrix one's dimesions: (%lu, %lu); Matrix two's dimensions: (%lu, %lu)",matrixOne.width,matrixOne.height,matrixTwo.width,matrixTwo.height];
    }
    
    if(matrixOne.height != 1 && matrixOne.width != 1) {
        [NSException raise:@"Illegal Argument" format:@"The matrices must be either row or column vectors. Matrices' dimensions:(%lu, %lu).", matrixOne.width,matrixTwo.height];
    }
    
//    BPMatrix* one = matrixOne;
//    BPMatrix* two = matrixTwo;
//    if(matrixOne.width == 1) {
//        one = [matrixOne transposedNew];
//        two = [matrixTwo transposedNew];
//    }
//    BPMatrix* subtraction = [BPMatrix matrixWithSubtractionOfMatrixOne:one byMatrixTwo:two];
//    one = nil; two = nil;
    
//    cblas_sscal((int)subtraction.width, 1.0 / cblas_snrm2((int)subtraction.width, [subtraction getData], 1), [subtraction getMutableData], 1); // NORMALIZE VECTOR
    
//    vDSP_vsq([subtraction getData], 1, [subtraction getMutableData], 1, subtraction.width); // square each element
    
    RawType retVal;
//    vDSP_sve([subtraction getData], 1, &retVal, subtraction.width); // sum and add this euclidean distance to the array
    vDSP_distancesq([matrixOne getData], 1, [matrixTwo getData], 1, &retVal, matrixOne.width*matrixOne.height);
    return sqrt(retVal);
}

-(BPMatrix *)getColumnsFromIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2 {
    BPMatrix* retVal = [BPMatrix matrixWithDimensions:CGSizeMake(index2-index1+1, _height) withPrimitiveSize:_size];
    BPMatrix* tempCol = nil;
    for (NSUInteger i = index1; i <= index2; ++i) {
        tempCol = [self getColumnAtIndex:i];
        for(NSUInteger j = 0; j < _height; ++j) {
            retVal[j*(index2-index1+1) + (i-index1)] = tempCol[j];
        }
    }
    return retVal;
}

-(BPMatrix *)stretchByNumberOfRows:(NSUInteger)numRows {
    if(self.width != 1) {
        [NSException raise:@"Dimensions Not Allowed" format:@"Must be a column vector. Width: %lu",self.width];
    }
    BPMatrix*retVal = [BPMatrix matrixWithDimensions:CGSizeMake(numRows, _height) withPrimitiveSize:sizeof(RawType)];
    
    for (int i = 0; i < _height; ++i) {
        for (int j = 0; j < numRows; ++j) {
            retVal[j+i*numRows] = self[i];
        }
    }
    
    return retVal;
}

-(BPMatrix *)flippedL2R {
    BPMatrix *retval = [self duplicate];
    RawType* retValData = [retval getMutableData];
    for (int i = 0; i < _height; ++i) {
        for(int L = 0, R = (int)_width - 1; L < R; ++L, --R) {
            RawType temp = retValData[i*_width + R];
            retValData[i*_width + R] = retValData[i*_width + L];
            retValData[i*_width + L] = temp;
        }
    }
    
    return retval;
}

+(BPMatrix *)concatMatrixOne:(BPMatrix *)matOne withMatrixTwo:(BPMatrix *)matTwo {
    if([matOne height] != [matTwo height]) {
        [NSException raise:@"Dimensions not allowed" format:@"Heights must match. Mat One Height: %lu | Mat Two Height: %lu",[matOne height], [matTwo height]];
    }
    BPMatrix *retVal = [BPMatrix matrixWithDimensions:CGSizeMake(matOne.width+matTwo.width, matOne.height) withPrimitiveSize:sizeof(RawType)];
    RawType* retValP = [retVal getMutableData];
    int index = 0;
    for (int i = 0; i < matOne.height; ++i) {
        for (int j = 0; j < matOne.width; ++j, ++index) {
            retValP[index] = [matOne[i*matOne.width + j] floatValue];
        }
        for (int j = 0; j < matTwo.width; ++j,++index) {
            retValP[index] = [matTwo[i*matTwo.width + j] floatValue];
        }
    }
    return retVal;
}

@end
