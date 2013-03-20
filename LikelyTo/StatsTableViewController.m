//
//  StatsTableViewController.m
//  LikelyTo
//
//  Created by Jennifer Clark on 2/6/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "StatsTableViewController.h"
#import <CoreData/CoreData.h>
#import "Friend+Create.h"

@interface StatsTableViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;
@property BOOL debug;
@property (nonatomic) BOOL beganUpdates;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIAlertView *savingError;
@property (weak, nonatomic) IBOutlet UIImageView *activityView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation StatsTableViewController

#pragma mark - lazy instantiation of properties
- (UIAlertView *)savingError
{
    if (!_savingError) {
        _savingError = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Sorry, we were unable to save the results of this game. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
    return _savingError;
}

- (UIActivityIndicatorView *)spinner
{
    if (!_spinner) {
   _spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    
    return  _spinner;
}

- (void)setUpSpinner
{
    [self.activityView addSubview:self.spinner];
    [self.spinner startAnimating];
    self.spinner.hidesWhenStopped = YES;
}

#pragma mark - core data query and saving
- (void)setUpFetchedResultsController
{
    NSArray *results;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
    // request.predicate = don't specify to get all of the objects
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:[DataController dc].database.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    //sectionNameKeyPath defines the name of each section

    NSError *error = nil;
    results = [[DataController dc].database.managedObjectContext
                            executeFetchRequest:request error:&error];
    
    if ([results count] == 0) self.spinner = nil;
}

- (void)useDocument
{
    __weak StatsTableViewController *zelf = self;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[DataController dc].database.fileURL path]]) {
        __weak StatsTableViewController *zelf = self;
        [[DataController dc].database saveToURL:[DataController dc].database.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)  {
            [zelf setUpFetchedResultsController];
        }];
    }   else if ([DataController dc].database.documentState == UIDocumentStateClosed) {
        [[DataController dc].database openWithCompletionHandler:^(BOOL success) {
        [zelf setUpFetchedResultsController];
        [zelf setUpSpinner];
        }];
        }   else if ([DataController dc].database.documentState == UIDocumentStateNormal) {
            [zelf setUpFetchedResultsController];
            [zelf setUpSpinner];
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

#pragma mark - fetched results controller protocols
- (void)performFetch
{   self.debug = NO;
    if (self.fetchedResultsController) {
        if (self.fetchedResultsController.fetchRequest.predicate) {
            if (self.debug) NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
        } else {
            if (self.debug) NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
        }
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    } else {
        if (self.debug) NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
    //NSLog(@"The number of rows will be %i",[[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects]);
    [self.tableView reloadData];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
    self.debug = NO;
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc) {
        _fetchedResultsController = newfrc;
        newfrc.delegate = self;
        if ((!self.title || [self.title isEqualToString:oldfrc.fetchRequest.entity.name]) && (!self.navigationController || !self.navigationItem.title)) {
            //self.title = newfrc.fetchRequest.entity.name;
            self.title = nil;
        }
        if (newfrc) {
            if (self.debug) NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
            [self performFetch];
        } else {
            if (self.debug) NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        [self.tableView beginUpdates];
        self.beganUpdates = YES;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.beganUpdates) [self.tableView endUpdates];
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    if (suspend) {
        _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else {
        [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
    }
}

#pragma mark - view controller class methods
- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"newFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // try cacheing images if using FB thumbnail images of friends
    //cells are re-used, so must change pic if cell is dismissed and re-used during scrolling before download completes
    
    //get the managed object that is on each row
    Friend *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = friend.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i Games", friend.gameCount]; 
    [self.spinner stopAnimating];
    cell.imageView.image = [UIImage imageNamed:@"icon57x57"];
    
    return cell;
    
//    dispatch_queue_t downloadQueue = dispatch_queue_create("Get FB Friend", NULL);
//    dispatch_async(downloadQueue, ^{
    
        //NSString *string4pic = friend.thumbnailPic;
//        UIImage *image = [UIImage imageWithData:
//                          [NSData dataWithContentsOfURL:
//                           [NSURL URLWithString:string4pic]]];
////        dispatch_async(dispatch_get_main_queue(), ^{
            
            //cell.imageView.image = image;
    
//        });
//    });
//    
    
}

/*
- (void)startImageFetchForFriend:(Friend*)friend
{
    
    // Make asynchronous request and get image in block
    [NSURLConnection sendAsynchronousRequest: [NSURL URLWithString:friend.thumbnailPic] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        // Make sure eveything is ok
        if(error){
            // do something
        }
        
        UIImage *image = [UIImage imageWithData:data];
        
        // Set the cache value as specified above, based on friend ID
        
        // Check to see if cell with friend.id is visible. If so, update just that cell's image view. (if you choose not to use the main operation queue, make sure this call happens on the main thread.
        
    }];
}
*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak StatsTableViewController *zelf = self;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Friend *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[DataController dc].database.managedObjectContext deleteObject:friend];
        NSError *error = nil;
        [[DataController dc].database.managedObjectContext save:&error];
        
        [[DataController dc].database saveToURL:[DataController dc].database.fileURL
                forSaveOperation:UIDocumentSaveForOverwriting
               completionHandler:^(BOOL success) {
                   if (success) {
                       //NSLog(@"saved");
                   } else {
                       [zelf.savingError show];
                   }
               }];
    }
    
    [self.tableView reloadData];
}

#pragma mark - view controller life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.tableView = nil;
    self.activityView = nil;
}

#pragma mark - prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"friendResultsDetail"]){
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Friend *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (segue.destinationViewController) {
    [segue.destinationViewController performSelector:@selector(setFriendName:) withObject:friend.name];
    [segue.destinationViewController performSelector:@selector(setFriendImageName:) withObject:friend.bigPic];
    }
    
    NSNumber *diary = [NSNumber numberWithInt:friend.diaryQ];
    NSNumber *island = [NSNumber numberWithInt:friend.islandQ];
    NSNumber *realityShow = [NSNumber numberWithInt:friend.realityShowQ];
    NSNumber *statusUpdate = [NSNumber numberWithInt:friend.statusUpdateQ];
    NSNumber *gameShow = [NSNumber numberWithInt:friend.gameShowQ];
    NSNumber *blindDate = [NSNumber numberWithInt:friend.blindDateQ];
    NSNumber *confessCrime = [NSNumber numberWithInt:friend.confessCrimeQ];
    NSNumber *kareoke = [NSNumber numberWithInt:friend.kareokeQ];
    NSNumber *timeTravel = [NSNumber numberWithInt:friend.timeTravelQ];
    NSNumber *tatoo = [NSNumber numberWithInt:friend.tatooQ];
    NSNumber *switchLives = [NSNumber numberWithInt:friend.switchLivesQ];
    NSNumber *novel = [NSNumber numberWithInt:friend.novelQ];
    NSNumber *drive = [NSNumber numberWithInt:friend.driveQ];
    NSNumber *bucketList = [NSNumber numberWithInt:friend.bucketListQ];
    NSNumber *clothes = [NSNumber numberWithInt:friend.clothesQ];
    NSNumber *fightCrime = [NSNumber numberWithInt:friend.fightCrimeQ];
    NSNumber *hairCut = [NSNumber numberWithInt:friend.hairCutQ];
    NSNumber *lottery = [NSNumber numberWithInt:friend.lotteryQ];
    NSNumber *pieEating = [NSNumber numberWithInt:friend.pieEatingQ];
    NSNumber *wedding = [NSNumber numberWithInt:friend.weddingQ];

    NSArray *currentStats = [[NSArray alloc]initWithObjects:diary, island, realityShow, statusUpdate, gameShow, blindDate, confessCrime, kareoke, timeTravel, tatoo, switchLives, novel, drive, bucketList, clothes, fightCrime, hairCut, lottery, pieEating, wedding, nil];

    NSArray *keysForStats = [[NSArray alloc]initWithObjects:DIARY, ISLAND, REALITY_SHOW, STATUS_UPDATE, GAME_SHOW, BLIND_DATE, CONFESS_CRIME, KAREOKE, TIME_TRAVEL, TATOO, SWITCH_LIVES, NOVEL, DRIVE, BUCKET_LIST, CLOTHES, FIGHT_CRIME, HAIRCUT, LOTTERY, PIE_EATING, WEDDING, nil];
    
    NSMutableArray *currentStatsForEditing = [[NSMutableArray alloc]initWithCapacity:[currentStats count]];
    NSMutableArray *keysForStatsForEditing = [[NSMutableArray alloc]initWithCapacity:[keysForStats count]];
    
    int i;
    for (i = 0; i < [currentStats count]; i++) {
        int integer = [[currentStats objectAtIndex:i] intValue];
        if (integer > 0) {
            [currentStatsForEditing addObject:[currentStats objectAtIndex:i]];
            [keysForStatsForEditing addObject:[keysForStats objectAtIndex:i]];
        }
    }
    
    if (segue.destinationViewController) {
    [segue.destinationViewController performSelector:@selector(setNumericResults:) withObject:currentStatsForEditing];
    [segue.destinationViewController performSelector:@selector(setQuestionKeys:) withObject:keysForStatsForEditing];
    }
    }

}

@end
