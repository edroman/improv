//
//  Copyright (c) 2012 Parse. All rights reserved.

#import "LoginViewController.h"
#import <Parse/Parse.h>

@implementation LoginViewController

BOOL           keyboardVisible = NO;
CGPoint        offset;
UIScrollView  *scrollView = 0;
UITextField   *activeField = 0;

#pragma mark - UIViewController

// Callback that's invoked when the user presses return/done
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	// Dismiss the keyboard
	[textField resignFirstResponder];

	return YES;
}

// Validates text field
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	
	if (textField.text.length == 0) {
		return NO;
	}
	
	return YES;
}

// Tracks which field is currently being edited, for keyboard scrolling
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	activeField = textField;
}

// Tracks which field is currently being edited, for keyboard scrolling
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	activeField = nil;
}

// Callback that's invoked when the keyboard is displayed.  This is our chance to move widgets around
// so the keyboard doesn't occlude the widgets.  Corresponds to event registered in viewDidLoad()
-(void) keyboardDidShow: (NSNotification *)aNotification
{
	// If keyboard is visible, return
	if (keyboardVisible)
	{
		NSLog(@"Keyboard is already visible. Ignoring notification.");
		return;
	}

	// Get the size of the keyboard
	NSDictionary* info = [aNotification userInfo];
	CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	// Set the "content inset" of the current view to be default
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
	scrollView.contentInset = contentInsets;
	scrollView.scrollIndicatorInsets = contentInsets;
	
	// If active text field is hidden by keyboard, scroll it so it's visible by updating the
	// "content inset" to adjust for the keyboard size
	CGRect aRect = self.view.frame;
	aRect.size.height -= kbSize.height;
	if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
		CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
		[scrollView setContentOffset:scrollPoint animated:YES];
	}

	// Keyboard is now visible
	keyboardVisible = YES;
}

// Callback that's invoked when the keyboard is finished.  This is our chance to restore widgets positions
// from keyboardDidShow().  Corresponds to event registered in viewDidLoad()
-(void) keyboardDidHide: (NSNotification *)notif
{
	// Is the keyboard already shown
	if (!keyboardVisible)
	{
		NSLog(@"Keyboard is already hidden. Ignoring notification.");
		return;
	}

	// Reset the current view's "content inset" to be default again, so that UI widgets that would have
	// been occluded by keyboard are no longer scrolled
	UIEdgeInsets contentInsets = UIEdgeInsetsZero;
	scrollView.contentInset = contentInsets;
	scrollView.scrollIndicatorInsets = contentInsets;

	// Keyboard is no longer visible
	keyboardVisible = NO;
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

	// For keyboard scrolling:
	
	scrollView = (UIScrollView*) self.view;
	keyboardVisible = NO;
	activeField = 0;

	// Assign UIScrollView delegate
	((UIScrollView*) self.view).delegate = self;
	
	// Register for keyboard show/hide events
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector (keyboardDidShow:)
																name: UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector (keyboardDidHide:)
																name: UIKeyboardDidHideNotification object:nil];
	
	// Note: could alternatively register for UIKeyboardWillHideNotification instead, which triggers
	// immediately before keyboard is hidden
}

#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
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
			// Create Parse User
			
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

@end
