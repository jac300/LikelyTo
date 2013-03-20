
#import <Foundation/Foundation.h>

//singleton class
@interface DataController : NSObject {
	
	NSString *baseURL;
    NSArray *facebookArray;
    NSMutableArray *savedResults;
    NSCache *facebookCachedPhotos;
    NSArray *imagesNotChosen;
    NSArray *friendsNotChosen;
    UIManagedDocument *database;
    int facebookRefreshCounter;
}

@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSArray *facebookArray;
@property (nonatomic, strong) NSMutableArray *savedResults;
@property (strong, nonatomic) NSCache *facebookCachedPhotos;
@property (strong, nonatomic) NSArray *imagesNotChosen;
@property (strong, nonatomic) NSArray *friendsNotChosen;
@property (nonatomic, strong) UIManagedDocument *database;
@property (nonatomic) int facebookRefreshCounter;


// SINGLETON BUSINESS
+ (DataController *) dc;
+ (id) allocWithZone : (NSZone *)zone;
- (id) copyWithZone : (NSZone *)zone;

@end
