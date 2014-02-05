//
//  BPFacialRecognition.h
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/22/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPPerson.h"
@class  BPRecognitionResult, UIImage;
@interface BPFacialRecognizer : NSObject <BPPersonDelegate>

+(BPFacialRecognizer*)newRecognizer;
-(void)addNewPerson:(BPPerson*)person;
-(void)train;
-(BPRecognitionResult*)recognizeUnknownPerson:(UIImage*)image;
-(BOOL)doesUnknownImage:(UIImage*)image matchPerson:(BPPerson*)person;
-(NSSet*)peopleInRecognizer;

@end