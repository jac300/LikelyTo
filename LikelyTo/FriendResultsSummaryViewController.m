//
//  FriendResultsSummaryViewController.m
//  LikelyTo
//
//  Created by Jennifer Clark on 2/7/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "FriendResultsSummaryViewController.h"
#import "Friend+Create.h"
#import "FacebookLogin.h"
#import "FacebookBrain.h"

@interface FriendResultsSummaryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate, FacebookCallHandler>

@property (strong, nonatomic) UILabel *friendNameLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *blueBackgroundView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIImageView *whiteFrame;
@property (strong, nonatomic) UIAlertView *connectionError;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *shareTimer;
@property (strong, nonatomic) FacebookBrain *brainInstance;
@property (strong, nonatomic) UIActivityIndicatorView *shareRequestSpinner;
@property (strong, nonatomic) UIImageView *photo;
@property (strong, nonatomic) UIButton *dismissButton;

@end

@implementation FriendResultsSummaryViewController


//delegate methods
- (void)postCallBackTasks:(FacebookBrain *)sender {
    [self.shareTimer invalidate];
    [self.shareRequestSpinner stopAnimating];
}

- (void)showConnectionError: (FacebookBrain *)sender {
    [self.connectionError show];
}

- (UIActivityIndicatorView *)makeSpinnerForShareRequest {
    
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    CGFloat x = self.view.bounds.size.width - 25;
    CGFloat y = self.view.bounds.origin.y + 20;
    
    CGPoint center = CGPointMake(x, y);
    view.center = center;
    
    view.hidesWhenStopped = YES;
    return view;
}


-(UIButton *)makeDismissButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"backButton"];
    
    CGFloat width = buttonImage.size.width;
    CGFloat height = buttonImage.size.height;
    
    CGFloat X = self.view.frame.size.width/2 - width/2;
    CGFloat Y = 1;
    
    button.frame = CGRectMake(X, Y, width, height);
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(dismissViewController:)
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

    
- (UIAlertView *)connectionError
{
    if (!_connectionError)  _connectionError = [[UIAlertView alloc]initWithTitle:@"Connection  Error!" message:@"We were unable to connect with Facebook. Please make sure you have a network connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    return _connectionError;
}

- (void)appClosed {
    [self.connectionError dismissWithClickedButtonIndex:0 animated:NO];
    [self.timer invalidate];
    [self.shareTimer invalidate];
    [self.shareRequestSpinner stopAnimating];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.connectionError) {
    [self.timer invalidate];
    [self.shareTimer invalidate];
    [self.shareRequestSpinner stopAnimating];
    
        if (!self.photo.image) {
        [self dismissViewControllerAnimated:YES completion:nil];
        }
    
    }
}

-(void)showConnectionErrorForTimeOut:(NSTimer *)timer
{
    [self.connectionError show];
    [self.timer invalidate];
    [self.shareTimer invalidate];
    [self.shareRequestSpinner stopAnimating];

}

- (void)dismissViewController:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.timer invalidate];
    [self.shareTimer invalidate];
    [self.shareRequestSpinner stopAnimating];
}

-(CGRect)makeRectForImageView
{
    CGFloat y = 60;
    
    if (self.view.frame.size.height > 500) {
        y = 55;
    }

    CGRect rect = CGRectMake(97, y, 126, 84);
    return rect;
}

-(UIImageView *)makeWhiteFrameForPhoto
{
    CGFloat x = 92;
    CGFloat width = 136;
    CGFloat height = 94;
    CGFloat y = 55;
    
    if (self.view.frame.size.height > 500) {
        y = 50;
    }
    
    CGRect frame = CGRectMake(x, y, width, height);
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    imageView.image = [UIImage imageNamed:@"whitePictureFrame"];
    
    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    CGPoint center = imageView.center;
    self.spinner.center = center;
    self.spinner.hidesWhenStopped = YES;
    
    return imageView;
}

- (UILabel *)makeNameLabel
{
    CGFloat x = 51;
    CGFloat width = 220;
    CGFloat height = 21;
    CGFloat y = 160;
    
    if (self.view.frame.size.height > 500) {
        
    }
    
    CGRect frame = CGRectMake(x, y, width, height);
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:18];
    
    return label;
    
}

- (void) cropPhoto:(UIImage *)originalImage
{
    CGSize size = [originalImage size];
    
    self.photo = [[UIImageView alloc]initWithFrame:[self makeRectForImageView]];
    [self.view addSubview:self.photo];
    
    CGRect rect = CGRectMake (size.width / 4, size.height / 4 ,
                              (size.width / 1), (size.height / 2));
    
    //core foundation objects which are "created" or "copied" must be released using CFRelease
    CGImageRef cgImage = CGImageCreateWithImageInRect([originalImage CGImage], rect);
    [self.photo setImage:[UIImage imageWithCGImage:cgImage]];
    
    CGImageRelease(cgImage);
}

- (void)facebookFetchBegan
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(showConnectionErrorForTimeOut:) userInfo:nil repeats:NO];
}

