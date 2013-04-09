//
//  FriendSelectorViewController.m
//  LikelyTo
//
//  Created by Jennifer Clark on 2/5/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "FriendSelectorViewController.h"
#import "StatsTableViewController.h"
#import "FacebookBrain.h"
#import <CoreData/CoreData.h>
#import "Friend+Create.h"
#import "FacebookLogin.h"
#import "SharedDatabaseDocument.h"
#import "QuestionAskerViewController.h"

@interface FriendSelectorViewController () <FacebookCallHandler>

@property (strong, nonatomic) UIImageView *backgroundView;
@property (weak, nonatomic) UIImageView *friendOneView; //delete
@property (weak, nonatomic) UIImageView *friendTwoView; //delete
@property (weak, nonatomic) UIImageView *friendThreeView; //delete
@property (strong, nonatomic) UIActivityIndicatorView *topView;
@property (strong, nonatomic) UIActivityIndicatorView *middleView;
@property (strong, nonatomic) UIActivityIndicatorView *bottomView;
@property (strong, nonatomic) UILabel *firstFriendLabel;
@property (strong, nonatomic) UILabel *secondFriendLabel;
@property (strong, nonatomic) UILabel *thirdFriendLabel;
@property (strong, nonatomic) UIButton *topButton;
@property (strong, nonatomic) UIButton *middleButton;
@property (strong, nonatomic) UIButton *bottomButton;

@property (nonatomic) int randomIndex1;
@property (nonatomic) int randomIndex2;
@property (nonatomic) int randomIndex3;
@property (nonatomic) int imagesCropped;

@property (strong, nonatomic) NSArray *facebookPhotosAll;
@property (strong, nonatomic) NSMutableArray *savedResults;
@property (strong, nonatomic) NSString *firstFriendName;
@property (strong, nonatomic) NSString *secondFriendName;
@property (strong, nonatomic) NSString *thirdFriendName;
@property (strong, nonatomic) UIAlertView *connectionError;
@property (strong, nonatomic) FacebookBrain *brainInstance;
@property (strong, nonatomic) SharedDatabaseDocument *sharedDocument;
@property (strong, nonatomic) NSMutableArray *friendsNotChosen;
@property (strong, nonatomic) NSMutableArray *imagesNotChosen;
@property (strong, nonatomic) QuestionAskerViewController *questionController;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation FriendSelectorViewController

# pragma - mark Lazy Instantiation of Properties
- (UIAlertView *)connectionError
{
    if (!_connectionError) {
        _connectionError = [[UIAlertView alloc]initWithTitle:@"Connection Error!" message:@"We were unable to connect with Facebook. Please make sure you have a network connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
    return _connectionError;
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.imagesCropped < 3) {
    [self.navigationController popViewControllerAnimated:YES];
    [self.timer invalidate];
    } 
}

- (void)appClosed {
    [self.connectionError dismissWithClickedButtonIndex:0 animated:NO];
    [self.timer invalidate];
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(setFacebookImages:)
                                               object:nil]; 
}

- (void)appReopened
{
    if (self.imagesCropped < 3) {
        if (!self.facebookPhotosAll) [self.brainInstance getFacebookData];
        else [self setFacebookImages:self.facebookPhotosAll];
    }
}

- (void)setBrainInstance:(FacebookBrain *)brainInstance
{
    _brainInstance = brainInstance;
    self.brainInstance.delegate = self;
}

- (NSMutableArray *)friendsNotChosen
{
    if (!_friendsNotChosen)  _friendsNotChosen = [[NSMutableArray alloc]init];
    return _friendsNotChosen;
}

#pragma mark - gesture recognizers
- (void)oneFingerSwipeRight:(UITapGestureRecognizer *)recognizer {
    [self.navigationController popViewControllerAnimated:YES];
    [self maintainDataBeforeFriendIsChosen];
}

- (void)prepareGestureRecognizers
{
    UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(oneFingerSwipeRight:)];
    
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:oneFingerSwipeRight];
}

-(CGRect)makeRectForImageViews:(int)viewNumber
{
    CGFloat y = 0;

    if (self.view.frame.size.height <= 480) {
        switch (viewNumber) {
            case 1:
                y = 27; 
                self.topButton.enabled = YES;
                break;
            case 2:
                y  = 153;
                self.middleButton.enabled = YES;
                break;
            case 3:
                y = 282;
                self.bottomButton.enabled = YES;
                break;
        }

    } else if (self.view.frame.size.height > 480) {
        switch (viewNumber) {
            case 1:
                y = 34; 
                self.topButton.enabled = YES;
                break;
            case 2:
                y = 190;
                self.middleButton.enabled = YES;
                break;
            case 3:
                y = 347;
                self.bottomButton.enabled = YES;
                break;
        }
      }

    return CGRectMake(104, y, 124, 83);
}

