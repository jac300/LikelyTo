
//  Created by Jen Clark on 9/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookLogin.h"
#import "AppDelegate.h"
#import "StatsTableViewController.h"

@interface FacebookLogin ()

@property (weak, nonatomic) IBOutlet UIButton *facebookConnectOrPlay;
@property (weak, nonatomic) IBOutlet UIButton *gameInfo;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UIImageView *infoTextView;
@property (weak, nonatomic) IBOutlet UIButton *seeStatsButton;
@property (nonatomic) BOOL infoViewIsVisible;

@end

@implementation FacebookLogin


- (void)sessionStateChanged:(NSNotification*)notification {
    
    if (FBSession.activeSession.isOpen) {
    UIImage *image = [UIImage imageNamed:@"playButton4Login"];
    [self.facebookConnectOrPlay setImage:image forState:UIControlStateNormal];
    self.seeStatsButton.hidden = NO;
    }  else {
        UIImage *image = [UIImage imageNamed:@"connectButton"];
        self.seeStatsButton.hidden = YES;
        [self.facebookConnectOrPlay setImage:image forState:UIControlStateNormal];
        }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.facebookConnectOrPlay = nil;
    self.gameInfo = nil;
    self.logoView = nil;
    self.infoTextView = nil;
    self.seeStatsButton = nil;
}


- (IBAction)facebookConnectOrPlay:(UIButton *)sender {
    AppDelegate *appDelegate =(AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (FBSession.activeSession.isOpen) {
       [self performSegueWithIdentifier:@"playGame" sender:self];
        //[appDelegate closeSession];
    } else [appDelegate openSessionWithAllowLoginUI:YES];
}


- (void)adjustPositionOfLogoViewforGameInfo: (UIView *)view
{
    CGFloat x =  view.center.x;
    CGFloat y;
    if (!self.infoViewIsVisible) y = view.center.y - (self.view.bounds.size.height *0.12);
        else y = view.center.y + (self.view.bounds.size.height * 0.12);
    view.center = CGPointMake(x, y);
}


- (void)adjustPositionOfInfoText: (UIView *)view
{
    CGFloat x =  view.center.x;
    CGFloat y;
    
    if (!self.infoViewIsVisible) y = self.view.bounds.size.height * 0.68;
        else y = self.view.bounds.size.height + view.center.y;
    
    view.center = CGPointMake(x, y);
}

- (IBAction)gameInfo:(UIButton *)sender {
    
    self.infoViewIsVisible = [self.facebookConnectOrPlay isHidden];
    
    UIImage *infoImage = [UIImage imageNamed:@"infoIcon"];
    UIImage *exitInfoImage = [UIImage imageNamed:@"exitInfoButton"];
    UIImage *infoText = [UIImage imageNamed:@"infoText"];
    
    if (self.infoViewIsVisible) {
    [self.gameInfo setImage:infoImage forState:UIControlStateNormal];
    }   else {
        self.facebookConnectOrPlay.hidden = YES;
        self.seeStatsButton.hidden = YES;
        [self.gameInfo setImage:exitInfoImage forState:UIControlStateNormal];
        [self.infoTextView setImage:infoText];
        }
    
    UIViewAnimationOptions options = UIViewAnimationOptionCurveLinear;
    __weak FacebookLogin *zelf = self;
    [UIView animateWithDuration:0.8 delay:0 options:options animations:^{
        [zelf adjustPositionOfLogoViewforGameInfo:zelf.logoView];
        [zelf adjustPositionOfInfoText:zelf.infoTextView];
        } completion:^(BOOL finished) {
            if (finished) {
                if (zelf.infoViewIsVisible) {
                    zelf.facebookConnectOrPlay.hidden = NO;
                    zelf.seeStatsButton.hidden = NO;
                    self.infoViewIsVisible = [self.facebookConnectOrPlay isHidden];
                }
            }

        }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    if (FBSession.activeSession.isOpen) {
    UIImage *image = [UIImage imageNamed:@"playButton4Login"];
    [self.facebookConnectOrPlay setImage:image forState:UIControlStateNormal];
    self.seeStatsButton.hidden = NO;
    }   else {
            UIImage *image = [UIImage imageNamed:@"connectButton"];
            [self.facebookConnectOrPlay setImage:image forState:UIControlStateNormal];
            self.seeStatsButton.hidden = YES;
            }
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:NO];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"seeStatsFromLoginView"]) {
        [segue.destinationViewController prepareDatabaseDocument];
    }
}



@end
