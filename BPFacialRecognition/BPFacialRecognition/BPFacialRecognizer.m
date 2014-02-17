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
#import "BPFisherFaces.h"
@interface BPFacialRecognizer ()
@property (nonatomic, retain) NSMutableArray *people;
@property (nonatomic, assign) BOOL needsToBeTrained;
@property (nonatomic, retain) BPFisherFaces* operator;
@end

@implementation BPFacialRecognizer
+(BPFacialRecognizer *)newRecognizer {
    BPFacialRecognizer *recognizer = [BPFacialRecognizer new];
    [recognizer setPeople:[NSMutableArray new]];
    [recognizer setNeedsToBeTrained:YES];
    [recognizer setOperator:[BPFisherFaces createFisherFaceAlgorithmWithDataSource:recognizer]];
    return recognizer;
}



-(void)addNewPerson:(BPPerson*)person {
    [person setDelegate:self];
    [_people addObject:person];
    _needsToBeTrained = YES;
}

-(void)train {
    [_operator train];
    _needsToBeTrained = NO;
}

-(BPRecognitionResult*)recognizeUnknownPerson:(UIImage*)image {
    if (_needsToBeTrained) {
        NSLog(@"Recognizer needs to be trained before recongizing. Please call -train on on Recognizer. Returning nil.");
        return nil;
    }
    
    return [_operator recognizeImage:image];
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

-(NSUInteger)totalNumberOfImages {
    return [[_people valueForKeyPath:@"@sum.count"] unsignedIntegerValue];
}

-(NSArray *)totalImageSet {
    NSMutableArray *retVal = [NSMutableArray new];
    for(BPPerson *person in _people) {
        NSSet* images = [person getPersonsImages];
        [retVal addObjectsFromArray:[images allObjects]];
    }
    return [retVal copy];
}

-(NSUInteger)totalNumberOfPeople {
    return [_people count];
}

-(NSArray*)personImageIndexes {
    NSMutableArray *retVal = [NSMutableArray new];
    NSUInteger index = 0;
    for (BPPerson *person in _people) {
        [retVal addObject:[NSNumber numberWithUnsignedInt:index]];
        index += [[person getPersonsImages] count];
    }
    // endpost
    [retVal addObject:[NSNumber numberWithUnsignedInt:index]];
    return retVal;
}

@end
