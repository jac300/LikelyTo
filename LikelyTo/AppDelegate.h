//
//  AppDelegate.h
//  LikelyTo
//
//  Created by Jennifer Clark on 2/5/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <FacebookSDK/FacebookSDK.h>
#import "Facebook.h"
#import "FBSBJSON.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, FBDialogDelegate>

@property (strong, nonatomic) UIWindow *window;

extern NSString *const FBSessionStateChangedNotification;

@property (nonatomic, assign) BOOL appUsageCheckEnabled;
@property (strong, nonatomic) Facebook *facebook;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) closeSession;
- (void) sendRequest;


@end
