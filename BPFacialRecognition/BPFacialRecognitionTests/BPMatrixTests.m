//
//  BPMatrixTests.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 3/30/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BPMatrix.h"
#import "BPEigen.h"
@interface BPMatrixTests : XCTestCase

@end

@implementation BPMatrixTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testMultiplicationNumbers_Class {
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(5, 2) withPrimitiveSize:sizeof(RawType)];
    BPMatrix* B = [BPMatrix matrixWithDimensions:CGSizeMake(3, 5) withPrimitiveSize:sizeof(RawType)];
    
    RawType* APointer = [A getMutableData];
    RawType* BPointer = [B getMutableData];
    
    for (int i = 0; i < 10; ++i) {
        APointer[i] = i;
    }
    
    for (int i = 0; i < 15; ++i) {
        BPointer[i] = i;
    }
    
    BPMatrix* C = [BPMatrix matrixWithMultiplicationOfMatrixOne:A withMatrixTwo:B];
    RawType* CPointer = (RawType*)[C getData];
    BOOL fail = false;
    fail = CPointer[0] != 90; XCTAssertFalse(fail, @"Multiplication occured incorrectly");
    fail = CPointer[1] != 100; XCTAssertFalse(fail, @"Multiplication occured incorrectly");
    fail = CPointer[2] != 110; XCTAssertFalse(fail, @"Multiplication occured incorrectly");
    fail = CPointer[3] != 240; XCTAssertFalse(fail, @"Multiplication occured incorrectly");
    fail = CPointer[4] != 275; XCTAssertFalse(fail, @"Multiplication occured incorrectly");
    fail = CPointer[5] != 310; XCTAssertFalse(fail, @"Multiplication occured incorrectly");
    
}

- (void)testMultiplicationNumbers_Instance {
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(5, 2) withPrimitiveSize:sizeof(RawType)];
    BPMatrix* B = [BPMatrix matrixWithDimensions:CGSizeMake(3, 5) withPrimitiveSize:sizeof(RawType)];
    
    RawType* APointer = [A getMutableData];
    RawType* BPointer = [B getMutableData];
    
    for (int i = 0; i < 10; ++i) {
        APointer[i] = i;
    }
    
    for (int i = 0; i < 15; ++i) {
        BPointer[i] = i;
    }
    
    [A multiplyBy:B];
    RawType* CPointer = (RawType*)[A getData];
    BOOL fail = false;
    fail = CPointer[0] != 90; XCTAssertFalse(fail, @"Multiplication occured incorrectly");
    fail = CPointer[1] != 100; XCTAssertFalse(fail, @"Multiplication occured incorrectly");
    fail = CPointer[2] != 110; XCTAssertFalse(fail, @"Multiplication occured incorrectly");
    fail = CPointer[3] != 240; XCTAssertFalse(fail, @"Multiplication occured incorrectly");
    fail = CPointer[4] != 275; XCTAssertFalse(fail, @"Multiplication occured incorrectly");
    fail = CPointer[5] != 310; XCTAssertFalse(fail, @"Multiplication occured incorrectly");
    
}

- (void)testSubtractNumbers_Class {
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(5, 2) withPrimitiveSize:sizeof(RawType)];
    BPMatrix* B = [BPMatrix matrixWithDimensions:CGSizeMake(5, 2) withPrimitiveSize:sizeof(RawType)];
    
    RawType* APointer = [A getMutableData];
    RawType* BPointer = [B getMutableData];
    
    for (int i = 0; i < 10; ++i) {
        APointer[i] = i;
    }
    
    for (int i = 0; i < 10; ++i) {
        BPointer[i] = 3*i;
    }
    
    BPMatrix* C = [BPMatrix matrixWithSubtractionOfMatrixOne:B byMatrixTwo:A];
    RawType* CPointer = (RawType*)[C getData];
    for (int i = 0; i < 10; ++i) {
        XCTAssertEqual(2*i, CPointer[i], @"Subtraction occured incorrectly");

    }
}

