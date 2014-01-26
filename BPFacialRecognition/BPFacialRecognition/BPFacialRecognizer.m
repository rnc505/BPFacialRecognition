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
}

-(void)train {
    // DO TRAINING MUMBOJUMBO
}

-(BPRecognitionResult*)recognizeUnknownPerson:(UIImage*)image {
    if (_needsToBeTrained) {
        NSLog(@"Recognizer needs to be trained before recongizing. Please call -train on on Recognizer. Returning nil.");
        return nil;
    }
    // RECOGNIZE UNKNOWN PERSON
    
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
