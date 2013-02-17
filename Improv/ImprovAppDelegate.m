#import <Parse/Parse.h>
#import "ImprovAppDelegate.h"
#import "IntroViewController.h"

@implementation ImprovAppDelegate


#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Initialize constants - load from pList file
	[Constants loadData];
	
	///////////////////////////////////////
	// Parse Initialization
	///////////////////////////////////////
	
	[Parse setApplicationId:@"WTbIj7pY3jJC3cnqxF2cidV164TOWxgTtbGfjGnF" clientKey:@"EjV6lQXjI0S35MYcaoPPkhgRXCaYvU1J9B59lvAa"];

	// Setup Facebook App ID.  Also done in Project Settings.
	NSString *appId = [[Constants data] objectForKey:@"fbAppId"];
	[PFFacebookUtils initializeWithApplicationId:appId];

	[application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
													UIRemoteNotificationTypeAlert|
													UIRemoteNotificationTypeSound];

	return YES;
}

// For Facebook-Parse integration
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	return [PFFacebookUtils handleOpenURL:url];
}

// For Facebook-Parse integration
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	return [PFFacebookUtils handleOpenURL:url];
}

///////////////////////////////
// BEGIN Push notifications
///////////////////////////////

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
	[PFPush storeDeviceToken:newDeviceToken];
	[PFPush subscribeToChannelInBackground:@"" target:self selector:@selector(subscribeFinished:error:)];

/*
	// Store the deviceToken in the current installation and save it to Parse.
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation setDeviceTokenFromData:deviceToken];
	[currentInstallation saveInBackground];
*/
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	if (error.code == 3010) {
		NSLog(@"Push notifications are not supported in the iOS Simulator.");
	} else {
		// show some alert or otherwise handle the failure to register.
		NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	[PFPush handlePush:userInfo];
}

///////////////////////////////
// END Push notifications
///////////////////////////////

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}


#pragma mark - ()

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error
{
	if ([result boolValue]) {
		NSLog(@"Improv successfully subscribed to push notifications on the broadcast channel.");
	} else {
		NSLog(@"Improv failed to subscribe to push notifications on the broadcast channel.");
	}
}


@end
