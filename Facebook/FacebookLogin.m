
//  Created by Jen Clark on 9/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookLogin.h"
#import "AppDelegate.h"
#import "GameData.h"
#import "FacebookBrain.h"


@interface FacebookLogin ()  <FacebookCallHandler>

@property (weak, nonatomic) IBOutlet UIImageView *FMKLogoView;
@property (weak, nonatomic) IBOutlet UIButton *facebookConnect;
@property (weak, nonatomic) IBOutlet UIButton *playFMK;
@property (weak, nonatomic) IBOutlet UIButton *FMKinfo;
@property (weak, nonatomic) IBOutlet UIImageView *topLine;
@property (weak, nonatomic) IBOutlet UIImageView *middleLine;
@property (weak, nonatomic) IBOutlet UIImageView *bottomLine;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressView;
@property (strong, nonatomic) FacebookBrain *brainInstance;

@end

@implementation FacebookLogin

GameData *gameData;

- (void)preCallBackTasks:(FacebookBrain *)sender;
{
    [self.progressView setHidden:FALSE];
    [self.progressView startAnimating];
    [self.FMKLogoView setHidden:TRUE];
    [self.playFMK setHidden:TRUE];
    [self.FMKinfo setHidden:TRUE];
    [self.topLine setHidden:TRUE];
    [self.middleLine setHidden:TRUE];
    [self.bottomLine setHidden:TRUE];
    [self.facebookConnect setHidden:TRUE];
}

- (void)postCallBackTasks:(FacebookBrain *)sender;
{
    [self.progressView stopAnimating];
    [self.progressView setHidesWhenStopped:TRUE];
    
    if([DataController dc].fbArray) {
        [self performSegueWithIdentifier:@"playSegue" sender:self];
    }        else {
        UIAlertView *connectionError = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"We can't seem to connect to facebook! Please make sure you are logged in and connected to the internet." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [connectionError show];
        [self.FMKLogoView setHidden:FALSE];
        [self.playFMK setHidden:FALSE];
        [self.FMKinfo setHidden:FALSE];
        [self.topLine setHidden:FALSE];
        [self.middleLine setHidden:FALSE];
        [self.bottomLine setHidden:FALSE];
        [self.facebookConnect setHidden:FALSE];
    }
}

- (void)setBrainInstance:(FacebookBrain *)brainInstance
{
    _brainInstance = brainInstance;
    self.brainInstance.delegate = self;
}


- (void)sessionStateChanged:(NSNotification*)notification {
    
    if (FBSession.activeSession.isOpen) {
        [self.facebookConnect setImage:[UIImage imageNamed:@"logOut"] forState:UIControlStateNormal];
        [self.playFMK setHidden:FALSE];
        [self.bottomLine setHidden:FALSE];
        
    }   else {
        [self.facebookConnect setImage:[UIImage imageNamed:@"connectToFacebook"] 
         forState:UIControlStateNormal];
        [self.playFMK setHidden:TRUE];
        [self.bottomLine setHidden: TRUE];
        }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
        gameData = [[GameData alloc]init];
        self.brainInstance = [[FacebookBrain alloc]init];

    if (FBSession.activeSession.isOpen) {
        [self.facebookConnect setImage:[UIImage imageNamed:@"logOut"] forState:UIControlStateNormal];
        [self.playFMK setHidden:FALSE];
        [self.bottomLine setHidden: FALSE];
        
    } else {
        [self.facebookConnect setImage:[UIImage imageNamed:@"connectToFacebook"] 
        forState:UIControlStateNormal];
        [self.playFMK setHidden:TRUE];
        [self.bottomLine setHidden: TRUE];
    }
    
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"blackNavBar"] forBarMetrics:UIBarMetricsDefault];
    
    self.FMKLogoView.Image = [UIImage imageNamed:@"kmaLogoNB"];
    [self.playFMK setImage:[UIImage imageNamed:@"startGame"] forState:UIControlStateNormal];
    [self.FMKinfo setImage:[UIImage imageNamed:@"whatTheKMA"] forState:UIControlStateNormal];
    self.topLine.Image = [UIImage imageNamed:@"greyLine"];
    self.middleLine.Image = [UIImage imageNamed:@"greyLine"];
    self.bottomLine.Image = [UIImage imageNamed:@"greyLine"];
   
    self.progressView.Hidden = TRUE;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:NO];
  
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction)facebookConnect:(id)sender {
    AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    if (FBSession.activeSession.isOpen) {
        [appDelegate closeSession];
    } else {
        [appDelegate openSessionWithAllowLoginUI:YES];
    }
}


- (IBAction)playFMK:(id)sender
{
    [self.brainInstance getFacebookData];
}



@end