- (void)shareRequestMade
{
    self.shareTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showConnectionErrorForTimeOut:) userInfo:nil repeats:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appClosed) name:@"AppDidCloseNotification" object:nil];
    
    self.dismissButton = [self makeDismissButton];
    [self.view addSubview:self.dismissButton];
    self.whiteFrame = [self makeWhiteFrameForPhoto];
    [self.view addSubview:self.whiteFrame];
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    self.friendNameLabel = [self makeNameLabel];
    [self.view addSubview:self.friendNameLabel];
    
    CGFloat collectionViewX = 20;
    CGFloat collectionViewWidth = 280;
    CGFloat collectionViewHeight = 380;
    CGFloat collectionViewY = 210;
    
    if (self.view.frame.size.height > 500) {
        collectionViewY = 220;
    }
    
    CGRect collectionViewFrame = CGRectMake(collectionViewX, collectionViewY, collectionViewWidth, collectionViewHeight);
    
    self.collectionView.frame = collectionViewFrame;
    self.collectionView.backgroundColor = nil;

    self.spinner.hidesWhenStopped = YES;
    
    self.brainInstance = [[FacebookBrain alloc]init];
    self.brainInstance.delegate = self;

    self.friendNameLabel.text = self.friendName;
    
    UIImage *image = [[DataController dc].facebookCachedPhotos objectForKey:self.friendName];
    if (image) {
        [self cropPhoto:image];
        [self.spinner stopAnimating];
    }   else {
        __weak FriendResultsSummaryViewController *zelf = self;
        [zelf facebookFetchBegan];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.friendImageName]]
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if(error) {
                                       [zelf.connectionError show];
                                  }   else  {
                                      [zelf.timer invalidate];
                                       UIImage *image = [UIImage imageWithData:data];
                                       [[DataController dc].facebookCachedPhotos setObject:image forKey:zelf.friendName];
                                      [zelf cropPhoto:image];
                                   }
                               }];
        }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.friendNameLabel = nil;
    self.collectionView = nil;
    self.blueBackgroundView = nil;
    self.spinner = nil;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return [self.numericResults count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //background color view = tag 1
    //question view = tag 2
    //label = tag 3
    //logo view = tag 4
    
     NSArray *colors = [[NSArray alloc]initWithObjects:@"orangeBackgroundColor", @"pinkBackgroundColor", @"greenBackgroundColor", @"purpleBackgroundColor", @"yellowBackgroundColor", @"blueBackgroundColor", nil];
    
    int randomIndex = arc4random()% [colors count];
    NSString *backgroundImageName = [colors objectAtIndex:randomIndex];
    UIImage *backgroundImage = [UIImage imageNamed:backgroundImageName];

    UICollectionViewCell *cell = [collectionView
                                    dequeueReusableCellWithReuseIdentifier:@"newResult"
                                    forIndexPath:indexPath];
   
    UILabel *label; 
    label = (UILabel *)[cell viewWithTag:3];
    label.text = [NSString stringWithFormat:@"%@x", [self.numericResults objectAtIndex:indexPath.row]];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    UIImageView *colorBackrgroundView;
    colorBackrgroundView = (UIImageView *)[cell viewWithTag:1];
    colorBackrgroundView.image = backgroundImage;
    
    UIImageView *logoView; 
    logoView = (UIImageView *)[cell viewWithTag:4];
    logoView.image = [UIImage imageNamed:@"logoLoginScreen"];
    
    UIImageView *questionView;
    questionView = (UIImageView *)[cell viewWithTag:2];
    questionView.image = [UIImage imageNamed:[self.questionKeys objectAtIndex:indexPath.row]];
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self shareRequestMade];
    self.shareRequestSpinner = [self makeSpinnerForShareRequest];
    [self.view addSubview:self.shareRequestSpinner];
    [self.shareRequestSpinner startAnimating];
    
    NSNumber *stat = [self.numericResults objectAtIndex:indexPath.row];
    NSString *s;
    
    if ([stat intValue] > 1) {
        s = @"s";
    } else s = @"";
    
    NSDictionary *questionsAndKeys = [Friend questionsAndQuestionKeys];
    NSString *questionKey = [self.questionKeys objectAtIndex:indexPath.row];
    NSString *question = [questionsAndKeys objectForKey:questionKey];
    NSString *description;
    
    if ([questionKey isEqualToString:KAREOKE] || [questionKey isEqualToString:DRIVE] || [questionKey isEqualToString:LOTTERY] || [questionKey isEqualToString:WEDDING] || [questionKey isEqualToString:FIGHT_CRIME] || [questionKey isEqualToString:PIE_EATING] || [questionKey isEqualToString:BUCKET_LIST] || [questionKey isEqualToString:REALITY_SHOW] || [questionKey isEqualToString:TATOO] || [questionKey isEqualToString:TIME_TRAVEL] || [questionKey isEqualToString:ISLAND] ) {
        
        description = [NSString stringWithFormat:@"In %@ game%@, I chose %@ as the friend I'd be most likely to %@ with!", stat, s, self.friendName, question];
   
    } else if ([questionKey isEqualToString:CLOTHES] || [questionKey isEqualToString:SWITCH_LIVES] || [questionKey isEqualToString:HAIRCUT] || [questionKey isEqualToString:BLIND_DATE] || [questionKey isEqualToString:STATUS_UPDATE] || [questionKey isEqualToString:GAME_SHOW] || [questionKey isEqualToString:DIARY] ) {
        
        description = [NSString stringWithFormat:@"In %@ game%@, I chose %@ as the friend I'd be most likely to let %@!", stat, s, self.friendName, question];
    
    } else if ([questionKey isEqualToString:NOVEL]) {
        
        description = [NSString stringWithFormat:@"In %@ game%@, I chose %@ as the friend who would be most likely to %@!", stat, s, self.friendName, question];
    
    } else if ([questionKey isEqualToString:CONFESS_CRIME]) {
        
        description = [NSString stringWithFormat:@"In %@ game%@, I chose %@ as the friend who I would be most likely to %@ to!", stat, s, self.friendName, question];
    }

    NSMutableDictionary *postParameters = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                          @"https://itunes.apple.com/us/app/likelyto/id603161949?mt=8", @"link",
                                          @"LikelyTo", @"name",
                                          description, @"description",
                                          @"I just played!", @"caption",
                                          nil];
    
    [self.brainInstance getPermissionToPublishStory:postParameters];

}
                       
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
