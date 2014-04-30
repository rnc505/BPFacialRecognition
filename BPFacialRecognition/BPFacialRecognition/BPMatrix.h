//
//  BPMatrix.h
//  BPFacialRecognition
//
//  Created by Robby Cohen on 3/28/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPMatrix : NSObject
@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;
@property (nonatomic, readonly) NSUInteger size;
@property (nonatomic, retain, readonly) BPMatrix* eigenvalues;
@property (nonatomic, retain, readonly) BPMatrix* eigenvectors;
+(id)matrixWithDimensions:(CGSize)dimension withPrimitiveSize:(NSUInteger)size;
+(BPMatrix*)null;
+(BPMatrix*)matrixWithMultiplicationOfMatrixOne:(BPMatrix*)matrixOne withMatrixTwo:(BPMatrix*)matrixTwo;
+(BPMatrix*)matrixWithSubtractionOfMatrixOne:(BPMatrix*)matrixOne byMatrixTwo:(BPMatrix*)matrixTwo;
+(BPMatrix*)matrixWithAdditionOfMatrixOne:(BPMatrix*)matrixOne WithMatrixTwo:(BPMatrix*)matrixTwo;
+(RawType)euclideanDistanceBetweenMatrixOne:(BPMatrix*)matrixOne andMatrixTwo:(BPMatrix*)matrixTwo;
+(BPMatrix*)concatMatrixOne:(BPMatrix*)matOne withMatrixTwo:(BPMatrix*)matTwo;

+(BPMatrix *)eigendecomposeGeneralizedMatrixA:(BPMatrix*)A andB:(BPMatrix*)B WithNumberOfValues:(NSUInteger)numValues numberOfVector:(NSUInteger)numVectors;
-(const void*)getData;
-(void*)getMutableData;
-(BPMatrix*)transpose;
-(BPMatrix*)transposedNew;
-(BPMatrix*)multiplyBy:(BPMatrix*)rightMatrix;
-(BPMatrix*)duplicate;
-(BPMatrix*)meanOfRows;
-(BPMatrix*)subtractedBy:(BPMatrix*)rightMatrix;
-(BPMatrix*)eigendecomposeIsSymmetric:(BOOL)isSymmetric withNumberOfValues:(NSUInteger)eigenval withNumberOfVectors:(NSUInteger)eigenvec;
-(BPMatrix*)addBy:(BPMatrix*)rightMatrix;
-(BPMatrix*)zeroOutData;
-(BPMatrix*)invertMatrix;

-(BPMatrix*)getColumnAtIndex:(NSUInteger)index;
-(BPMatrix*)getRowAtIndex:(NSUInteger)index;

-(BPMatrix*)getColumnsFromIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2;

-(BPMatrix*)stretchByNumberOfRows:(NSUInteger)numRows;
-(BPMatrix*)flippedL2R;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
@end
