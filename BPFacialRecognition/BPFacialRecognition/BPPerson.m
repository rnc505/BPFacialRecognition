//
//  BPPerson.m
//  BPFacialRecognition
//
//  Created by Robby Cohen on 1/22/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import "BPPerson.h"
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "BPFacialRecognizer.h"
#import "UIImage+Utils.h"
@interface BPPerson ()
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* uuid;
@property (nonatomic, retain) NSMutableSet* images;
@property (nonatomic, retain) NSMutableSet* grayscaledImages;
-(BOOL)imageContainsFace:(UIImage*)image;
@end

@implementation BPPerson

+(BPPerson *)personWithName:(NSString *)name {
    BPPerson* person = [BPPerson new];
    [person setName:name];
    [person setUuid:[[NSUUID UUID] UUIDString]];
    [person setImages:[NSMutableSet new]];
    [person setGrayscaledImages:[NSMutableSet new]];
    return person;
}
-(BOOL)detectFaceAndAddImage:(UIImage *)newImage {
//    if([self imageContainsFace:newImage]) {
        UIImage *resized = [newImage resizedSquareImageOfDimension:kSizeDimension];;
        [_images addObject:resized];
        [_grayscaledImages addObject:[resized grayscaledImage]];
        if(_delegate) {
            [_delegate addedNewImage];
        }
        return YES;
//    }
//    return NO;
}
-(BOOL)isEqual:(id)other {
    if (other == self) { // self equality, compare address pointers
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        // test not nil and is same type of class
        return NO;
    }
    return [self isEqualToPerson:other];
}

-(BOOL)isEqualToPerson:(BPPerson *)person {
    return [_uuid isEqualToString:[person uuid]];
}

-(BOOL)imageContainsFace:(UIImage *)image {
    CIImage* image1 = [CIImage imageWithCGImage:[image CGImage]];
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    NSArray* features = [faceDetector featuresInImage:image1];
    for(int i = 0; i < features.count; ++i){
        if ([features[i] isKindOfClass:[CIFaceFeature class]]) {
            return YES;
        }
    }
    return NO;
}

-(NSSet *)getPersonsImages {
    return _grayscaledImages;
}

-(NSNumber*)count {
    return [NSNumber numberWithUnsignedLong:[_grayscaledImages count]];
}

-(NSString *)description {
    return  [NSString stringWithFormat:@"Person: %@",_name];
}

@end
