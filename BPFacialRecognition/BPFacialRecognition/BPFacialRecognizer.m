//
//  BPFacialRecognition.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/22/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import "BPFacialRecognizer.h"
#import "BPRecognitionResult.h"
#import "BPPerson.h"
@interface BPFacialRecognizer ()
@property (nonatomic, retain) NSMutableSet *people;
@end

@implementation BPFacialRecognizer
+(BPFacialRecognizer *)newRecognizer {
    BPFacialRecognizer *recognizer = [BPFacialRecognizer new];
    [recognizer setPeople:[NSMutableSet new]];
    return recognizer;
}

-(void)addNewPerson:(BPPerson*)person {
    [_people addObject:person];
}

-(void)train {
    // DO TRAINING MUMBOJUMBO
}

-(BPRecognitionResult*)recognizeUnknownPerson:(UIImage*)image {
    // RECOGNIZE UNKOWN PERSON
    
    BPPerson* recognizedPerson = [BPPerson personWithName:@"New Person"];
    double confidence = 0;
    
    return [BPRecognitionResult resultWithPerson:recognizedPerson withConfidence:confidence];
}

-(BOOL)doesUnknownImage:(UIImage*)image matchPerson:(BPPerson*)person {
    BPRecognitionResult *matched = [self recognizeUnknownPerson:image];
    return [person isEqualToPerson:[matched person]];
}

@end
