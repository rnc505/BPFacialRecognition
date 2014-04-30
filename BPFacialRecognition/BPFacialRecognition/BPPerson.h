//
//  BPPerson.h
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/22/14.
//  Copyright (c) 2014 BP. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol BPPersonDelegate <NSObject>
-(void)addedNewImage;
@end

@class UIImage;
@interface BPPerson : NSObject
@property (nonatomic, weak) id<BPPersonDelegate> delegate;
@property (nonatomic, retain) NSNumber* count;
+(BPPerson*)personWithName:(NSString*)name;
-(BOOL)detectFaceAndAddImage:(UIImage*)newImage;
-(NSArray*)getPersonsImages;

@end
