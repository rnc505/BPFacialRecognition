//
//  BPMatrix.h
//  BPFacialRecognition
//
//  Created by Robby Cohen on 3/28/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPMatrix : NSObject
@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, readonly) NSUInteger height;
@property (nonatomic, readonly) NSUInteger size;
@property (nonatomic, retain, readonly) BPMatrix* eigenvalues;
@property (nonatomic, retain, readonly) BPMatrix* eigenvectors;
+(id)matrixWithDimensions:(CGSize)dimension withPrimitiveSize:(NSUInteger)size;
+(BPMatrix*)matrixWithMultiplicationOfMatrixOne:(BPMatrix*)matrixOne withMatrixTwo:(BPMatrix*)matrixTwo;
+(BPMatrix*)matrixWithSubtractionOfMatrixOne:(BPMatrix*)matrixOne byMatrixTwo:(BPMatrix*)matrixTwo;
+(BPMatrix*)matrixWithAdditionOfMatrixOne:(BPMatrix*)matrixOne WithMatrixTwo:(BPMatrix*)matrixTwo;

-(const void*)getData;
-(void*)getMutableData;

-(BPMatrix*)transpose;
-(BPMatrix*)multiplyBy:(BPMatrix*)rightMatrix;
-(BPMatrix*)duplicate;
-(BPMatrix*)meanOfRows;
-(BPMatrix*)subtractedBy:(BPMatrix*)rightMatrix;
-(BPMatrix*)eigendecomposeIsSymmetric:(BOOL)isSymmetric withNumberOfValues:(NSUInteger)eigenval withNumberOfVectors:(NSUInteger)eigenvec;
-(BPMatrix*)addBy:(BPMatrix*)rightMatrix;
-(BPMatrix*)zeroOutData;
-(BPMatrix*)invertMatrix;


@end