- (void)testSubtractNumbers_Instance{
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(5, 2) withPrimitiveSize:sizeof(RawType)];
    BPMatrix* B = [BPMatrix matrixWithDimensions:CGSizeMake(5, 2) withPrimitiveSize:sizeof(RawType)];
    
    RawType* APointer = [A getMutableData];
    RawType* BPointer = [B getMutableData];
    
    for (int i = 0; i < 10; ++i) {
        APointer[i] = i;
    }
    
    for (int i = 0; i < 10; ++i) {
        BPointer[i] = 3*i;
    }
    
    [B subtractedBy:A];
    RawType* CPointer = (RawType*)[B getData];
    for (int i = 0; i < 10; ++i) {
        XCTAssertEqual(2*i, CPointer[i], @"Subtraction occured incorrectly");

    }
}

- (void)testAdditionNumbers_Class {
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(5, 2) withPrimitiveSize:sizeof(RawType)];
    BPMatrix* B = [BPMatrix matrixWithDimensions:CGSizeMake(5, 2) withPrimitiveSize:sizeof(RawType)];
    
    RawType* APointer = [A getMutableData];
    RawType* BPointer = [B getMutableData];
    
    for (int i = 0; i < 10; ++i) {
        APointer[i] = i;
    }
    
    for (int i = 0; i < 10; ++i) {
        BPointer[i] = 3*i;
    }
    
    BPMatrix* C = [BPMatrix matrixWithAdditionOfMatrixOne:A WithMatrixTwo:B];
    RawType* CPointer = (RawType*)[C getData];
    for (int i = 0; i < 10; ++i) {
        XCTAssertEqual(4*i, CPointer[i], @"Addition occured incorrectly");
    }
}

- (void)testDuplicate {
    BPMatrix *A = [BPMatrix matrixWithDimensions:CGSizeMake(5, 2) withPrimitiveSize:sizeof(RawType)];
    
    RawType* APointer = [A getMutableData];
    for (int i = 0; i < 10; ++i) {
        APointer[i] = 3*i;
    }
    BPMatrix *B = [A duplicate];
    RawType *BPointer = (RawType*)[B getData];
    for (int i = 0; i < 10; ++i) {
        XCTAssertEqual(3*i, BPointer[i], @"Duplicate occured incorrectly");
    }
    
}

- (void)testAdditionNumbers_Instance{
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(5, 2) withPrimitiveSize:sizeof(RawType)];
    BPMatrix* B = [BPMatrix matrixWithDimensions:CGSizeMake(5, 2) withPrimitiveSize:sizeof(RawType)];
    
    RawType* APointer = [A getMutableData];
    RawType* BPointer = [B getMutableData];
    
    for (int i = 0; i < 10; ++i) {
        APointer[i] = i;
    }
    
    for (int i = 0; i < 10; ++i) {
        BPointer[i] = 4*i;
    }
    
    [A addBy:B];
    RawType* CPointer = (RawType*)[A getData];
    for (int i = 0; i < 10; ++i) {
        XCTAssertEqual(5*i, CPointer[i], @"Addition occured incorrectly");
    }
}

- (void)testTranspose {
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(5, 2) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    for (int i = 0; i < 10; ++i) {
        APointer[i] = i;
    }

    [A transpose];
    APointer = (RawType*)[A getData];
    XCTAssertEqual(2, [A width], @"Width didn't update");
    XCTAssertEqual(5, [A height], @"Height didn't update");
    XCTAssertEqual(0, APointer[0], @"Transpose occured incorrectly");
    XCTAssertEqual(5, APointer[1], @"Transpose occured incorrectly");
    XCTAssertEqual(1, APointer[2], @"Transpose occured incorrectly");
    XCTAssertEqual(6, APointer[3], @"Transpose occured incorrectly");
    XCTAssertEqual(2, APointer[4], @"Transpose occured incorrectly");
    XCTAssertEqual(7, APointer[5], @"Transpose occured incorrectly");
    XCTAssertEqual(3, APointer[6], @"Transpose occured incorrectly");
    XCTAssertEqual(8, APointer[7], @"Transpose occured incorrectly");
    XCTAssertEqual(4, APointer[8], @"Transpose occured incorrectly");
    XCTAssertEqual(9, APointer[9], @"Transpose occured incorrectly");
    
    for(int i = 0; i < 10; ++i) {
        NSLog(@"%f",APointer[i]);
    }
    
//    for (int i = 0; i < 10; ++i) {
//        if(i % 2 == 0)
//            XCTAssertEqual(i/2, APointer[i], @"Transpose occured incorrectly");
//        else
//            XCTAssertEqual(i/2 + 5, APointer[i], @"Transpose occured incorrectly");
//    }
    
    A = [BPMatrix matrixWithDimensions:CGSizeMake(2, 2) withPrimitiveSize:sizeof(RawType)];
    APointer = [A getMutableData];
    for (int i = 0; i < 4; ++i) {
        APointer[i] = i;
    }
    [A transpose];
    APointer = [A getMutableData];
    XCTAssertEqual(0, APointer[0], @"Transpose occured incorrectly");
    XCTAssertEqual(2, APointer[1], @"Transpose occured incorrectly");
    XCTAssertEqual(1, APointer[2], @"Transpose occured incorrectly");
    XCTAssertEqual(3, APointer[3], @"Transpose occured incorrectly");

    
}

