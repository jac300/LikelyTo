//
//  FacebookBrain.m
//  fmk
//
//  Created by Jennifer Clark on 11/26/12.
//
//


#import "FacebookBrain.h"

@implementation FacebookBrain



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

        //if a protocol is optional, check to make sure self.delegate respondsToSelector
        if ([self.delegate respondsToSelector:@selector(postCallBackTasks:)]) {
        [self.delegate postCallBackTasks:self];
          
        }
        }];
        //before call back
        if ([self.delegate respondsToSelector:@selector(postCallBackTasks:)]) {
        [self.delegate facebookFetchBegan:self];
        
    }

    
}



@end