# pragma - mark Crop Photos
- (void) cropPhoto:(UIImage *)originalImage forViewNumber:(int)viewNumber inImageView:(UIImageView *)imageView
{
    CGSize size = [originalImage size];
    UIImageView *createView = [[UIImageView alloc]initWithFrame:[self makeRectForImageViews:viewNumber]];
    imageView = createView;
    [self.view addSubview:imageView];
    
    CGRect rect = CGRectMake (size.width / 4, size.height / 4 ,
                              (size.width / 1), (size.height / 2));
  
    //core foundation objects which are "created" or "copied" must be released using CFRelease
    CGImageRef cgImage = CGImageCreateWithImageInRect([originalImage CGImage], rect);
    [imageView setImage:[UIImage imageWithCGImage:cgImage]];
    
    if (cgImage) {
        if (!self.imagesCropped) self.imagesCropped = 0;
        if (self.imagesCropped < 4)  self.imagesCropped++;
        if (!self.imagesNotChosen)  self.imagesNotChosen = [[NSMutableArray alloc]initWithCapacity:3];

        [self.imagesNotChosen addObject:imageView];
    }
    
    CGImageRelease(cgImage);
}

# pragma - maintain current data

- (void)maintainDataBeforeFriendIsChosen
{
    if ([DataController dc].imagesNotChosen == nil || [DataController dc].friendsNotChosen == nil){
        [DataController dc].imagesNotChosen =self.imagesNotChosen;
        [DataController dc].friendsNotChosen = self.friendsNotChosen;
    }
}

# pragma - get Facebook Friends and Populate View with Data
- (void)postDownloadTasks:(UIActivityIndicatorView *)spinner setLabel:(UILabel *)friendLabel withFriendName:(NSString *)friendName cropImage:(UIImage *)friendImage inImageView:(UIImageView *)imageView forViewNumber:(int)viewNumber
{
    [spinner stopAnimating];
    friendLabel.TextAlignment = NSTextAlignmentCenter;
    friendLabel.TextColor = [UIColor whiteColor];
    friendLabel.Text = friendName;
    [self cropPhoto:friendImage forViewNumber:viewNumber inImageView:imageView];

    if (self.imagesCropped == 3) {
    [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)assignRandomIndices
{
    self.randomIndex1 = arc4random()% [self.facebookPhotosAll count];
    self.randomIndex2 = arc4random()% [self.facebookPhotosAll count];
    self.randomIndex3 = arc4random()% [self.facebookPhotosAll count];
    
    if (self.randomIndex1 == self.randomIndex2 || self.randomIndex1 == self.randomIndex3 || self.randomIndex2 == self.randomIndex3) {
        [self assignRandomIndices];
    }
}

- (void)fetchImage: (NSString *)request forView:(UIActivityIndicatorView *)spinner forLabel:(UILabel *)label withName:(NSString *)name andImageView:(UIImageView *)imageView withViewNumber:(int)viewNumber
{
    __weak FriendSelectorViewController *zelf = self;
    NSMutableURLRequest *urlRequest;
    urlRequest.HTTPShouldUsePipelining = YES;
    urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:request]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if(error) {
                                   [zelf.connectionError show];
                               }   else  {
                                   UIImage *image = [UIImage imageWithData:data];
                                   [[DataController dc].facebookCachedPhotos setObject:image forKey:name];
                                   [zelf postDownloadTasks:spinner setLabel:label withFriendName:name cropImage:image inImageView:imageView forViewNumber:viewNumber];
                                    }
                        
                           }];

}

