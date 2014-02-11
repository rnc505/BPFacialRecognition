//
//  BPRecognizerOperator.h
//  BPFacialRecognition
//
//  Created by Robby Cohen on 2/5/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BPRecognizerOperator <NSObject>
-(void)copyVector:(void*)inputVector toVector:(void*)outputVector numberOfElements:(NSUInteger)elements offset:(NSUInteger)offset sizeOfType:(NSUInteger)typeSize;
-(void)copyVector:(void*)inputVector toVector:(void*)outputVector numberOfElements:(NSUInteger)elements sizeOfType:(NSUInteger)typeSize;
-(void)columnWiseMeanOfFloatMatrix:(float*)inputMatrix toFloatVector:(float*)outputVector columnHeight:(NSUInteger)cHeight rowWidth:(NSUInteger)rWidth freeInput:(BOOL)shouldFreeInput;
-(void)subtractFloatVector:(float*)subtrahend fromFloatVector:(float*)minuend numberOfElements:(NSUInteger)elements freeInput:(BOOL)shouldFreeInput;
-(void)transposeFloatMatrix:(float*)inputMatrix transposed:(float*)outputMatrix columnHeight:(NSUInteger)cHeight rowWidth:(NSUInteger)rWidth freeInput:(BOOL)shouldFreeInput;
-(void)multiplyFloatMatrix:(float*)inputMatrixOne withFloatMatrix:(float*)inputMatrixTwo product:(float*)product matrixOneColumnHeight:(NSUInteger)cOneHeight matrixOneRowWidth:(NSUInteger)rOneWidth matrixTwoRowWidth:(NSUInteger)rTwoWidth freeInputs:(BOOL)shouldFreeInputs;
-(void)eigendecomposeFloatMatrix:(float*)inputMatrix intoEigenvalues:(float*)eigenvalues eigenvectors:(float*)eigenvectors numberOfImportantValues:(NSUInteger)numberOfImportantValues matrixDimension:(NSUInteger)dimension freeInput:(BOOL)shouldFreeInput;
@end