- (void)testZeroOutData {
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(5, 2) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    for (int i = 0; i < 10; ++i) {
        APointer[i] = i;
    }
    [A zeroOutData];
    
    for(int i = 0; i < 10; ++i) {
        XCTAssertEqual(0, APointer[i], @"Zeroed occured incorrectly");
    }
}

- (void)testInvertMatrix {
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(2, 2) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    for (int i = 0; i < 4; ++i) {
        APointer[i] = i;
    }
    [A invertMatrix];    APointer = [A getMutableData];
    XCTAssertEqual(-1.5, APointer[0], @"Inversion occured incorrectly");
    XCTAssertEqual(.5, APointer[1], @"Inversion occured incorrectly");
    XCTAssertEqual(1, APointer[2], @"Inversion occured incorrectly");
    XCTAssertEqual(0, APointer[3], @"Inversion occured incorrectly");


}

- (void)testInvertMatrix2 {
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(3, 3) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    //Inverse[{{1, 3, 2}, {5, 1, 9}, {8, 8, 3}}]
    APointer[0] = 1.f;
    APointer[1] = 3.f;
    APointer[2] = 2.f;
    APointer[3] = 5.f;
    APointer[4] = 1.f;
    APointer[5] = 9.f;
    APointer[6] = 8.f;
    APointer[7] = 8.f;
    APointer[8] = 3.f;
    [A invertMatrix]; APointer = [A getMutableData];
    //{{-69/166, 7/166, 25/166}, {57/166, -13/166, 1/166}, {16/83, 8/83, -7/83}}
    XCTAssertEqualWithAccuracy(-69.f/166, APointer[0], .01, @"Inversion occured incorrectly");
    XCTAssertEqualWithAccuracy(7.f/166, APointer[1], .01, @"Inversion occured incorrectly");
    XCTAssertEqualWithAccuracy(25.f/166, APointer[2], .01, @"Inversion occured incorrectly");
    
    XCTAssertEqualWithAccuracy(57.f/166, APointer[3], .01, @"Inversion occured incorrectly");
    XCTAssertEqualWithAccuracy(-13.f/166, APointer[4], .01, @"Inversion occured incorrectly");
    XCTAssertEqualWithAccuracy(1.f/166, APointer[5], .01, @"Inversion occured incorrectly");
    
    XCTAssertEqualWithAccuracy(16.f/83, APointer[6], .01, @"Inversion occured incorrectly");
    XCTAssertEqualWithAccuracy(8.f/83, APointer[7], .01, @"Inversion occured incorrectly");
    XCTAssertEqualWithAccuracy(-7.f/83, APointer[8], .01, @"Inversion occured incorrectly");

}

- (void)testEigendecomposeSymmetric {
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(3, 3) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    APointer[0] = APointer[2] = APointer[6] = APointer[8] = 1;
    APointer[1] = APointer[3] = APointer[5] = APointer[7] = 2;
    APointer[4] = 3;
    [A eigendecomposeIsSymmetric:YES withNumberOfValues:3 withNumberOfVectors:9];
    BPMatrix* eigenvalues = [A eigenvalues];
    //BPMatrix* eigenvectors = [A eigenvectors];
    RawType* eigenvaluesPointer = (void*)[eigenvalues getData];
    //RawType* eigenvectorsPointer = (void*)[eigenvectors getData];
    
    XCTAssertEqualWithAccuracy(5.37228, eigenvaluesPointer[2], 0.01, @"Eigendecompose occured incorrectly");
    XCTAssertEqualWithAccuracy(0, eigenvaluesPointer[1], 0.01, @"Eigendecompose occured incorrectly");
    XCTAssertEqualWithAccuracy(-0.372281, eigenvaluesPointer[0], 0.01, @"Eigendecompose occured incorrectly");
    
    // we are going to assume vectors are correct, but if shit breaks, we gotta write a test for it #TODO
}

