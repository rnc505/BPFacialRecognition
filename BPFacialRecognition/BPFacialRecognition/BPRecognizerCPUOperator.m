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

-(void)columnWiseMeanOfFloatMatrix:(float*)inputMatrix toFloatVector:(float*)outputVector columnHeight:(NSUInteger)cHeight rowWidth:(NSUInteger)rWidth freeInput:(BOOL)shouldFreeInput {
    
    for (int i = 0; i < cHeight; ++i) {
        vDSP_meanv(inputMatrix + i, cHeight, outputVector+i, rWidth);
    }
    if(shouldFreeInput)
        free(inputMatrix);
    
}
-(void)subtractFloatVector:(float*)subtrahend fromFloatVector:(float*)minuend numberOfElements:(NSUInteger)elements freeInput:(BOOL)shouldFreeInput{
    
    vDSP_vsub(subtrahend, 1, minuend, 1, minuend, 1, elements);
    if (shouldFreeInput) {
        free(subtrahend);
    }
    
}
-(void)transposeFloatMatrix:(float*)inputMatrix transposed:(float*)outputMatrix columnHeight:(NSUInteger)cHeight rowWidth:(NSUInteger)rWidth freeInput:(BOOL)shouldFreeInput {
    
    vDSP_mtrans(inputMatrix, 1, outputMatrix, 1, rWidth, cHeight);
    if (shouldFreeInput) {
        free(inputMatrix);
    }
    
}
-(void)multiplyFloatMatrix:(float*)inputMatrixOne withFloatMatrix:(float*)inputMatrixTwo product:(float*)product matrixOneColumnHeight:(NSUInteger)cOneHeight matrixOneRowWidth:(NSUInteger)rOneWidth matrixTwoRowWidth:(NSUInteger)rTwoWidth freeInputs:(BOOL)shouldFreeInputs {
    
    vDSP_mmul(inputMatrixOne, 1, inputMatrixTwo, 1, product, 1, cOneHeight, rTwoWidth, rOneWidth);
    if (shouldFreeInputs) {
        free(inputMatrixOne);
        free(inputMatrixTwo);
    }
    
}
@end
