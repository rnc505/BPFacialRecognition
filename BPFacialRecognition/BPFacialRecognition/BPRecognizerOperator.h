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
-(void)columnWiseMeanOfDoubleMatrix:(double*)inputMatrix toDoubleVector:(double*)outputVector columnHeight:(NSUInteger)cHeight rowWidth:(NSUInteger)rWidth freeInput:(BOOL)shouldFreeInput;
-(void)subtractDoubleVector:(double*)subtrahend fromDoubleVector:(double*)minuend numberOfElements:(NSUInteger)elements freeInput:(BOOL)shouldFreeInput;
-(void)transposeDoubleMatrix:(double*)inputMatrix transposed:(double*)outputMatrix columnHeight:(NSUInteger)cHeight rowWidth:(NSUInteger)rWidth freeInput:(BOOL)shouldFreeInput;
-(void)multiplyDoubleMatrix:(double*)inputMatrixOne withDoubleMatrix:(double*)inputMatrixTwo product:(double*)product matrixOneColumnHeight:(NSUInteger)cOneHeight matrixOneRowWidth:(NSUInteger)rOneWidth matrixTwoRowWidth:(NSUInteger)rTwoWidth freeInputs:(BOOL)shouldFreeInputs;
@end