- (void)testEigendecomposeNonsymmetric {
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(3, 3) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    //Inverse[{{1, 3, 2}, {5, 1, 9}, {8, 8, 3}}]
    APointer[0] = 1.f;
    APointer[1] = 3.f;
    APointer[2] = 2.f;
    APointer[3] = 5.f;
    APointer[4] = 1.f;
    APointer[5] = 9.f;
    APointer[6] = 8.f;
    APointer[7] = 8.f;
    APointer[8] = 3.f;
    [A eigendecomposeIsSymmetric:NO withNumberOfValues:3 withNumberOfVectors:9];
    
    BPMatrix *eigenvalues = [A eigenvalues];
    RawType* eigenvaluesPointer = (void*)[eigenvalues getData];
    //BPMatrix* eigenvectors = [A eigenvectors];
    //RawType* eigenvectorsPointer = (void*)[eigenvectors getData];

    XCTAssertEqualWithAccuracy(13.215, eigenvaluesPointer[0], 0.01, @"Eigendecompose occured incorrectly");
    XCTAssertEqualWithAccuracy(-2.03142, eigenvaluesPointer[1], 0.01, @"Eigendecompose occured incorrectly");
    XCTAssertEqualWithAccuracy(-6.18359, eigenvaluesPointer[2], 0.01, @"Eigendecompose occured incorrectly");
    
    // we are going to assume vectors are correct, but if shit breaks, we gotta write a test for it #TODO
    
}

- (void)testEigendecomposeGeneralizedMatrices {
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(5, 5) withPrimitiveSize:sizeof(RawType)];
    A[0] = @(2.f), A[1] = @(3.f),A[2] = @(4.f), A[3] = @(5.f), A[4] = @(6.f), A[5] = @(4.f), A[6] = @(4.f), A[7] = @(5.f),A[8] = @(6.f),A[9] = @(7.f),A[10] = @(0.f), A[11] = @(3.f), A[12] = @(6.f),A[13] = @(7.f),A[14] = @(8.f),A[15] = @(0.f), A[16] = @(0.f), A[17] = @(2.f),A[18] = @(8.f),A[19] = @(9.f),A[20] = @(0.f), A[21] = @(0.f), A[22] = @(0.f),A[23] = @(1.f),A[24] = @(10.f);
    
    BPMatrix* B = [BPMatrix matrixWithDimensions:CGSizeMake(5, 5) withPrimitiveSize:sizeof(RawType)];
    B[0] = @(1.f), B[1] = @(-1.f),B[2] = @(-1.f), B[3] = @(-1.f), B[4] = @(-1.f), B[5] = @(0.f), B[6] = @(1.f), B[7] = @(-1.f),B[8] = @(-1.f),B[9] = @(-1.f),B[10] = @(0.f), B[11] = @(0.f), B[12] = @(1.f),B[13] = @(-1.f),B[14] = @(-1.f),B[15] = @(0.f), B[16] = @(0.f), B[17] = @(0.f),B[18] = @(1.f),B[19] = @(-1.f),B[20] = @(0.f), B[21] = @(0.f), B[22] = @(0.f),B[23] = @(0.f),B[24] = @(1.f);
//
//    BPMatrix*A = [BPMatrix matrixWithDimensions:CGSizeMake(3, 3) withPrimitiveSize:sizeof(RawType)];
//    A[0] = @(10.f), A[1] = @(1.f), A[2] = @(2.f), A[3] = @(1.f), A[4] = @(2.f), A[5] = @(-1.f), A[6] = @(1.f), A[7] = @(1.f), A[8] = @(2.f);
//    
//    BPMatrix*B = [BPMatrix matrixWithDimensions:CGSizeMake(3, 3) withPrimitiveSize:sizeof(RawType)];
//    B[0] = @(1.f), B[1] = @(2.f), B[2] = @(3.f), B[3] = @(4.f), B[4] = @(5.f), B[5] = @(6.f), B[6] = @(7.f), B[7] = @(8.f), B[8] = @(9.f);
    
