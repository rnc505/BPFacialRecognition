//
//  BPRecognizerCPUOperator.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 2/5/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import "BPRecognizerCPUOperator.h"

@implementation BPRecognizerCPUOperator
-(void)copyVector:(void*)inputVector toVector:(void*)outputVector numberOfElements:(NSUInteger)elements offset:(NSUInteger)offset sizeOfType:(NSUInteger)typeSize {
    
    // copys the memory from inputVector into outputVector + an offset
    memcpy(outputVector+(elements*offset*typeSize), inputVector, elements*typeSize);
    
}

-(void)copyVector:(void*)inputVector toVector:(void*)outputVector numberOfElements:(NSUInteger)elements sizeOfType:(NSUInteger)typeSize {
    [self copyVector:inputVector toVector:outputVector numberOfElements:elements offset:0 sizeOfType:typeSize];
}

-(void)columnWiseMeanOfDoubleMatrix:(double*)inputMatrix toDoubleVector:(double*)outputVector columnHeight:(NSUInteger)cHeight rowWidth:(NSUInteger)rWidth freeInput:(BOOL)shouldFreeInput {
    
    for (int i = 0; i < cHeight; ++i) {
        vDSP_meanvD(inputMatrix + i, cHeight, outputVector+i, rWidth);
    }
    if(shouldFreeInput)
        free(inputMatrix);
    
}
-(void)subtractDoubleVector:(double*)subtrahend fromDoubleVector:(double*)minuend numberOfElements:(NSUInteger)elements freeInput:(BOOL)shouldFreeInput{
    
    vDSP_vsubD(subtrahend, 1, minuend, 1, minuend, 1, elements);
    if (shouldFreeInput) {
        free(subtrahend);
    }
    
}
-(void)transposeDoubleMatrix:(double*)inputMatrix transposed:(double*)outputMatrix columnHeight:(NSUInteger)cHeight rowWidth:(NSUInteger)rWidth freeInput:(BOOL)shouldFreeInput {
    
    vDSP_mtransD(inputMatrix, 1, outputMatrix, 1, rWidth, cHeight);
    if (shouldFreeInput) {
        free(inputMatrix);
    }
    
}
-(void)multiplyDoubleMatrix:(double*)inputMatrixOne withDoubleMatrix:(double*)inputMatrixTwo product:(double*)product matrixOneColumnHeight:(NSUInteger)cOneHeight matrixOneRowWidth:(NSUInteger)rOneWidth matrixTwoRowWidth:(NSUInteger)rTwoWidth freeInputs:(BOOL)shouldFreeInputs {
    
    vDSP_mmulD(inputMatrixOne, 1, inputMatrixTwo, 1, product, 1, cOneHeight, rTwoWidth, rOneWidth);
    if (shouldFreeInputs) {
        free(inputMatrixOne);
        free(inputMatrixTwo);
    }
    
}
@end
