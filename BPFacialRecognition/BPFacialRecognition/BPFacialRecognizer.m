//
//  BPFacialRecognition.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/22/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import "BPFacialRecognizer.h"
#import "BPRecognitionResult.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Utils.h"
#import "BPRecognizerCPUOperator.h"
@interface BPFacialRecognizer ()
@property (nonatomic, retain) NSMutableSet *people;
@property (nonatomic, assign) BOOL needsToBeTrained;
@property (nonatomic, retain) EAGLContext* context;
@property (nonatomic, retain) BPRecognizerCPUOperator* operator;
-(RawType*)createVectorFromImageSet:(NSUInteger)numberOfImages;
-(void)createMeanImageFromVector:(RawType*)vector fromNumberOfImages:(NSUInteger)numberOfImages;
-(RawType*)createSurrogateCovarianceFromVector:(RawType*)vector fromNumberOfImages:(NSUInteger)numberOfImages;
@end

@implementation BPFacialRecognizer
+(BPFacialRecognizer *)newRecognizer {
    BPFacialRecognizer *recognizer = [BPFacialRecognizer new];
    [recognizer setPeople:[NSMutableSet new]];
    [recognizer setNeedsToBeTrained:YES];
    [recognizer setOperator:[BPRecognizerCPUOperator new]];
    return recognizer;
}



-(void)addNewPerson:(BPPerson*)person {
    [person setDelegate:self];
    [_people addObject:person];
    _needsToBeTrained = YES;
}

-(void)train {
    NSNumber *numberOfImages = [_people valueForKeyPath:@"@sum.count"];
    RawType* oneDVector = [self createVectorFromImageSet:[numberOfImages unsignedIntegerValue]]; // sizeDimension*sizeDimension x numberOfImages matrix
    [self createMeanImageFromVector:oneDVector fromNumberOfImages:[numberOfImages unsignedIntegerValue]]; // sizeDimension*sizeDimension x numberOfImages matrix
    RawType* surrogateCovariance = [self createSurrogateCovarianceFromVector:oneDVector fromNumberOfImages:[numberOfImages unsignedIntegerValue]];
    
    
    free(surrogateCovariance);
    free(oneDVector);
    _needsToBeTrained = NO;
}

-(BPRecognitionResult*)recognizeUnknownPerson:(UIImage*)image {
    if (_needsToBeTrained) {
        NSLog(@"Recognizer needs to be trained before recongizing. Please call -train on on Recognizer. Returning nil.");
        return nil;
    }
    
    /*
        Run the person recognizer here
     */
    
    BPPerson* recognizedPerson = [BPPerson personWithName:@"New Person"];
    double confidence = 0;
    
    return [BPRecognitionResult resultWithPerson:recognizedPerson withConfidence:confidence];
}

-(BOOL)doesUnknownImage:(UIImage*)image matchPerson:(BPPerson*)person {
    return YES;
    BPRecognitionResult *matched = [self recognizeUnknownPerson:image];
    if(!matched) {
        return NO;
    }
    return [person isEqual:[matched person]];
}
-(NSSet *)peopleInRecognizer {
    return [_people copy];
}

#pragma BPPersonDelegate Methods
-(void)addedNewImage {
    _needsToBeTrained = YES;
}

-(RawType *)createVectorFromImageSet:(NSUInteger)numberOfImages {
    RawType* retVal = (RawType*) calloc(sizeDimension * sizeDimension * numberOfImages, sizeof(float));
    int currentPosition = 0;
    for (BPPerson *person in _people) {
        NSSet* images = [person getPersonsImages];
        for (UIImage* img in images) {
            double* vImg = [img vImageDataWithDoubles];
            [_operator copyVector:vImg toVector:retVal numberOfElements:sizeDimension*sizeDimension offset:currentPosition sizeOfType:sizeof(RawType)];
            ++currentPosition;
            free(vImg);
        }
    }
    return retVal;
}

-(void)createMeanImageFromVector:(RawType *)vector fromNumberOfImages:(NSUInteger)numberOfImages {
    RawType* mean = (RawType*) calloc(sizeDimension*sizeDimension, sizeof(float));
//    [BPUtil calculateMeanOfVectorFrom:vector toVector:mean ofHeight:sizeDimension*sizeDimension ofWidth:numberOfImages];
//    [BPUtil subtractMean:mean fromVector:vector withNumberOfImages:numberOfImages];
    [_operator columnWiseMeanOfDoubleMatrix:vector toDoubleVector:mean columnHeight:sizeDimension*sizeDimension rowWidth:numberOfImages freeInput:NO];
    for (int i = 0; i < numberOfImages; ++i) {
        [_operator subtractDoubleVector:mean fromDoubleVector:(vector+i*sizeDimension*sizeDimension) numberOfElements:sizeDimension*sizeDimension freeInput:NO];
    }
}

-(RawType *)createSurrogateCovarianceFromVector:(RawType *)vector fromNumberOfImages:(NSUInteger)numberOfImages{
    RawType* surrogate = (RawType*) calloc(numberOfImages*numberOfImages, sizeof(float));
    
    // TODO: fix method declaration to include vector size info
//    [BPUtil calculateAtransposeTimesAFromVector:vector toOutputVector:surrogate withNumberOfImages:numberOfImages];
//    [_operator transposeMatrix:vector transposed:<#(void *)#> columnHeight:<#(NSUInteger)#> rowWidth:<#(NSUInteger)#> freeInput:<#(BOOL)#>]
    return surrogate;
}

@end
