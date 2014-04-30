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
        vDSP_meanv(inputMatrix + i*rWidth, 1, outputVector+i, rWidth);
    }
    if(shouldFreeInput) {
        free(inputMatrix); inputMatrix = NULL;
    }
    
}
-(void)subtractFloatVector:(float*)subtrahend fromFloatVector:(float*)minuend numberOfElements:(NSUInteger)elements freeInput:(BOOL)shouldFreeInput{
    
    vDSP_vsub(subtrahend, 1, minuend, 1, minuend, 1, elements);
    if (shouldFreeInput) {
        free(subtrahend); subtrahend = NULL;
    }
    
}

-(void)addFloatMatrix:(float*)inputMatrixOne toFloatMatrix:(float*)inputMatrixTwo intoResultFloatMatrix:(float*)outputMatrix columnHeight:(NSUInteger)cHeight rowWidth:(NSUInteger)rWidth freeInput:(BOOL)shouldFreeInput {
    
    vDSP_vadd(inputMatrixOne, 1, inputMatrixTwo, 1, outputMatrix, 1, cHeight*rWidth);
    if(shouldFreeInput) {
        free(inputMatrixOne); inputMatrixOne = NULL;
        free(inputMatrixTwo); inputMatrixTwo = NULL;
    }
}
-(void)transposeFloatMatrix:(float*)inputMatrix transposed:(float*)outputMatrix columnHeight:(NSUInteger)cHeight rowWidth:(NSUInteger)rWidth freeInput:(BOOL)shouldFreeInput {
    
    vDSP_mtrans(inputMatrix, 1, outputMatrix, 1, rWidth, cHeight);
    if (shouldFreeInput) {
        free(inputMatrix); inputMatrix = NULL;
    }
    
}
-(void)multiplyFloatMatrix:(float*)inputMatrixOne withFloatMatrix:(float*)inputMatrixTwo product:(float*)product matrixOneColumnHeight:(NSUInteger)cOneHeight matrixOneRowWidth:(NSUInteger)rOneWidth matrixTwoRowWidth:(NSUInteger)rTwoWidth freeInputs:(BOOL)shouldFreeInputs {
    
    double* oneD = nil; check_alloc_error(posix_memalign((void**)&oneD, kAlignment, cOneHeight*rOneWidth*sizeof(double)));
    double* twoD = nil; check_alloc_error(posix_memalign((void**)&twoD, kAlignment, rTwoWidth*rOneWidth*sizeof(double)));
    double* productD = nil; check_alloc_error(posix_memalign((void**)&productD, kAlignment, cOneHeight*rTwoWidth*sizeof(double)));
    
    vDSP_vspdp(inputMatrixOne, 1, oneD, 1, cOneHeight*rOneWidth);
    vDSP_vspdp(inputMatrixTwo, 1, twoD, 1, rTwoWidth*rOneWidth);
    
    vDSP_mmulD(oneD, 1, twoD, 1, productD, 1, cOneHeight, rTwoWidth, rOneWidth);
    if (shouldFreeInputs) {
        free(inputMatrixOne); inputMatrixOne = NULL;
        free(inputMatrixTwo); inputMatrixTwo = NULL;
    }
    vDSP_vdpsp(productD, 1, product, 1, cOneHeight*rTwoWidth);
}