//    BPMatrix *B = [BPMatrix matrixWithDimensions:CGSizeMake(3, 3) withPrimitiveSize:sizeof(RawType)];
//    B[0] = @(1.f), B[1] = @(2.f), B[2] = @(3.f), B[3] = @(4.f), B[4] = @(5.f), B[5] = @(6.f), B[6] = @(7.f), B[7] = @(8.f), B[8] = @(9.f);
//    BPMatrix *A = [B duplicate];
    
    
    BPMatrix* empty = [BPMatrix eigendecomposeGeneralizedMatrixA:A andB:B WithNumberOfValues:A.width numberOfVector:A.width*A.height];
    
    BPMatrix* eigenvalues = [empty eigenvalues];
    RawType* eigenvaluesPointer = (void*)[eigenvalues getData];
    NSLog(@"");
//    XCTAssertEqualWithAccuracy(<#a1#>, <#a2#>, <#accuracy#>, <#format...#>)
}

- (void)testAlternativeToEigendecomposingGeneralizedMatrices {
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(3, 3) withPrimitiveSize:sizeof(RawType)];
    A[0] = @(1.f), A[1] = @(2.f),A[2] = @(3.f), A[3] = @(4.f), A[4] = @(5.f), A[5] = @(6.f), A[6] = @(7.f), A[7] = @(8.f),A[8] = @(9.f);
    
    BPMatrix* B = [BPMatrix matrixWithDimensions:CGSizeMake(3, 3) withPrimitiveSize:sizeof(RawType)];
    B[0] = @(5.f), B[1] = @(20.f),B[2] = @(35.f), B[3] = @(10.f), B[4] = @(25.f), B[5] = @(40.f), B[6] = @(15.f), B[7] = @(30.f),B[8] = @(45.f);
    
    BPMatrix* Binverted = [[B duplicate] invertMatrix];
    [Binverted multiplyBy:A];
    [Binverted eigendecomposeIsSymmetric:NO withNumberOfValues:3 withNumberOfVectors:9];
    
    
    
    NSLog(@"");
}