- (void)setFacebookImages: (NSArray *)facebookArray
{
    [self assignRandomIndices];
   
    NSDictionary *firstFriend = [self.facebookPhotosAll objectAtIndex:self.randomIndex1];
    NSDictionary *secondFriend = [self.facebookPhotosAll objectAtIndex:self.randomIndex2];
    NSDictionary *thirdFriend = [self.facebookPhotosAll objectAtIndex:self.randomIndex3];
    
    //maintains friend dictionaries in case the view controller is dismissed before a selection is made
    if (firstFriend) [self.friendsNotChosen addObject:firstFriend];
    if (secondFriend) [self.friendsNotChosen addObject:secondFriend];
    if (thirdFriend) [self.friendsNotChosen addObject:thirdFriend];

    //get friend names
    self.firstFriendName = [[self.facebookPhotosAll objectAtIndex:self.randomIndex1]objectForKey:FRIEND_NAME];
    self.secondFriendName = [[self.facebookPhotosAll objectAtIndex:self.randomIndex2]objectForKey:FRIEND_NAME];
    self.thirdFriendName = [[self.facebookPhotosAll objectAtIndex:self.randomIndex3]objectForKey:FRIEND_NAME];
    
    //request friend pics
    NSString *firstRequest = [[self.facebookPhotosAll objectAtIndex:self.randomIndex1]objectForKey:FRIEND_BIG_PIC];
    NSString *secondRequest = [[self.facebookPhotosAll objectAtIndex:self.randomIndex2]objectForKey:FRIEND_BIG_PIC];
    NSString *thirdRequest = [[self.facebookPhotosAll objectAtIndex:self.randomIndex3]objectForKey:FRIEND_BIG_PIC];

    //check to see if images are already in cache
    UIImage *firstImage = [[DataController dc].facebookCachedPhotos objectForKey:self.firstFriendName];
    UIImage *secondImage = [[DataController dc].facebookCachedPhotos objectForKey:self.secondFriendName];
    UIImage *thirdImage = [[DataController dc].facebookCachedPhotos objectForKey:self.thirdFriendName];
                
    if (firstImage) {
        [self postDownloadTasks:self.topView setLabel:self.firstFriendLabel withFriendName:self.firstFriendName cropImage:firstImage inImageView:self.friendOneView forViewNumber:1];
    }   else {
        [self fetchImage:firstRequest forView:self.topView forLabel:self.firstFriendLabel withName:self.firstFriendName andImageView:self.friendOneView withViewNumber:1];
        }
            
    if (secondImage) {
        [self postDownloadTasks:self.middleView setLabel:self.secondFriendLabel withFriendName:self.secondFriendName cropImage:secondImage inImageView:self.friendTwoView forViewNumber:2];
    }   else {
        [self fetchImage:secondRequest forView:self.middleView forLabel:self.secondFriendLabel withName:self.secondFriendName andImageView:self.friendTwoView withViewNumber:2];
        }
    
    if (thirdImage) {
        [self postDownloadTasks:self.bottomView setLabel:self.thirdFriendLabel withFriendName:self.thirdFriendName cropImage:thirdImage inImageView:self.friendThreeView forViewNumber:3];
    }   else {
        [self fetchImage:thirdRequest forView:self.bottomView forLabel:self.thirdFriendLabel withName:self.thirdFriendName andImageView:self.friendThreeView withViewNumber:3];
        }

}

- (void)postCallBackTasks:(FacebookBrain *)sender
{  
    if ([[DataController dc].facebookArray count] > 2) {
        [self.timer invalidate];
        self.timer = nil;
        self.facebookPhotosAll = [DataController dc].facebookArray;
        if (self.facebookPhotosAll) {
        [self setFacebookImages:self.facebookPhotosAll];
        }  else {
            [self.connectionError show];
            
        }
        
    } else [self.connectionError show];
}

- (void)facebookFetchBegan:(FacebookBrain *)sender
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(showConnectionError:) userInfo:nil repeats:NO];
}


#pragma mark - view controller life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //if this not a new game, reset the view with previously chosen facebook friends
    if ([[DataController dc].imagesNotChosen count] == 3 && [[DataController dc].friendsNotChosen count] == 3) {
    
        self.topView.hidden = YES;
        self.middleView.hidden = YES;
        self.bottomView.hidden = YES;
        
        for (UIImageView *view in [DataController dc].imagesNotChosen) {
            [self.view addSubview:view];
        }
        
    self.firstFriendName = [[[DataController dc].friendsNotChosen objectAtIndex:0]objectForKey:FRIEND_NAME];
    self.firstFriendLabel.text = self.firstFriendName;
    
    self.secondFriendName = [[[DataController dc].friendsNotChosen objectAtIndex:1]objectForKey:FRIEND_NAME];
    self.secondFriendLabel.text = self.secondFriendName;
          
    self.thirdFriendName = [[[DataController dc].friendsNotChosen objectAtIndex:2]objectForKey:FRIEND_NAME];
    self.thirdFriendLabel.text = self.thirdFriendName;

    }   else {
        [self.topView startAnimating];
        [self.middleView startAnimating];
        [self.bottomView startAnimating];
        self.topView.hidesWhenStopped = YES;
        self.middleView.hidesWhenStopped = YES;
        self.bottomView.hidesWhenStopped = YES;
        self.topButton.enabled = NO;
        self.middleButton.enabled = NO;
        self.bottomButton.enabled = NO;
        if ([[DataController dc].facebookArray count] > 2) {
            [self postCallBackTasks:nil];
            [self facebookFetchBegan:nil];
        }   else {
            self.brainInstance = [[FacebookBrain alloc]init];
            [self.brainInstance getFacebookData];
            }
        }
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


