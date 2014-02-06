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

@interface BPFacialRecognizer ()
@property (nonatomic, retain) NSMutableSet *people;
@property (nonatomic, assign) BOOL needsToBeTrained;
@property (nonatomic, retain) EAGLContext* context;

-(RawType*)createVectorFromImageSet:(NSUInteger)numberOfImages;
-(void)createMeanImageFromVector:(RawType*)vector fromNumberOfImages:(NSUInteger)numberOfImages;
-(RawType*)createSurrogateCovarianceFromVector:(RawType*)vector fromNumberOfImages:(NSUInteger)numberOfImages;
@end

@implementation BPFacialRecognizer
+(BPFacialRecognizer *)newRecognizer {
    BPFacialRecognizer *recognizer = [BPFacialRecognizer new];
    [recognizer setPeople:[NSMutableSet new]];
    [recognizer setNeedsToBeTrained:YES];
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
            vImage_Buffer vImg = [BPUtil vImageFromUIImage:img];
            [BPUtil copyVectorFrom:vImg.data toVector:retVal offset:currentPosition sizeOfType:sizeof(float)];
            ++currentPosition;
            [BPUtil cleanupvImage:vImg];
        }
    }
    return retVal;
}

-(void)createMeanImageFromVector:(RawType *)vector fromNumberOfImages:(NSUInteger)numberOfImages {
    RawType* mean = (RawType*) calloc(sizeDimension*sizeDimension, sizeof(float));
    [BPUtil calculateMeanOfVectorFrom:vector toVector:mean ofHeight:sizeDimension*sizeDimension ofWidth:numberOfImages];
    [BPUtil subtractMean:mean fromVector:vector withNumberOfImages:numberOfImages];
}

-(RawType *)createSurrogateCovarianceFromVector:(RawType *)vector fromNumberOfImages:(NSUInteger)numberOfImages{
    RawType* surrogate = (RawType*) calloc(numberOfImages*numberOfImages, sizeof(float));
    [BPUtil calculateAtransposeTimesAFromVector:vector toOutputVector:surrogate withNumberOfImages:numberOfImages];
    return surrogate;
}

@end
