//
//  FriendSelectorViewController.h
//  LikelyTo
//
//  Created by Jennifer Clark on 2/5/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendSelectorViewController;
@protocol ResetQuestion <NSObject>

@required

- (void)prepareNewView:(FriendSelectorViewController *)sender;

@end

@interface FriendSelectorViewController : UIViewController

@property (strong, nonatomic) NSString *backgroundImageName;
@property (strong, nonatomic) NSString *question;
@property (weak, nonatomic) id <ResetQuestion> delegate;


@end
