//
//  BPFacialRecognition.h
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/22/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPPerson.h"
#import "BPFisherFaces.h"

@class  BPRecognitionResult, UIImage, BPPerson;
@interface BPFacialRecognizer : NSObject <BPPersonDelegate,BPFisherFacesDataSource>

+(BPFacialRecognizer*)newRecognizer;
-(void)addNewPerson:(BPPerson*)person;
-(void)train;
-(BPRecognitionResult*)recognizeUnknownPerson:(UIImage*)image;
-(BOOL)doesUnknownImage:(UIImage*)image matchPerson:(BPPerson*)person;
-(NSArray*)peopleInRecognizer;
-(BPMatrix*)getMeanImage;
@end

