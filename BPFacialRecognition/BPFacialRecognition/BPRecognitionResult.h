//
//  BPRecognitionResult.h
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/22/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BPPerson;
@interface BPRecognitionResult : NSObject

+(BPRecognitionResult*)resultWithPerson:(BPPerson*)person withConfidence:(double)confidence;

-(BPPerson*)person;
-(double)confidence;

@end
