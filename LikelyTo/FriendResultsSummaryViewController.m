//
//  FriendResultsSummaryViewController.m
//  LikelyTo
//
//  Created by Jennifer Clark on 2/7/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "FriendResultsSummaryViewController.h"
#import "FacebookLogin.h"

@interface FriendResultsSummaryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *friendImageView;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *resultView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *blueBackgroundView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIAlertView *connectionError;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation FriendResultsSummaryViewController

- (UIAlertView *)connectionError
{
    if (!_connectionError)  _connectionError = [[UIAlertView alloc]initWithTitle:@"Connection  Error!" message:@"We were unable to connect with Facebook. Please make sure you have a network connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];

    return _connectionError;
}

- (void)appClosed {
    [self.connectionError dismissWithClickedButtonIndex:0 animated:NO];
    [self.timer invalidate];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
     [self dismissViewControllerAnimated:YES completion:nil];
    [self.timer invalidate];
}

-(void)showConnectionError:(NSTimer *)timer
{
    [self.connectionError show];
    if (self.timer) [self.timer invalidate];
}

- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) cropPhoto:(UIImage *)originalImage inImageView:(UIImageView *)imageView atXPoint:(int)x atYPoint:(int)y withWidthSize:(int)width withHeightSize:(int)height
{
    CGSize size = [originalImage size];
    
    [imageView setFrame:CGRectMake(0, 0, size.width, size.height)];
    [self.view addSubview:imageView];
    
    CGRect rect = CGRectMake (size.width / 4, size.height / 4 ,
                              (size.width / 1), (size.height / 2));
    
    CGImageRef cgImage = CGImageCreateWithImageInRect([originalImage CGImage], rect);
    [imageView setImage:[UIImage imageWithCGImage:cgImage]];
    CGImageRelease(cgImage);
}

- (void)facebookFetchBegan
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:12.0 target:self selector:@selector(showConnectionError:) userInfo:nil repeats:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appClosed) name:@"AppDidCloseNotification" object:nil];
    
    self.collectionView.backgroundColor = nil;
    [self.spinner startAnimating];
    self.spinner.hidesWhenStopped = YES;

    self.friendNameLabel.text = self.friendName;
    self.friendNameLabel.textAlignment = NSTextAlignmentCenter;
    self.friendNameLabel.textColor = [UIColor whiteColor];
    
    UIImage *image = [[DataController dc].facebookCachedPhotos objectForKey:self.friendName];
    if (image) {
        [self cropPhoto:image inImageView:self.friendImageView atXPoint:97 atYPoint:87 withWidthSize:127 withHeightSize:85];
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
                                        [zelf cropPhoto:image inImageView:zelf.friendImageView atXPoint:97 atYPoint:87 withWidthSize:127 withHeightSize:85];
                                   }
                               }];
        }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.friendImageView = nil;
    self.friendNameLabel = nil;
    self.resultView = nil;
    self.collectionView = nil;
    self.blueBackgroundView = nil;
    self.spinner = nil;
    self.collectionView = nil;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
