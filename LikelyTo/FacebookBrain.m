//
//  FacebookBrain.m
//  fmk
//
//  Created by Jennifer Clark on 11/26/12.
//
//


#import "FacebookBrain.h"

@implementation FacebookBrain

-(void)simulateSixFriends //test
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    int i;
    for (i = 0; i < 6; i ++) {
        [array addObject:[[DataController dc].facebookArray objectAtIndex:i]];
    }
    
    [DataController dc].facebookArray = nil;
    [DataController dc].facebookArray = array;
    NSLog(@"The facebook array has %i", [[DataController dc].facebookArray count]);
    
    for (NSDictionary *dictionary in [DataController dc].facebookArray) {
        NSString *name = [dictionary objectForKey:FRIEND_NAME];
        NSLog(@"%@", name);
    }
}

- (void)getFacebookData
{
        NSString *query =
        @"{"
        @"'friends':'SELECT uid2 FROM friend WHERE uid1 = me()',"
        @"'friendinfo':'SELECT uid, name, sex, pic_big, pic_square FROM user WHERE uid IN (SELECT uid2 FROM #friends)',"
        @"}";
        
        NSDictionary *queryParam = [NSDictionary dictionaryWithObjectsAndKeys:
                                    query, @"q", nil];
        
        [FBRequestConnection startWithGraphPath:@"/fql"
                                     parameters:queryParam
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error) {
        if (error) {
            if ([self.delegate respondsToSelector:@selector(showConnectionError:)]) [self.delegate showConnectionError:self];
            }     else {
                // NSLog(@"Result: %@", result);
                                  }
                                  
        NSArray *friendInfo =  (NSArray *) [[[result objectForKey:@"data"]
                                                objectAtIndex:1]
                                               objectForKey:@"fql_result_set"];
                                  
        NSArray *fbArrayTEMP = [[NSArray alloc] initWithArray:friendInfo];
        [DataController dc].facebookArray = nil;
        [DataController dc].facebookArray = fbArrayTEMP;
                            
        //after call back

        //[self simulateSixFriends];
        if ([self.delegate respondsToSelector:@selector(postCallBackTasks:)]) {
        [self.delegate postCallBackTasks:self];
          
        }
        }];
        //before call back
        if ([self.delegate respondsToSelector:@selector(postCallBackTasks:)]) {
        [self.delegate facebookFetchBegan:self];
    }
}

- (void)publishStory:(NSMutableDictionary *)parameters
{
    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:parameters
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         
         //NSString *alertText;
         if (error) {
             if ([self.delegate respondsToSelector:@selector(showConnectionError:)]) {
                 [self.delegate showConnectionError:self];
             }
                 // alertText = [NSString stringWithFormat:
                 // @"error: domain = %@, code = %d",
                 // error.domain, error.code];
         }  else {
                if ([self.delegate respondsToSelector:@selector(postCallBackTasks:)]) {
                    [[[UIAlertView alloc] initWithTitle:@"Success!"
                                                message:@"Game result was posted to your Timeline."
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil]
                     show];
                    [self.delegate postCallBackTasks:self];
                    // alertText = [NSString stringWithFormat:
                    //                          @"Posted action, id: %@",
                    //                          [result objectForKey:@"id"]];
                    // NSLog(@"%@", alertText);
                }
             
            }
         
     }];
}

- (void)getPermissionToPublishStory:(NSMutableDictionary *)postParameters
{
    // Ask for publish_actions permissions in context
    if ([FBSession.activeSession.permissions
         indexOfObject:@"publish_actions"] == NSNotFound) {
        // No permissions found in session, ask for it
        [FBSession.activeSession
         reauthorizeWithPublishPermissions:
         [NSArray arrayWithObject:@"publish_actions"]
         defaultAudience:FBSessionDefaultAudienceFriends
         completionHandler:^(FBSession *session, NSError *error) {
             if (!error) {
                 // If permissions granted, publish the story
                 [self publishStory:postParameters];
            }
         }];
    } else {
        // If permissions present, publish the story
        [self publishStory:postParameters];
      }
}

@end
