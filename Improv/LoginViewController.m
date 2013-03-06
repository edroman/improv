//
//  Copyright (c) 2012 Parse. All rights reserved.

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()
@end

@implementation LoginViewController

#pragma mark - UIViewController

// Callback that's invoked when the user presses return/done
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	// Dismiss the keyboard
	[textField resignFirstResponder];

	return YES;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Facebook Profile";
	
	// Check if user is cached and linked to Facebook, if so, bypass login	
	if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
		NSLog(@"User logged in already - bypassing Facebook login");
		[self performSegueWithIdentifier:@"LoginToLobbySegue" sender:nil];
	}

	// Assign the UITextFieldDelegate
	UITextField *textField = (UITextField *)[self.view viewWithTag:100];
	textField.delegate = self;
	[textField setReturnKeyType:UIReturnKeyDone];
	UITextField *textField2 = (UITextField *)[self.view viewWithTag:101];
	textField2.delegate = self;
	[textField2 setReturnKeyType:UIReturnKeyDone];
	UITextField *textField3 = (UITextField *)[self.view viewWithTag:102];
	textField3.delegate = self;
	[textField3 setReturnKeyType:UIReturnKeyDone];

}

// Login to facebook method
- (IBAction)loginButtonTouchHandler:(id)sender
{
	// Set permissions required from the facebook user account
	NSArray *permissionsArray = @[@"email",@"publish_stream"];
	
	// Login PFUser using facebook
	[PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
		[_activityIndicator stopAnimating]; // Hide loading indicator
		
		if (!user) {
			if (!error) {
				NSLog(@"Uh oh. The user cancelled the Facebook login.");
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
				[alert show];
			} else {
				NSLog(@"Uh oh. An error occurred: %@", error);
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
				[alert show];
			}
		} else if (user.isNew) {
			NSLog(@"User with facebook signed up and logged in!");
			// Ask Facebook for more detailed data about the user
			// Create request for user's Facebook data
			NSString *requestPath = @"me/?fields=name,first_name,last_name,picture,email";
			
			// Send request to Facebook
			PF_FBRequest *request = [PF_FBRequest requestForGraphPath:requestPath];
			[request startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
				if (!error) {
					NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary

					// TODO: Add images, see https://parse.com/tutorials/integrating-facebook-in-ios
					// and https://parse.com/docs/ios_guide#files/iOS
					// and https://developers.facebook.com/docs/tutorials/ios-sdk-tutorial/personalize/#step2
					
					// Update Parse with that new user data
					[user setObject:userData[@"name"] forKey:@"name"];
					[user setObject:userData[@"first_name"] forKey:@"first_name"];
					[user setObject:userData[@"last_name"] forKey:@"last_name"];
					[user setObject:userData[@"email"] forKey:@"email"];
					[user setObject:userData[@"id"] forKey:@"fbID"];
					[user saveInBackground];
					
					// Save the device's owner
					PFInstallation *installation = [PFInstallation currentInstallation];
					[installation setObject:[PFUser currentUser] forKey:@"owner"];
					[installation saveInBackground];
				}
			}];
			
			
			// Load Lobby
			[self performSegueWithIdentifier:@"LoginToLobbySegue" sender:sender];
		} else {
			NSLog(@"User with facebook logged in!");
			
			// Load Lobby
			[self performSegueWithIdentifier:@"LoginToLobbySegue" sender:sender];
		}
	}];
	
	[_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

// When user submits Name/Email fields (logs in without facebook)
- (IBAction)submitButtonTouchHandler:(id)sender {
	int i;
	i = 5;
}

@end
