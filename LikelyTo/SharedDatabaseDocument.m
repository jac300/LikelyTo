//
//  SharedDatabaseDocument.m
//  LikelyTo
//
//  Created by Jennifer Clark on 3/5/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "SharedDatabaseDocument.h"

@interface SharedDatabaseDocument()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation SharedDatabaseDocument

- (void)fetchDataIntoDocument:(UIManagedDocument *)document
{
    if ([[DataController dc].savedResults count] > 0) {
        dispatch_queue_t fetchQ = dispatch_queue_create("get results data", NULL);
        dispatch_async(fetchQ, ^{
            NSArray *friends = [DataController dc].savedResults;
            [document.managedObjectContext performBlock:^{
                for (NSDictionary *friendInfo in friends) { //add photos to database
                    [Friend friendWithFBInfo:friendInfo inManagedObjectContext:document.managedObjectContext];
                }
                NSError *error = nil;
                [[DataController dc].database.managedObjectContext save:&error];
                [[DataController dc].database saveToURL:[DataController dc].database.fileURL
                        forSaveOperation:UIDocumentSaveForOverwriting
                       completionHandler:^(BOOL success) {
                           if (success) {
                               //NSLog(@"saved");
                           } else {
                               //handle error
                           }
                       }];
                [DataController dc].savedResults = nil;
            }];
        });
    } 
}

- (void)useDocument
{
    __weak SharedDatabaseDocument *zelf = self;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[DataController dc].database.fileURL path]]) {
        [[DataController dc].database saveToURL:[DataController dc].database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)  {
            [zelf fetchDataIntoDocument:[DataController dc].database];
        }];
    }   else if ([DataController dc].database.documentState == UIDocumentStateClosed) {
        [[DataController dc].database openWithCompletionHandler:^(BOOL success) {
            [zelf fetchDataIntoDocument:[DataController dc].database];
        }];
        }   else if ([DataController dc].database.documentState == UIDocumentStateNormal) {
            [self fetchDataIntoDocument:[DataController dc].database];
            }
}


- (void)prepareDatabaseDocument
{
    if (![DataController dc].database) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
        url = [url URLByAppendingPathComponent:@"Default Database"];
        [DataController dc].database = [[UIManagedDocument alloc]initWithFileURL:url];
        }
    
    [self useDocument];
}


@end
