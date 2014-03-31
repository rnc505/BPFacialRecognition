//
//  BPMatrix.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 3/28/14.
//  Copyright (c) 2014 BP. All rights reserved.
//
#define swap(a, b) {a^=b;b^=a;a^=b;}
#import "BPMatrix.h"
#import "BPRecognizerCPUOperator.h"
@interface BPMatrix()
@property(nonatomic, retain) NSMutableData* data;
@property(nonatomic, retain) BPRecognizerCPUOperator *operator;
@property (nonatomic, readwrite) NSUInteger width;
@property (nonatomic, readwrite) NSUInteger height;
@property (nonatomic, retain, readwrite) BPMatrix* eigenvalues;
@property (nonatomic, retain, readwrite) BPMatrix* eigenvectors;
-(id)initWithWidth:(NSUInteger)width withHeight:(NSUInteger)height withPrimitiveSize:(NSUInteger)size;
-(id)initWithWidth:(NSUInteger)width withHeight:(NSUInteger)height withPrimitiveSize:(NSUInteger)size withMemory:(void*)memory;
-(void*)allocateNewMemoryOfDimension:(CGSize)dimensions ofPrimitiveSize:(NSUInteger)size;
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

-(BPMatrix*)duplicate {
    void* mem = [self allocateNewMemoryOfDimension:CGSizeMake(_width, _height) ofPrimitiveSize:_size];
    [_operator copyVector:(void*)[self getData] toVector:mem numberOfElements:_height*_width sizeOfType:_size];
    return [[BPMatrix alloc] initWithWidth:_width withHeight:_height withPrimitiveSize:_size withMemory:mem];
}

+(BPMatrix*)matrixWithMultiplicationOfMatrixOne:(BPMatrix *)matrixOne withMatrixTwo:(BPMatrix *)matrixTwo {
    return [[matrixOne duplicate] multiplyBy:matrixTwo];
}

-(BPMatrix*)multiplyBy:(BPMatrix *)rightMatrix {
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
    [_operator subtractFloatVector:(void*)[rightMatrix getData] fromFloatVector:[self getMutableData] numberOfElements:_height*_width freeInput:NO];
    return self;
}
-(BPMatrix*)eigendecomposeIsSymmetric:(BOOL)isSymmetric withNumberOfValues:(NSUInteger)eigenval withNumberOfVectors:(NSUInteger)eigenvec{
    void *newEigenvalues = [self allocateNewMemoryOfDimension:CGSizeMake(eigenval, 1) ofPrimitiveSize:_size];
    void *newEigenvectors = [self allocateNewMemoryOfDimension:CGSizeMake(eigenval, eigenvec/eigenval) ofPrimitiveSize:_size];
    if(isSymmetric) {
        // into newEigenvalues = [smallest, 2nd smallest,..., largest]
        // into newEigenvectors = [smallestEV1, smallestEV2,...smallestEVn, 2nd smallestEV1, 2nd smallestEV2,... 2nd smallestEVn,... largestEV1, largestEV2,...largestEVn]
        [_operator eigendecomposeSymmetricFloatMatrix:(void*)[self getMutableData] intoEigenvalues:newEigenvalues eigenvectors:newEigenvectors numberOfImportantValues:eigenval matrixDimension:eigenvec/eigenval freeInput:NO];
    } else {
        [_operator eigendecomposeFloatMatrix:(void*)[self getMutableData] intoEigenvalues:newEigenvalues eigenvectors:newEigenvectors numberOfImportantValues:eigenval matrixDimension:eigenvec/eigenval freeInput:NO];
    }
    [self setEigenvalues:[[BPMatrix alloc] initWithWidth:eigenval withHeight:1 withPrimitiveSize:_size withMemory:newEigenvalues]];
    [self setEigenvectors:[[BPMatrix alloc] initWithWidth:eigenval withHeight:eigenvec/eigenval withPrimitiveSize:_size withMemory:newEigenvectors]];
    return self;
}
-(BPMatrix*)addBy:(BPMatrix*)rightMatrix {
    [_operator addFloatMatrix:(void*)[self getData] toFloatMatrix:(void*)[rightMatrix getData] intoResultFloatMatrix:(void*)[self getMutableData] columnHeight:_height rowWidth:_width freeInput:NO];
    return self;
}
-(BPMatrix*)zeroOutData {
    [_operator clearFloatMatrix:[self getMutableData] numberOfElements:_width*_height];
    return self;
}
-(BPMatrix*)invertMatrix {
    [_operator invertFloatMatrix:(void*)[self getData] intoResult:(void*)[self getMutableData] matrixDimension:_width freeInput:NO];
    return self;
}

@end
