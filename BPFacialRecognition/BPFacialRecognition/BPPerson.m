//
//  BPPerson.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/22/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import "BPPerson.h"
@interface BPPerson ()
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* uuid;
@property (nonatomic, retain) NSMutableSet* images;
@end

@implementation BPPerson

+(BPPerson *)personWithName:(NSString *)name {
    BPPerson* person = [BPPerson new];
    [person setName:name];
    [person setUuid:[[NSUUID UUID] UUIDString]];
    [person setImages:[NSMutableSet new]];
    return person;
}
-(void)addImage:(UIImage *)newImage {
    [_images addObject:newImage];
}
-(BOOL)isEqualToPerson:(BPPerson *)person {
    return [_uuid isEqualToString:[person uuid]];
}

@end
