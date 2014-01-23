//
//  BPRecognitionResult.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/22/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import "BPRecognitionResult.h"

@interface BPRecognitionResult ()
@property (nonatomic, retain) BPPerson* person;
@property (nonatomic, assign) double confidence;
@end

@implementation BPRecognitionResult
@synthesize person = _person, confidence = _confidence;
+(BPRecognitionResult *)resultWithPerson:(BPPerson*)person withConfidence:(double)confidence {
    BPRecognitionResult *result = [BPRecognitionResult new];
    [result setPerson:person];
    [result setConfidence:confidence];
    return result;
}

-(BPPerson *)person {
    return _person;
}

-(double)confidence {
    return _confidence;
}

@end
