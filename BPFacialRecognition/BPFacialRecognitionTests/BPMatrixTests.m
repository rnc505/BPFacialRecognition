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

@end
