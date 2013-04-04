//
//  Friend+Create.h
//  LikelyTo
//
//  Created by Jennifer Clark on 2/8/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "Friend.h"

@interface Friend (Create)

#define QUESTION @"question"
#define DIARY @"diary"
#define ISLAND @"island"
#define REALITY_SHOW @"realityShow"
#define STATUS_UPDATE @"statusUpdates"
#define GAME_SHOW @"gameshow"
#define CONFESS_CRIME @"confessCrime"
#define KAREOKE @"kareoke"
#define BLIND_DATE  @"blindDate"
#define TIME_TRAVEL  @"timeTravel"
#define BUCKET_LIST @"bucketList"
#define DRIVE @"drive"
#define NOVEL @"novel"
#define SWITCH_LIVES @"switchLives"
#define TATOO  @"tatoo"
#define CLOTHES @"clothes"
#define FIGHT_CRIME  @"fightCrime"
#define HAIRCUT @"haircut"
#define LOTTERY @"lottery"
#define PIE_EATING @"pieEating"
#define WEDDING @"wedding"

+ (Friend *)friendWithFBInfo:(NSDictionary *)FBInfo inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSDictionary *)questionsAndQuestionKeys;


@end
