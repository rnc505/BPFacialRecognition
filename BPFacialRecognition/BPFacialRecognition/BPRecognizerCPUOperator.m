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

-(void)addFloatMatrix:(float*)inputMatrixOne toFloatMatrix:(float*)inputMatrixTwo intoResultFloatMatrix:(float*)outputMatrix columnHeight:(NSUInteger)cHeight rowWidth:(NSUInteger)rWidth freeInput:(BOOL)shouldFreeInput {
    
    vadd(inputMatrixOne, 1, inputMatrixTwo, 1, outputMatrix, 1, cHeight*rWidth);
    if(shouldFreeInput) {
        free(inputMatrixOne);
        free(inputMatrixTwo);
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

-(void)eigendecomposeSymmetricFloatMatrix:(float*)inputMatrix intoEigenvalues:(float*)eigenvalues eigenvectors:(float*)eigenvectors numberOfImportantValues:(NSUInteger)numberOfImportantValues matrixDimension:(NSUInteger)dimension freeInput:(BOOL)shouldFreeInput {
    
    // il and ul could change.
    // 1 -> dimension - numberOfImportantValues ==> should be smallest
    // dimension - numberOfImportantValues -> dimension ==> should be largest
//    __CLPK_integer il = dimension - numberOfImportantValues + 1;
//    __CLPK_integer ul = dimension;
    __CLPK_integer il = 1;
    __CLPK_integer ul = dimension - numberOfImportantValues+1;
    __CLPK_real abstol = -1,vl,vu;
    __CLPK_integer foundEigenvalues, info;
    __CLPK_integer* iwork = calloc(1, sizeof(__CLPK_integer));
    __CLPK_integer* isuppz = calloc(dimension, sizeof(__CLPK_integer));
    __CLPK_integer lwork = -1, liwork = -1, n = dimension, lda = dimension;
    __CLPK_real* work = calloc(1, sizeof(__CLPK_real));
    ssyevr_("V", "I", "U", &n, inputMatrix, &lda, &vl, &vu, &il, &ul, &abstol, &foundEigenvalues, eigenvalues, eigenvectors, &n, isuppz, work, &lwork, iwork, &liwork, &info);
    lwork = (int)*work;
    work = (float*)reallocf(work, lwork*sizeof(float) );
    liwork = *iwork;
    iwork = (long*)reallocf(iwork, liwork*sizeof(long) );

    ssyevr_("V", "I", "U", &n, inputMatrix, &lda, &vl, &vu, &il, &n, &abstol, &foundEigenvalues, eigenvalues, eigenvectors, &n, isuppz, work, &lwork, iwork, &liwork, &info);
    
    if(info > 0) {
        NSLog(@"failed to computer eigenvalues");
    }
    free(iwork); free(work); free(isuppz);
    if(shouldFreeInput) {
        free(inputMatrix);
    }
}

-(void)eigendecomposeFloatMatrix:(float*)inputMatrix intoEigenvalues:(float*)eigenvalues eigenvectors:(float*)eigenvectors numberOfImportantValues:(NSUInteger)numberOfImportantValues matrixDimension:(NSUInteger)dimension freeInput:(BOOL)shouldFreeInput {
    __CLPK_integer n = dimension, lda = dimension, info,lwork =-1;
    __CLPK_real wr[n], wi[n], wkopt = -1, *work = calloc(1, sizeof(__CLPK_real));
    sgeev_("N", "V", &n, inputMatrix, &lda, wr, wi, NULL, &n, eigenvectors, &n, &wkopt, &lwork, &info);
    lwork = (int)wkopt;
    work = (float*)reallocf(work, lwork*sizeof(float) );
    sgeev_("N", "V", &n, inputMatrix, &lda, wr, wi, NULL, &n, eigenvectors, &n, work, &lwork, &info);
    if(info > 0) {
        NSLog(@"failed to computer eigenvalues");
    }
    free(work);
    if (shouldFreeInput) {
        free(inputMatrix);
    }
    
}

-(void)clearFloatMatrix:(float*)inputMatrix numberOfElements:(NSUInteger)elements {
    vDSP_vclr(inputMatrix, 1, elements);
}

-(void)invertFloatMatrix:(float*)inputMatrix intoResult:(float*)outputMatrix matrixDimension:(NSUInteger)dimension freeInput:(BOOL)shouldFreeInput {
    
//    __CLPK_integer *IPIV = calloc(dimension+1, sizeof(__CLPK_integer));
    __CLPK_integer IPIV[dimension+1]  __attribute__ ((aligned));
    __CLPK_integer LWORK = dimension*dimension;
//    __CLPK_real *WORK = calloc(LWORK, sizeof(__CLPK_real));
    __CLPK_real WORK[LWORK]  __attribute__ ((aligned));
    __CLPK_integer INFO, N = dimension;
    
    sgetrf_(&N,&N,inputMatrix,&N,IPIV,&INFO);
    sgetri_(&N,inputMatrix,&N,IPIV,WORK,&LWORK,&INFO);
    
    //free(IPIV);
    //free(WORK);
    if(shouldFreeInput) {
        free(inputMatrix);
    }
}

@end
