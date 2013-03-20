//
//  FriendResultsSummaryViewController.h
//  LikelyTo
//
//  Created by Jennifer Clark on 2/7/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendResultsSummaryViewController : UIViewController

@property (strong, nonatomic) NSString *friendName;
@property (strong, nonatomic) NSString *friendImageName;
@property (strong, nonatomic) NSArray *numericResults;
@property (strong, nonatomic) NSArray *questionKeys;

@end
