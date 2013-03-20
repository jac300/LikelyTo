
#import "DataController.h"


@implementation DataController

//fmk-Prefix.pch and add this class so it is automicatically imported to all classes!

@synthesize baseURL;
@synthesize facebookArray;
@synthesize savedResults;
@synthesize facebookCachedPhotos;
@synthesize imagesNotChosen;
@synthesize friendsNotChosen;
@synthesize database;
@synthesize facebookRefreshCounter;

- (id) init {
	
	self = [super init];
	
	if (self) {
		
		baseURL = [NSString stringWithFormat:@"http://www.fmk.com/"];
		
	}
    
	return self;
	
}

#pragma mark - Singleton Methods

+ (DataController *) dc {
	
	static DataController *_sharedInstance;
	
	if(!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[super allocWithZone:nil] init];
		});
	}
	
	return _sharedInstance;
	
}

+ (id)allocWithZone:(NSZone *)zone {	
	
	return [self dc];
}
- (id)copyWithZone:(NSZone *)zone {
	return self;	
}


@end