-(void)eigendecomposeSymmetricFloatMatrix:(float*)inputMatrix intoEigenvalues:(float*)eigenvalues eigenvectors:(float*)eigenvectors numberOfImportantValues:(NSUInteger)numberOfImportantValues matrixDimension:(NSUInteger)dimension freeInput:(BOOL)shouldFreeInput {
    
    // il and ul could change.
    // 1 -> dimension - numberOfImportantValues ==> should be smallest
    // dimension - numberOfImportantValues -> dimension ==> should be largest
//    __CLPK_integer il = dimension - numberOfImportantValues + 1;
//    __CLPK_integer ul = dimension;
    __CLPK_integer il = 1;
    __CLPK_integer ul = (int)numberOfImportantValues;
    __CLPK_real abstol = -1,vl,vu;
    __CLPK_integer foundEigenvalues, info;
//    __CLPK_integer* iwork = calloc(1, sizeof(__CLPK_integer));
    __CLPK_integer iwork = 0;
//    __CLPK_integer* isuppz = calloc(dimension, sizeof(__CLPK_integer));
    __CLPK_integer *isuppz __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&isuppz, kAlignment, 2*dimension*sizeof(__CLPK_integer)));
    __CLPK_integer lwork = -1, liwork = -1, n = (int)dimension, lda = (int)dimension;
//    __CLPK_real* work = calloc(1, sizeof(__CLPK_real));
    
    __CLPK_real work = 0.f;
    
    ssyevr_("V", "I", "U", &n, inputMatrix, &lda, &vl, &vu, &il, &ul, &abstol, &foundEigenvalues, eigenvalues, eigenvectors, &n, isuppz, &work, &lwork, &iwork, &liwork, &info);
    lwork = (int)work;
//    work = (float*)reallocf(work, lwork*sizeof(float) );
    __CLPK_real *WORK_PTR __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&WORK_PTR, kAlignment, lwork*sizeof(__CLPK_real)));
    liwork = iwork;
//    iwork = (long*)reallocf(iwork, liwork*sizeof(long) );
    __CLPK_integer *I_WORK_PTR __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&I_WORK_PTR, kAlignment, liwork*sizeof(__CLPK_integer)));

    ssyevr_("V", "I", "U", &n, inputMatrix, &lda, &vl, &vu, &il, &ul, &abstol, &foundEigenvalues, eigenvalues, eigenvectors, &n, isuppz, WORK_PTR, &lwork, I_WORK_PTR, &liwork, &info);
    
    if(info > 0) {
        NSLog(@"failed to computer eigenvalues");
    }
    free(I_WORK_PTR); I_WORK_PTR = NULL;
    free(WORK_PTR); WORK_PTR = NULL;
    free(isuppz); isuppz = NULL;
    if(shouldFreeInput) {
        free(inputMatrix); inputMatrix = NULL;
    }
//    [self transposeFloatMatrix:eigenvectors transposed:eigenvectors columnHeight:numberOfImportantValues rowWidth:dimension freeInput:NO];
    
}

-(void)eigendecomposeFloatMatrix:(float*)inputMatrix intoEigenvalues:(float*)eigenvalues eigenvectors:(float*)eigenvectors numberOfImportantValues:(NSUInteger)numberOfImportantValues matrixDimension:(NSUInteger)dimension freeInput:(BOOL)shouldFreeInput {
    __CLPK_integer n = (int)dimension, lda = (int)dimension, info,lwork =-1;
    __CLPK_real wi[n] __attribute__((aligned(kAlignment))), wkopt = -1;
//    __CLPK_real work = calloc(1, sizeof(__CLPK_real));
   
    sgeev_("N", "V", &n, inputMatrix, &lda, eigenvalues, wi, NULL, &n, eigenvectors, &n, &wkopt, &lwork, &info);
    lwork = (int)wkopt;
//    work = (float*)reallocf(work, lwork*sizeof(float) );
    __CLPK_real *WORK_PTR __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&WORK_PTR, kAlignment, lwork*sizeof(__CLPK_real)));
    sgeev_("N", "V", &n, inputMatrix, &lda, eigenvalues, wi, NULL, &n, eigenvectors, &n, WORK_PTR, &lwork, &info);
    if(info > 0) {
        NSLog(@"failed to computer eigenvalues");
    }
    free(WORK_PTR); WORK_PTR = NULL;
    if (shouldFreeInput) {
        free(inputMatrix); inputMatrix = NULL;
    }
    
}

