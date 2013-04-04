//
//  Friend+Create.m
//  LikelyTo
//
//  Created by Jennifer Clark on 2/7/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "Friend+Create.h"
#import "FacebookBrain.h"

@implementation Friend (Create)

+ (Friend *)friendWithFBInfo:(NSDictionary *)FBInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Friend *friend = nil;
    
    //before creating a new friend, check the database to see if that friend already exists
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", [FBInfo objectForKey:FRIEND_NAME]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    //execute the request
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error]; //array of all the photos that match the predicate
    
    //if matches is nil, that qualifies as an error
    if (!matches || [matches count] > 1) {
        return nil;
        
    } else if ([matches count] == 0) { //if there are no matches then add it to the database
        
        friend = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:context];
        friend.name = [FBInfo objectForKey:FRIEND_NAME];
        friend.thumbnailPic = [FBInfo objectForKey:FRIEND_SMALL_PIC];
        friend.bigPic = [FBInfo objectForKey:FRIEND_BIG_PIC];
        
        friend.diaryQ = 0;
        friend.islandQ = 0;
        friend.realityShowQ = 0;
        friend.statusUpdateQ = 0;
        friend.gameShowQ = 0;
        friend.blindDateQ = 0;
        friend.confessCrimeQ = 0;
        friend.kareokeQ = 0;
        friend.timeTravelQ = 0;
        friend.tatooQ = 0;
        friend.switchLivesQ = 0;
        friend.novelQ = 0;
        friend.driveQ = 0;
        friend.bucketListQ = 0;
        friend.clothesQ = 0;
        friend.fightCrimeQ = 0;
        friend.hairCutQ = 0;
        friend.lotteryQ = 0;
        friend.pieEatingQ = 0;
        friend.weddingQ = 0;
        
        friend.gameCount = 1;
        
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:DIARY]) friend.diaryQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:ISLAND]) friend.islandQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:REALITY_SHOW]) friend.realityShowQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:STATUS_UPDATE]) friend.statusUpdateQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:GAME_SHOW]) friend.gameShowQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:BLIND_DATE]) friend.blindDateQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:CONFESS_CRIME]) friend.confessCrimeQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:KAREOKE]) friend.kareokeQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:TIME_TRAVEL]) friend.timeTravelQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:TATOO]) friend.tatooQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:SWITCH_LIVES]) friend.switchLivesQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:NOVEL]) friend.novelQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:DRIVE]) friend.driveQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:BUCKET_LIST]) friend.bucketListQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:CLOTHES]) friend.clothesQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:FIGHT_CRIME]) friend.fightCrimeQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:HAIRCUT]) friend.hairCutQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:LOTTERY]) friend.lotteryQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:PIE_EATING]) friend.pieEatingQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:WEDDING]) friend.weddingQ ++;
        
    } else { //if matches is 1
        
        friend = [matches lastObject];
        
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:DIARY]) friend.diaryQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:ISLAND]) friend.islandQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:REALITY_SHOW]) friend.realityShowQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:STATUS_UPDATE]) friend.statusUpdateQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:GAME_SHOW]) friend.gameShowQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:BLIND_DATE]) friend.blindDateQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:CONFESS_CRIME]) friend.confessCrimeQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:KAREOKE]) friend.kareokeQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:TIME_TRAVEL]) friend.timeTravelQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:TATOO]) friend.tatooQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:SWITCH_LIVES]) friend.switchLivesQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:NOVEL]) friend.novelQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:DRIVE]) friend.driveQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:BUCKET_LIST]) friend.bucketListQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:CLOTHES]) friend.clothesQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:FIGHT_CRIME]) friend.fightCrimeQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:HAIRCUT]) friend.hairCutQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:LOTTERY]) friend.lotteryQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:PIE_EATING]) friend.pieEatingQ ++;
        if ([[FBInfo objectForKey:QUESTION]isEqualToString:WEDDING]) friend.weddingQ ++;
        
        friend.gameCount ++;
    }
    
    return friend;
    
}

+ (NSArray *)questionsFormattedForPosting
{
    NSArray *questions = [[NSArray alloc]initWithObjects:
                          @ "pick out my clothes every day",
                          @ "sing karaoke",
                          @ "drive across country",
                          @ "split my lottery winnings",
                          @ "switch lives with me",
                          @ "crash a wedding",
                          @ "fight crime",
                          @ "enter a pie eating contest",
                          @ "go on a bucket list adventure",
                          @ "inspire a novel",
                          @ "cut my hair",
                          @ "star on a reality show",
                          @ "get a tattoo",
                          @ "set me up on a blind date",
                          @ "time travel",
                          @ "write my status updates",
                          @ "be my partner on a game show",
                          @ "read my diary",
                          @ "confess a crime to",
                          @ "choose to be stranded on a desert island",
                          nil];
    return questions;
}


+(NSArray *)questionKeys
{
    NSArray *questionKeys = [[NSArray alloc]initWithObjects:
                             CLOTHES, KAREOKE, DRIVE, LOTTERY, SWITCH_LIVES, WEDDING, FIGHT_CRIME, PIE_EATING, BUCKET_LIST, NOVEL, HAIRCUT, REALITY_SHOW, TATOO, BLIND_DATE, TIME_TRAVEL, STATUS_UPDATE, GAME_SHOW, DIARY, CONFESS_CRIME, ISLAND
                             , nil];
    return questionKeys;
}


+ (NSDictionary *)questionsAndQuestionKeys
{
    NSDictionary *dictionary = [[NSDictionary alloc]initWithObjects:[self questionsFormattedForPosting] forKeys:[self questionKeys]];
    
    return dictionary;
}


@end