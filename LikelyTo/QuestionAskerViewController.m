//
//  QuestionAskerViewController.m
//  LikelyTo
//
//  Created by Jennifer Clark on 2/5/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "QuestionAskerViewController.h"
#import "FacebookBrain.h"
#import "StatsTableViewController.h"
#import "FriendSelectorViewController.h"
#import "FacebookBrain.h"

@interface QuestionAskerViewController () <UIAlertViewDelegate, ResetQuestion>


@property (weak, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) NSString *backgroundImageName;
@property (weak, nonatomic) IBOutlet UIImageView *questionView;
@property (strong, nonatomic) NSArray *questions;
@property (strong, nonatomic) NSString *questionImageName;
@property (strong, nonatomic) FacebookBrain *brainInstance;
@property (strong, nonatomic) UIImageView *logo;

@end

@implementation QuestionAskerViewController

- (IBAction)homeButton:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

- (void)oneFingerSwipeLeft:(UITapGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"getFriendSelection" sender:self];
}

- (void)chooseRandomBackgroundColor
{
    NSArray *colors = [[NSArray alloc]initWithObjects:@"orangeBackgroundColor", @"pinkBackgroundColor", @"greenBackgroundColor", @"purpleBackgroundColor", @"yellowBackgroundColor", @"blueBackgroundColor", nil];
    int randomIndex = arc4random()% [colors count];
    self.backgroundImageName = [colors objectAtIndex:randomIndex];
    UIImage *backgroundImage = [UIImage imageNamed:self.backgroundImageName];
    [self.backgroundView setImage:backgroundImage];
}

- (void)chooseRandomQuestion
{
    self.questions = [[NSArray alloc]initWithObjects:@"diary", @"island", @"realityShow", @"statusUpdates", @"gameshow", @"confessCrime", @"kareoke", @"blindDate", @"timeTravel", @"bucketList", @"drive", @"novel", @"switchLives", @"tatoo", @"clothes", @"fightCrime", @"haircut", @"lottery", @"pieEating", @"wedding", nil];
    int randomIndex = arc4random()% [self.questions count];
    self.questionImageName = [self.questions objectAtIndex:randomIndex];
    UIImage *questionImage = [UIImage imageNamed:self.questionImageName];
    [self.questionView setImage:questionImage];
}

- (void)prepareGestureRecognizers
{
    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(oneFingerSwipeLeft:)];
    
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:oneFingerSwipeLeft];
}


- (void)prepareNewView:(FriendSelectorViewController *)friendSelectorController
{
    [self chooseRandomBackgroundColor];
    [self chooseRandomQuestion];
}


- (BOOL)checkFacebookRefreshCounter
{
    if (![DataController dc].facebookRefreshCounter) [DataController dc].facebookRefreshCounter = 0;
    [DataController dc].facebookRefreshCounter ++;
    return ([DataController dc].facebookRefreshCounter == 25) ? YES : NO;
}


- (UIImageView *)makeLogoView {
    
    UIImage *logoImage = [UIImage imageNamed:@"logoLoginScreen"];
    CGFloat width = 66;
    CGFloat height = 114;
    CGFloat x = self.view.frame.size.width/2 - width/2;
    CGFloat y = 56;
    
    if (self.view.frame.size.height > 500) {
        y = 110;
    }
    
    CGRect frame = CGRectMake(x, y, width, height);
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    imageView.image = logoImage;
    
    return imageView;
}

- (UIImageView *)makeColoredBackground {
    
    CGFloat width = self.view.frame.size.width - 10;
    CGFloat height = self.view.frame.size.height - 10;
    CGFloat x = 5;
    CGFloat y = 5;
    CGRect frame = CGRectMake(x, y, width, height);
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    
    return imageView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    if ([self checkFacebookRefreshCounter] || [[DataController dc].facebookArray count] < 3)  {
        self.brainInstance = [[FacebookBrain alloc]init];
        [self.brainInstance getFacebookData];
        [DataController dc].facebookRefreshCounter = 0;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self prepareGestureRecognizers];
   
    self.logo = [self makeLogoView];
    [self.view addSubview:self.logo];
    
    self.backgroundView = [self makeColoredBackground];
    [self.view addSubview:self.backgroundView];
    [self.view sendSubviewToBack:self.backgroundView];
    [self prepareNewView:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"getFriendSelection"]) {
    [segue.destinationViewController performSelector:@selector(setBackgroundImageName:) withObject:self.backgroundImageName];
    [segue.destinationViewController performSelector:@selector(setQuestion:) withObject:self.questionImageName];
        FriendSelectorViewController *friendViewController = segue.destinationViewController;
        friendViewController.delegate = self;
    }   else if ([segue.identifier isEqualToString:@"seeStatsFromQuestionView"]) {
        [segue.destinationViewController prepareDatabaseDocument];
        }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.backgroundView = nil;
    self.questionView = nil;
}

@end