- (void)createWhiteFramesAndButtonsAndLabels {
    
    //white frame measurements
    UIImage *whiteFrame = [UIImage imageNamed:@"whitePictureFrame"];
    CGFloat x = 99;
    CGFloat width = 134;
    CGFloat height = 93;
    
    CGFloat yForTop = 21; 
    CGFloat yForMiddle = 147;
    CGFloat yForBottom = 276;
    
    if (self.view.frame.size.height > 500){
        yForTop = 30; 
        yForMiddle = 186;
        yForBottom = 341;
    }

    //label measurements
    CGFloat labelWidth = width*1.5;
    CGFloat labelHeight = 20;
    CGFloat labelX = self.view.center.x - labelWidth/2 + 8;
    
    //top frame
    CGRect topRect = CGRectMake(x, yForTop, width, height);
    UIImageView *topFrame = [[UIImageView alloc]initWithFrame:topRect];
    topFrame.image = whiteFrame;
    [self.view addSubview:topFrame];
    [self.view sendSubviewToBack:topFrame];
    
    self.topView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGPoint topCenter = CGPointMake(width/2, (yForTop + height)/2.5);
    self.topView.center = topCenter;
    [topFrame addSubview:self.topView];
    
    self.topButton = [[UIButton alloc]initWithFrame:topRect];
    self.topButton.tag = 1;
    [self.topButton addTarget:self action:@selector(friendChosen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.topButton];
    
    CGFloat labelYTop = yForTop + 7 + topFrame.frame.size.height;
    if (self.view.frame.size.height > 500) {
        labelYTop = yForTop + 15 + topFrame.frame.size.height;
    }
    
    CGRect labelFrameForTop = CGRectMake(labelX, labelYTop, labelWidth, labelHeight);
    self.firstFriendLabel = [[UILabel alloc]initWithFrame:labelFrameForTop];
    self.firstFriendLabel.backgroundColor = [UIColor clearColor];
    self.firstFriendLabel.TextAlignment = NSTextAlignmentCenter;
    self.firstFriendLabel.TextColor = [UIColor whiteColor];
    self.firstFriendLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:self.firstFriendLabel];
    
    //middle frame

    CGRect middleRect = CGRectMake(x, yForMiddle, width, height);
    UIImageView *middleFrame = [[UIImageView alloc]initWithFrame:middleRect];
    middleFrame.image = whiteFrame;
    [self.view addSubview:middleFrame];
    [self.view sendSubviewToBack:middleFrame];
    self.middleView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGPoint middleCenter = CGPointMake(width/2, (yForMiddle + height)/5.5);
    self.middleView.center = middleCenter;
    [middleFrame addSubview:self.middleView];
    
    self.middleButton = [[UIButton alloc]initWithFrame:middleRect];
    self.middleButton.tag = 2;
    [self.middleButton addTarget:self action:@selector(friendChosen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.middleButton];
    
    CGFloat labelYMiddle = yForMiddle + 7 + middleFrame.frame.size.height;
    if (self.view.frame.size.height > 500) {
    labelYMiddle = yForMiddle + 15 + middleFrame.frame.size.height;
    }
    CGRect labelFrameForMiddle = CGRectMake(labelX, labelYMiddle, labelWidth, labelHeight);
    self.secondFriendLabel = [[UILabel alloc]initWithFrame:labelFrameForMiddle];
    self.secondFriendLabel.backgroundColor = [UIColor clearColor];
    self.secondFriendLabel.TextAlignment = NSTextAlignmentCenter;
    self.secondFriendLabel.TextColor = [UIColor whiteColor];
    self.secondFriendLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:self.secondFriendLabel];
    
    //bottom frame
    CGRect bottomRect = CGRectMake(x, yForBottom, width, height);
    UIImageView *bottomFrame = [[UIImageView alloc]initWithFrame:bottomRect];
    bottomFrame.image = whiteFrame;
    [self.view addSubview:bottomFrame];
    [self.view sendSubviewToBack:bottomFrame];
    self.bottomView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGPoint bottomCenter = CGPointMake(width/2, (yForBottom + height)/8.5);
    self.bottomView.center = bottomCenter;
    [bottomFrame addSubview:self.bottomView];
    
    self.bottomButton = [[UIButton alloc]initWithFrame:bottomRect];
    self.bottomButton.tag = 3;
    [self.bottomButton addTarget:self action:@selector(friendChosen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bottomButton];
    
    CGFloat labelYBottom = yForBottom + 7 + bottomFrame.frame.size.height;
    if (self.view.frame.size.height > 500) {
    labelYBottom = yForBottom + 15 + bottomFrame.frame.size.height;
    }
    CGRect labelFrameForBottom = CGRectMake(labelX, labelYBottom, labelWidth, labelHeight);
    self.thirdFriendLabel = [[UILabel alloc]initWithFrame:labelFrameForBottom];
    self.thirdFriendLabel.backgroundColor = [UIColor clearColor];
    self.thirdFriendLabel.TextAlignment = NSTextAlignmentCenter;
    self.thirdFriendLabel.TextColor = [UIColor whiteColor];
    self.thirdFriendLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:self.thirdFriendLabel];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appClosed) name:@"AppDidCloseNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appReopened) name:@"AppDidReopenNotification" object:nil];
    
    [self createWhiteFramesAndButtonsAndLabels];
    
    self.backgroundView = [self makeColoredBackground];
    [self.view addSubview:self.backgroundView];
    [self.view sendSubviewToBack:self.backgroundView];
    [self.backgroundView setImage:[UIImage imageNamed:self.backgroundImageName]];
    
    [self prepareGestureRecognizers];
    
    if (![DataController dc].facebookCachedPhotos) {
        [DataController dc].facebookCachedPhotos = [[NSCache alloc]init];
        [[DataController dc].facebookCachedPhotos setCountLimit:200];
    }
    
    if (![DataController dc].savedResults) [DataController dc].savedResults = [[NSMutableArray alloc]init];
    self.sharedDocument = [[SharedDatabaseDocument alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
  
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - show UIAlertView
- (void)showConnectionError:(FacebookBrain *)sender;
{
    [self.connectionError show];
    if (self.timer) [self.timer invalidate];
}

- (void)animateReversePop
{
    [UIView animateWithDuration:0.50
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
                     }];
    
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma button presses
- (void)friendChosen:(UIButton *)sender {
    self.savedResults = [[NSMutableArray alloc]init];
    self.imagesCropped = 0;
    
    if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
    }
    
    switch ([sender tag]) {
        case 1:
            if ([[DataController dc].friendsNotChosen count] == 3) {
            [self.savedResults addObject:[[DataController dc].friendsNotChosen objectAtIndex:0]];
            }   else {
                    if ([self.facebookPhotosAll objectAtIndex:self.randomIndex1] != nil) {
                    [self.savedResults addObject:[self.facebookPhotosAll objectAtIndex:self.randomIndex1]];
                    }
                }
            break;
            
        case 2:
            if ([[DataController dc].friendsNotChosen count] == 3) {
            [self.savedResults addObject:[[DataController dc].friendsNotChosen objectAtIndex:1]];
            }   else {
                    if ([self.facebookPhotosAll objectAtIndex:self.randomIndex2] != nil) {
                    [self.savedResults addObject:[self.facebookPhotosAll objectAtIndex:self.randomIndex2]];
                    }
                }
            break;

        case 3:
            if ([[DataController dc].friendsNotChosen count] == 3) {
                [self.savedResults addObject:[[DataController dc].friendsNotChosen objectAtIndex:2]];
            }   else {
                    if ([self.facebookPhotosAll objectAtIndex:self.randomIndex3] != nil) {
                    [self.savedResults addObject:[self.facebookPhotosAll objectAtIndex:self.randomIndex3]];
                    }
                }
            break;
    }
        if ([self.savedResults count] == 1) {
        [[self.savedResults objectAtIndex:0]setValue:self.question forKey:@"question"];
        [[DataController dc].savedResults addObjectsFromArray:[self.savedResults copy]];
        [self.sharedDocument prepareDatabaseDocument];
        }
    
        [DataController dc].imagesNotChosen = nil;
        [DataController dc].friendsNotChosen = nil;
    
        [self.delegate prepareNewView:self];
        [self animateReversePop];
}

- (IBAction)goHome:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [DataController dc].imagesNotChosen = nil;
    [DataController dc].friendsNotChosen = nil;
    if (self.timer) [self.timer invalidate];
}

- (IBAction)arrowLeft:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self maintainDataBeforeFriendIsChosen];
    if (self.timer) [self.timer invalidate];
}

#pragma mark - prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"seeStatsFromFriendSelectorView"]) {
    [segue.destinationViewController prepareDatabaseDocument];
    [self maintainDataBeforeFriendIsChosen];
    }
}

@end
