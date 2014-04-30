//
//  BPEigen.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 4/29/14.
//  Copyright (c) 2014 BP. All rights reserved.
//
#import "BPEigen.h"
#import "BPMatrix.h"
#include <Eigen/Dense>
#include <iostream>
#define EIGEN_DONT_VECTORIZE
using namespace Eigen;

@implementation BPEigen : NSObject 
+(void)eigendecomposeGeneralizedMatricesA:(BPMatrix *)A andB:(BPMatrix *)B intoEigenvalues:(float *)eigenvalues eigenvectors:(float *)eigenvectors numberOfImportantValues:(NSUInteger)numImportant maxtrixDimension:(NSUInteger)dimension freeInput:(BOOL)shouldFreeInput {
    
    BPMatrix *invertBtimesA = [[B invertMatrix] multiplyBy:A];
    
    MatrixXf a(numImportant,numImportant);//, b(numImportant,numImportant);
//    BPEigen.fill
    
    for(int i = 0; i < numImportant; ++i) {
        for(int j = 0; j < numImportant; ++j) {
            a(i,j) = [invertBtimesA[i*numImportant+j] floatValue];
            //b(i,j) = B[i*numImportant+j];
        }
    }
    EigenSolver<MatrixXf> ges;
    ges.compute(a);
    //ges.compute(a, b);
    std::cout << a << std::endl;
//    std::cout << b << std::endl;
    std::cout << "Values: " <<ges.eigenvalues().transpose() << std::endl;
    std::cout << "Vectors: " << ges.eigenvectors().transpose() << std::endl;

}

+(void)test {
    MatrixXf a(3,3);
    BPMatrix *A = [BPMatrix matrixWithDimensions:CGSizeMake(3, 3) withPrimitiveSize:sizeof(RawType)];
    A[0] = @(1), A[1] = @(2), A[2] = @(3), A[3] = @(4), A[4] = @(5), A[5] = @(6), A[6] = @(7), A[7] = @(8), A[8] = @(9);
    NSUInteger numImportant = 3;
    for(int i = 0; i < numImportant; ++i) {
        for(int j = 0; j < numImportant; ++j) {
            a(i,j) = [A[i*numImportant+j] floatValue];
        }
    }
    std::cout<< a << std::endl;
}
//+(void)fillInMatrixXf:(MatrixXf*)mat withValues:(float*)source ofSquareDimensions:(NSUInteger)dim {

//}
@end
