//
//  BPFacialRecognition.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/22/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import "BPFacialRecognizer.h"
#import "BPRecognitionResult.h"
@interface BPFacialRecognizer ()
@property (nonatomic, retain) NSMutableSet *people;
@property (nonatomic, assign) BOOL needsToBeTrained;
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
    /*
        Run the trainer
     */
    
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

@end