- (void)testMeanOfRows {
    BPMatrix* A = [BPMatrix matrixWithDimensions:CGSizeMake(3, 3) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    //Inverse[{{1, 3, 2}, {5, 1, 9}, {8, 8, 3}}]
    APointer[0] = 1.f;
    APointer[1] = 3.f;
    APointer[2] = 2.f;
    APointer[3] = 5.f;
    APointer[4] = 1.f;
    APointer[5] = 9.f;
    APointer[6] = 8.f;
    APointer[7] = 8.f;
    APointer[8] = 3.f;
    BPMatrix* meanOfRows = [A meanOfRows];
    RawType* MeanPointer = (void*)[meanOfRows getData];
    XCTAssertEqual(6.f/3, MeanPointer[0], @"Mean of rows was incorrect");
    XCTAssertEqual(15.f/3, MeanPointer[1], @"Mean of rows was incorrect");
    XCTAssertEqual(19.f/3, MeanPointer[2], @"Mean of rows was incorrect");
}

- (void)testGetColumn {
    BPMatrix *A = [BPMatrix matrixWithDimensions:CGSizeMake(7, 3) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    for (int i = 0; i < A.width*A.height; ++i) {
        APointer[i] = (RawType)i;
    }
    BPMatrix *columnVec = [A getColumnAtIndex:2];
    RawType* ColumnPointer = (void*)[columnVec getData];
    
    XCTAssertEqual(1, columnVec.width, @"getColumn was incorrect");
    XCTAssertEqual(3, columnVec.height, @"getColumn was incorrect");
    
    XCTAssertEqual(2.f, ColumnPointer[0], @"getColumn was incorrect");
    XCTAssertEqual(9.f, ColumnPointer[1], @"getColumn was incorrect");
    XCTAssertEqual(16.f, ColumnPointer[2], @"getColumn was incorrect");
    

}

- (void)testGetColumns {
    BPMatrix *A = [BPMatrix matrixWithDimensions:CGSizeMake(7, 3) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    for (int i = 0; i < A.width*A.height; ++i) {
        APointer[i] = (RawType)i;
    }
    BPMatrix *columnVec = [A getColumnsFromIndex:2 toIndex:4];
    RawType* ColumnPointer = (void*)[columnVec getData];
    
    XCTAssertEqual(3, columnVec.width, @"getColumn was incorrect");
    XCTAssertEqual(3, columnVec.height, @"getColumn was incorrect");
    
    XCTAssertEqual(2.f, ColumnPointer[0], @"getColumn was incorrect");
    XCTAssertEqual(3.f, ColumnPointer[1], @"getColumn was incorrect");
    XCTAssertEqual(4.f, ColumnPointer[2], @"getColumn was incorrect");
    XCTAssertEqual(9.f, ColumnPointer[3], @"getColumn was incorrect");
    XCTAssertEqual(10.f, ColumnPointer[4], @"getColumn was incorrect");
    XCTAssertEqual(11.f, ColumnPointer[5], @"getColumn was incorrect");
    XCTAssertEqual(16.f, ColumnPointer[6], @"getColumn was incorrect");
    XCTAssertEqual(17.f, ColumnPointer[7], @"getColumn was incorrect");
    XCTAssertEqual(18.f, ColumnPointer[8], @"getColumn was incorrect");

}

- (void)testGetRow {
    BPMatrix *A = [BPMatrix matrixWithDimensions:CGSizeMake(7, 3) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    for (int i = 0; i < A.width*A.height; ++i) {
        APointer[i] = (RawType)i;
    }
    BPMatrix *columnVec = [A getRowAtIndex:2];
    RawType* ColumnPointer = (void*)[columnVec getData];
    
    XCTAssertEqual(7, columnVec.width, @"getColumn was incorrect");
    XCTAssertEqual(1, columnVec.height, @"getColumn was incorrect");
    
    XCTAssertEqual(14.f, ColumnPointer[0], @"getColumn was incorrect");
    XCTAssertEqual(15.f, ColumnPointer[1], @"getColumn was incorrect");
    XCTAssertEqual(16.f, ColumnPointer[2], @"getColumn was incorrect");
    XCTAssertEqual(17.f, ColumnPointer[3], @"getColumn was incorrect");
    XCTAssertEqual(18.f, ColumnPointer[4], @"getColumn was incorrect");
    XCTAssertEqual(19.f, ColumnPointer[5], @"getColumn was incorrect");
    XCTAssertEqual(20.f, ColumnPointer[6], @"getColumn was incorrect");
}


- (void)testEuclideanDistanceRowVector {
    BPMatrix *A = [BPMatrix matrixWithDimensions:CGSizeMake(7, 1) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    for (int i = 0; i < A.width*A.height; ++i) {
        APointer[i] = (RawType)i;
    }
    
    BPMatrix *B = [BPMatrix matrixWithDimensions:CGSizeMake(7, 1) withPrimitiveSize:sizeof(RawType)];
    RawType* BPointer = [B getMutableData];
    for (int i = 0; i < B.width*B.height; ++i) {
        BPointer[i] = (RawType)(i+10);
    }

    XCTAssertEqualWithAccuracy(26.4575f, [BPMatrix euclideanDistanceBetweenMatrixOne:A andMatrixTwo:B], .01, @"EuclideanDistance didn't work");
    
}

- (void)testEuclideanDistanceColumnVector {
    BPMatrix *A = [BPMatrix matrixWithDimensions:CGSizeMake(1, 7) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    for (int i = 0; i < A.width*A.height; ++i) {
        APointer[i] = (RawType)i;
    }
    
    BPMatrix *B = [BPMatrix matrixWithDimensions:CGSizeMake(1, 7) withPrimitiveSize:sizeof(RawType)];
    RawType* BPointer = [B getMutableData];
    for (int i = 0; i < B.width*B.height; ++i) {
        BPointer[i] = (RawType)(i+10);
    }
    
    XCTAssertEqualWithAccuracy(26.4575f, [BPMatrix euclideanDistanceBetweenMatrixOne:A andMatrixTwo:B], .01, @"EuclideanDistance didn't work");
    
}

- (void)testStretchColumnVector {
    BPMatrix *A = [BPMatrix matrixWithDimensions:CGSizeMake(1, 4) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    for (int i = 0; i < A.width*A.height; ++i) {
        APointer[i] = (RawType)i;
    }
    BPMatrix* stretchedA = [A stretchByNumberOfRows:3];
    RawType* stetchedP = (void*)[stretchedA getData];
    XCTAssertEqual(0, stetchedP[0], @"Stretched didn't work");
    XCTAssertEqual(0, stetchedP[1], @"Stretched didn't work");
    XCTAssertEqual(0, stetchedP[2], @"Stretched didn't work");
    
    XCTAssertEqual(1, stetchedP[3], @"Stretched didn't work");
    XCTAssertEqual(1, stetchedP[4], @"Stretched didn't work");
    XCTAssertEqual(1, stetchedP[5], @"Stretched didn't work");
    
    XCTAssertEqual(2, stetchedP[6], @"Stretched didn't work");
    XCTAssertEqual(2, stetchedP[7], @"Stretched didn't work");
    XCTAssertEqual(2, stetchedP[8], @"Stretched didn't work");
    
    XCTAssertEqual(3, stetchedP[9], @"Stretched didn't work");
    XCTAssertEqual(3, stetchedP[10], @"Stretched didn't work");
    XCTAssertEqual(3, stetchedP[11], @"Stretched didn't work");
}

- (void)testFlipL2R {
    BPMatrix *A = [BPMatrix matrixWithDimensions:CGSizeMake(3, 4) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    for (int i = 1; i <= A.width*A.height; ++i) {
        APointer[i-1] = (RawType)i;
    }
    BPMatrix *mat =[A flippedL2R];
    RawType*Aflip = (void*)[mat getData];
    
    XCTAssertEqual(3, Aflip[0], @"Flipp no go");
    XCTAssertEqual(2, Aflip[1], @"Flipp no go");
    XCTAssertEqual(1, Aflip[2], @"Flipp no go");
    
    XCTAssertEqual(6, Aflip[3], @"Flipp no go");
    XCTAssertEqual(5, Aflip[4], @"Flipp no go");
    XCTAssertEqual(4, Aflip[5], @"Flipp no go");

    XCTAssertEqual(9, Aflip[6], @"Flipp no go");
    XCTAssertEqual(8, Aflip[7], @"Flipp no go");
    XCTAssertEqual(7, Aflip[8], @"Flipp no go");
    
    XCTAssertEqual(12, Aflip[9], @"Flipp no go");
    XCTAssertEqual(11, Aflip[10], @"Flipp no go");
    XCTAssertEqual(10, Aflip[11], @"Flipp no go");
}

- (void)testConcatTwoMatricesByColumn {
    BPMatrix * A = [BPMatrix matrixWithDimensions:CGSizeMake(2, 4) withPrimitiveSize:sizeof(RawType)];
    RawType* APointer = [A getMutableData];
    for (int i = 0; i < A.width*A.height; ++i) {
        APointer[i] = (RawType)i;
    }
    
    BPMatrix * B = [BPMatrix matrixWithDimensions:CGSizeMake(1, 4) withPrimitiveSize:sizeof(RawType)];
    RawType* BPointer = [B getMutableData];
    for (int i = 0; i < B.width*B.height; ++i) {
        BPointer[i] = (RawType)i*2;
    }
    
    BPMatrix* concat = [BPMatrix concatMatrixOne:A withMatrixTwo:B];
    RawType* concatP = (void*)[concat getData];
    
    XCTAssertEqual(0, concatP[0], @"Concat no work");
    XCTAssertEqual(1, concatP[1], @"Concat no work");
    XCTAssertEqual(0, concatP[2], @"Concat no work");
    
    XCTAssertEqual(2, concatP[3], @"Concat no work");
    XCTAssertEqual(3, concatP[4], @"Concat no work");
    XCTAssertEqual(2, concatP[5], @"Concat no work");
    
    XCTAssertEqual(4, concatP[6], @"Concat no work");
    XCTAssertEqual(5, concatP[7], @"Concat no work");
    XCTAssertEqual(4, concatP[8], @"Concat no work");
    
    XCTAssertEqual(6, concatP[9], @"Concat no work");
    XCTAssertEqual(7, concatP[10], @"Concat no work");
    XCTAssertEqual(6, concatP[11], @"Concat no work");
    
}

-(void)testEigen {
    [BPEigen test];
}

@end
