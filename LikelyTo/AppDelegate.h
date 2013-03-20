//
//  AppDelegate.h
//  LikelyTo
//
//  Created by Jennifer Clark on 2/5/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

extern NSString *const FBSessionStateChangedNotification;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) closeSession;


@end