-(void)eigendecomposeGeneralizedMatricesA:(float *)A andB:(float *)B intoEigenvalues:(float *)eigenvalues eigenvectors:(float *)eigenvectors numberOfImportantValues:(NSUInteger)numImportant maxtrixDimension:(NSUInteger)dimension freeInput:(BOOL)shouldFreeInput {
    
    __CLPK_integer n = (int)dimension, lda = (int)dimension, ldb = (int)dimension, ldvr = (int)n,lwork = -1,info;
    __CLPK_real wkopt = -1;
    __CLPK_integer ONE = 1;
    
    __CLPK_real *alphar __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&alphar, kAlignment, n*sizeof(__CLPK_real)));
    __CLPK_real *alphai __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&alphai, kAlignment, n*sizeof(__CLPK_real)));
    __CLPK_real *beta __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&beta, kAlignment, n*sizeof(__CLPK_real)));
//    
//    __CLPK_real *leftEigenvect __attribute__((aligned(kAlignment))) = NULL;
//    check_alloc_error(posix_memalign((void**)&leftEigenvect, kAlignment, n*n*sizeof(__CLPK_real)));
    
    sggev_("N", "V", &n, A, &lda, B, &ldb, alphar, alphai, beta, NULL, &ldvr, eigenvectors, &ldvr, &wkopt, &lwork, &info);
    if(info != 0) {
        @throw [NSString stringWithFormat:@"Info was non-zero... %d",info];
    }
    lwork = (int)wkopt;
    __CLPK_real *WORK_PTR __attribute__((aligned(kAlignment))) = NULL;
    check_alloc_error(posix_memalign((void**)&WORK_PTR, kAlignment, lwork*sizeof(__CLPK_real)));
    sggev_("N", "V", &n, A, &lda, B, &ldb, alphar, alphai, beta, NULL, &ldvr, eigenvectors, &ldvr, WORK_PTR, &lwork, &info);
    
    for (int i = 0; i < n; ++i) {
        if (beta[i] < .0000000001) {
            eigenvalues[i]= 0;
        } else {
            eigenvalues[i] = alphar[i]/beta[i];
        }
    }
    NSLog(@"");
}


-(void)clearFloatMatrix:(float*)inputMatrix numberOfElements:(NSUInteger)elements {
    vDSP_vclr(inputMatrix, 1, elements);
}

-(void)invertFloatMatrix:(float*)inputMatrix intoResult:(float*)outputMatrix matrixDimension:(NSUInteger)dimension freeInput:(BOOL)shouldFreeInput {
    
//    __CLPK_integer *IPIV = calloc(dimension+1, sizeof(__CLPK_integer));
    __CLPK_integer IPIV[dimension+1]  __attribute__ ((aligned));
    __CLPK_integer LWORK = ((__CLPK_integer)dimension*((__CLPK_integer)dimension));
//    __CLPK_real *WORK = calloc(LWORK, sizeof(__CLPK_real));
    __CLPK_real WORK[LWORK]  __attribute__ ((aligned));
    __CLPK_integer INFO, N = (__CLPK_integer) dimension;
    
//    [self transposeFloatMatrix:inputMatrix transposed:outputMatrix columnHeight:dimension rowWidth:dimension freeInput:NO];
    [self copyVector:inputMatrix toVector:outputMatrix numberOfElements:dimension*dimension sizeOfType:sizeof(RawType)];
    sgetrf_(&N,&N,outputMatrix,&N,IPIV,&INFO);
    sgetri_(&N,outputMatrix,&N,IPIV,WORK,&LWORK,&INFO);
    
//    [self transposeFloatMatrix:outputMatrix transposed:outputMatrix columnHeight:dimension rowWidth:dimension freeInput:NO];
    
    //free(IPIV);
    //free(WORK);
    if(shouldFreeInput) {
        free(inputMatrix); inputMatrix = NULL;
    }
}

@end
