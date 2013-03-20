//
//  Friend.h
//  LikelyTo
//
//  Created by Jennifer Clark on 2/7/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * thumbnailPic;
@property (nonatomic, retain) NSString * bigPic;
@property (nonatomic) int64_t gameCount;
@property (nonatomic) int64_t diaryQ;
@property (nonatomic) int64_t islandQ;
@property (nonatomic) int64_t realityShowQ;
@property (nonatomic) int64_t statusUpdateQ;
@property (nonatomic) int64_t gameShowQ;
@property (nonatomic) int64_t blindDateQ;
@property (nonatomic) int64_t confessCrimeQ;
@property (nonatomic) int64_t kareokeQ;
@property (nonatomic) int64_t timeTravelQ;
@property (nonatomic) int64_t tatooQ;
@property (nonatomic) int64_t switchLivesQ;
@property (nonatomic) int64_t novelQ;
@property (nonatomic) int64_t driveQ;
@property (nonatomic) int64_t bucketListQ;
@property (nonatomic) int64_t clothesQ;
@property (nonatomic) int64_t fightCrimeQ;
@property (nonatomic) int64_t hairCutQ;
@property (nonatomic) int64_t lotteryQ;
@property (nonatomic) int64_t pieEatingQ;
@property (nonatomic) int64_t weddingQ;

@end
