//
//  BPMatrixTests.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 3/30/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BPMatrix.h"
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
    for (int i = 0; i < 10; ++i) {
        if(i % 2 == 0)
            XCTAssertEqual(i/2, APointer[i], @"Transpose occured incorrectly");
        else
            XCTAssertEqual(i/2 + 5, APointer[i], @"Transpose occured incorrectly");
    }
    
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
    XCTAssertEqual(14.f/3, MeanPointer[0], @"Mean of rows was incorrect");
    XCTAssertEqual(12.f/3, MeanPointer[1], @"Mean of rows was incorrect");
    XCTAssertEqual(14.f/3, MeanPointer[2], @"Mean of rows was incorrect");
}



@end
