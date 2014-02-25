//
//  BPFisherFaces.h
//  BPFacialRecognition
//
//  Created by Robby Cohen on 2/9/14.
//  Copyright (c) 2014 BP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPRecognitionResult.h"
@class UIImage;
@protocol BPFisherFacesDataSource <NSObject>
-(NSUInteger)totalNumberOfImages;
-(NSUInteger)totalNumberOfPeople;
-(NSArray*)totalImageSet;
-(int*)personImageIndexes;
@end

@interface BPFisherFaces : NSObject
+(BPFisherFaces*)createFisherFaceAlgorithmWithDataSource:(id<BPFisherFacesDataSource>)dataSource;
-(void)train;
-(RecResult)recognizeImage:(UIImage*)image;
@end
