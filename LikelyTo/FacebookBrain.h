//
//  FacebookBrain.h
//  fmk
//
//  Created by Jennifer Clark on 11/26/12.
//
//


#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@class FacebookBrain;

@protocol FacebookCallHandler <NSObject>

@optional
- (void)postCallBackTasks:(FacebookBrain *)sender;
- (void)showConnectionError: (FacebookBrain *)sender;
- (void)facebookFetchBegan:(FacebookBrain *)sender;

@end

@interface FacebookBrain : NSObject

#define FRIEND_NAME @"name"
#define FRIEND_BIG_PIC @"pic_big"
#define FRIEND_SMALL_PIC @"pic_square"
#define FRIEND_UID @"uid"

@property (weak, nonatomic) id <FacebookCallHandler> delegate;

- (void)getFacebookData;

@end
