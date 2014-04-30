//
//  BPEigen.h
//  BPFacialRecognition
//
//  Created by Robby Cohen on 4/29/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPMatrix.h"
@interface BPEigen : NSObject
+(void)eigendecomposeGeneralizedMatricesA:(BPMatrix*)A andB:(BPMatrix*)B intoEigenvalues:(float*)eigenvalues eigenvectors:(float*)eigenvectors numberOfImportantValues:(NSUInteger)numImportant maxtrixDimension:(NSUInteger)dimension freeInput:(BOOL)shouldFreeInput;
//+(void)fillInMatrixXf:(MatrixXf*)mat withValues:(float*)source ofSquareDimensions:(NSUInteger)dim;
+(void)test;
@end
