//
//  BPFisherFaces.h
//  BPFacialRecognition
//
//  Created by Robby Cohen on 2/9/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPRecognitionResult.h"
#import "BPPreRecognitionResult.h"
#import "BPMatrix.h"
@class UIImage;
@protocol BPFisherFacesDataSource <NSObject>
-(NSUInteger)totalNumberOfImages;
-(NSUInteger)totalNumberOfPeople;
-(NSArray*)totalImageSet;
-(int*)personImageIndexes;
@end

@interface BPFisherFaces : NSObject
@property (nonatomic, retain) BPMatrix *meanImage;
+(BPFisherFaces*)createFisherFaceAlgorithmWithDataSource:(id<BPFisherFacesDataSource>)dataSource;
-(void)train;
-(BPPreRecognitionResult*)recognizeImage:(UIImage*)image;
@end
