/* Imports */
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#include <substrate.h>


/* Definitions (Macros) */
#define Bundle_Path @"/Library/MobileSubstrate/DynamicLibraries/MovieBoxBundle.bundle"
#define Queued_Update @"Update has been queued and will commence soon."
#define AlertTitle @"Movie Box Updater"
#define AlertDownload @"Download Working"
#define AlertDismiss @"Dismiss"
#define AlertOK @"OK"

#define UpdateCheck_URL @"http://gh0stbyte.ga/iOS/moviebox.json"
#define UpdateCheck_Local @"3.6.4"
#define UpdateCheck_Alert @"There is an update available for this tweak."


/* Fake interface to allow calling of the update function, along with new sharedInstance */
@interface UpdatesManager : NSObject
/* Fool the compiler into thinking that we have the method */
- (void)requestUpdatedDataBaseWithFileURL:(NSString*)url;
/* Create sharedInstance method */
+ (id)sharedInstance;
@end

/* Variables */
static UIView *header;
static UpdatesManager *sharedInstance = nil;
NSString *updateURL;


%hook MenuViewController

/* When it sets up the headerView */
-(UIView*)headerView {
	/* set the headerview to itself */
	header = %orig;
	/* Give it a second to create the header before adding to it */
	[NSTimer scheduledTimerWithTimeInterval:1.0
    target:self
    selector:@selector(setupButton)
    userInfo:nil
    repeats:NO];
    /* return the header variable which is itself */
	return header;
}

%new
/* New function called 1 second after headerView called allowing time for it to be created */
-(void)setupButton {

	// Update Available Check
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:UpdateCheck_URL]];
	[NSURLConnection sendAsynchronousRequest:request 
		queue:[NSOperationQueue mainQueue] 
		completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
			NSDictionary *myjson = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
			updateURL = @"http://sbfunapi.cc/data/data_en.zip";
			NSString *current_version = [myjson objectForKey:@"current_version"];

			if(![current_version isEqualToString:UpdateCheck_Local]) {
				UIAlertView *a = [[UIAlertView alloc] initWithTitle:AlertTitle message:UpdateCheck_Alert delegate:self cancelButtonTitle:AlertOK otherButtonTitles:@"Update", nil];
				[a show];
				[a release];
			}
			
		}];


	CGFloat height = CGRectGetHeight(header.bounds);
	CGFloat width = CGRectGetWidth(header.bounds);

	// Create a new button that will trigger database updates. 
	UIButton *updateButton = [[UIButton alloc] initWithFrame:CGRectMake((width - 63), ((height/2) +3.333333), 20.0, 20.0)];
	// When button pressed, updateDB function will be called 
	[updateButton addTarget:self 
           action:@selector(updateDB)
	 forControlEvents:UIControlEventTouchUpInside];
	// Set the image of the button 
	[updateButton setImage:[UIImage imageWithContentsOfFile:[[[NSBundle alloc] initWithPath:Bundle_Path] pathForResource:@"refresh" ofType:@"png"]] forState:UIControlStateNormal];
	// Add button to the header UIView (header) 
	[header addSubview:updateButton];
}

%new
/* Function to update the Database */
-(void)updateDB {
	/* Let the user know that the update has been queued. Good for older phones that take a while to actually show the update process, and prevent the user
	   from spamming the update button. */
	UIAlertView *a = [[UIAlertView alloc] initWithTitle:AlertTitle message:Queued_Update delegate:nil cancelButtonTitle:AlertOK otherButtonTitles:nil];
	[a show];
	[a release];
	/* Use the sharedInstance function (returns the current instance) to call the requestUpdateBlah function with our updateURL grabbed from the server */
	[[%c(UpdatesManager) sharedInstance] requestUpdatedDataBaseWithFileURL:updateURL];
}

%new
// When the user presses a button 
- (void)alertView :(UIAlertView*)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {

	if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString: @"Update"]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://cydia.dtathemes.com/"]];
	}

}

%end

%hook UpdatesManager
/* When an UpdatesManager instance is created */
- (id)init
{
	/* we set our sharedInstance to be the current instance of the UpdatesManager */
	sharedInstance = %orig;
	/* Then we return the sharedInstance which is itself */
	return sharedInstance;
}

/* Create new sharedInstance */
%new 
+ (id)sharedInstance
{
	/* It returns the current instance of the UpdatesManger */
	return sharedInstance;	
}

%end
