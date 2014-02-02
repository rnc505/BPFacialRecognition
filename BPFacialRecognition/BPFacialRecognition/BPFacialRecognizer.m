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

-(Byte*)createVectorFromImageSet:(NSUInteger)numberOfImages;
-(void)createMeanImageFromVector:(Byte*)vector fromNumberOfImages:(NSUInteger)numberOfImages;
-(Byte*)createSurrogateCovarianceFromVector:(Byte*)vector fromNumberOfImages:(NSUInteger)numberOfImages;
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
    Byte* oneDVector = [self createVectorFromImageSet:[numberOfImages unsignedIntegerValue]]; // sizeDimension*sizeDimension x numberOfImages matrix
    [self createMeanImageFromVector:oneDVector fromNumberOfImages:[numberOfImages unsignedIntegerValue]]; // sizeDimension*sizeDimension x numberOfImages matrix
    Byte* surrogateCovariance = [self createSurrogateCovarianceFromVector:oneDVector fromNumberOfImages:numberOfImages];
    
    
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

-(Byte *)createVectorFromImageSet:(NSUInteger)numberOfImages {
    Byte* retVal = (Byte*) calloc(sizeDimension * sizeDimension * numberOfImages, sizeof(Byte));
    int currentPosition = 0;
    for (BPPerson *person in _people) {
        NSSet* images = [person getPersonsImages];
        for (UIImage* img in images) {
            vImage_Buffer vImg = [BPUtil vImageFromUIImage:img];
            [BPUtil copyVectorFrom:vImg.data toVector:retVal offset:currentPosition];
            ++currentPosition;
            [BPUtil cleanupvImage:vImg];
        }
    }
    return retVal;
}

-(void)createMeanImageFromVector:(Byte *)vector fromNumberOfImages:(NSUInteger)numberOfImages {
    Byte* mean = (Byte*) calloc(sizeDimension*sizeDimension, sizeof(Byte));
    [BPUtil calculateMeanOfVectorFrom:vector toVector:mean ofHeight:sizeDimension*sizeDimension ofWidth:numberOfImages];
    [BPUtil subtractMean:mean fromVector:vector withNumberOfImages:numberOfImages];
}

-(Byte *)createSurrogateCovarianceFromVector:(Byte *)vector fromNumberOfImages:(NSUInteger)numberOfImages{
    Byte* surrogate = (Byte*) calloc(numberOfImages*numberOfImages, sizeof(Byte));
    [BPUtil calculateAtransposeTimesAFromVector:vector toOutputVector:surrogate withNumberOfImages:<#(NSUInteger)#>]
    return surrogate;
}

@end
