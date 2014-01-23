//
//  BPPerson.h
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/22/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;
@interface BPPerson : NSObject

+(BPPerson*)personWithName:(NSString*)name;
-(void)addImage:(UIImage*)newImage;
-(BOOL)isEqualToPerson:(BPPerson*)person;

@end
