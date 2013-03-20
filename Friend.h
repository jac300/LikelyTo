//
//  Friend.h
//  LikelyTo
//
//  Created by Jennifer Clark on 2/8/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * bigPic;
@property (nonatomic) int16_t blindDateQ;
@property (nonatomic) int16_t bucketListQ;
@property (nonatomic) int16_t clothesQ;
@property (nonatomic) int16_t confessCrimeQ;
@property (nonatomic) int16_t diaryQ;
@property (nonatomic) int16_t driveQ;
@property (nonatomic) int16_t fightCrimeQ;
@property (nonatomic) int16_t gameCount;
@property (nonatomic) int16_t gameShowQ;
@property (nonatomic) int16_t hairCutQ;
@property (nonatomic) int16_t islandQ;
@property (nonatomic) int16_t kareokeQ;
@property (nonatomic) int16_t lotteryQ;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t novelQ;
@property (nonatomic) int16_t pieEatingQ;
@property (nonatomic) int16_t realityShowQ;
@property (nonatomic) int16_t statusUpdateQ;
@property (nonatomic) int16_t switchLivesQ;
@property (nonatomic) int16_t tatooQ;
@property (nonatomic, retain) NSString * thumbnailPic;
@property (nonatomic) int16_t timeTravelQ;
@property (nonatomic) int16_t weddingQ;

@end
