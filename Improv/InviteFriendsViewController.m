//
//  InviteFriendsViewController.m
//  Improv
//
//  Created by Ed Roman on 1/11/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import <Parse/Parse.h>
#import "PlayStoryViewController.h"

@interface InviteFriendsViewController ()
// Holds the friends retrieved from FB
@property (nonatomic, strong) NSMutableArray *fbFriends;
@property (strong, nonatomic) PF_FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;
@end

@implementation InviteFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	// Allocate memory for our friend list
	if (!self.fbFriends) self.fbFriends = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////
// BEGIN FBFriendPicker Stuff
////////////////////////////////////////////////////////

@synthesize friendPickerController = _friendPickerController;
@synthesize searchBar = _searchBar;
@synthesize searchText = _searchText;

- (void)dealloc
{
	_friendPickerController.delegate = nil;
}

- (void)addSearchBarToFriendPickerView
{
	if (self.searchBar == nil) {
		CGFloat searchBarHeight = 44.0;
		self.searchBar =
		[[UISearchBar alloc]
		 initWithFrame:
		 CGRectMake(0,0,
						self.view.bounds.size.width,
						searchBarHeight)];
		self.searchBar.autoresizingMask = self.searchBar.autoresizingMask |
		UIViewAutoresizingFlexibleWidth;
		self.searchBar.delegate = self;
		self.searchBar.showsCancelButton = NO;
		
		[self.friendPickerController.canvasView addSubview:self.searchBar];
		CGRect newFrame = self.friendPickerController.view.bounds;
		newFrame.size.height -= searchBarHeight;
		newFrame.origin.y = searchBarHeight;
		self.friendPickerController.tableView.frame = newFrame;
	}
}

// Invoked each time a user presses a key in the search bar.  Here we dynamically filter the friends down
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	self.searchText = searchBar.text;
	[self.friendPickerController updateView];
}

// Invoked when the user presses "Search" -- here we dismiss the keyboard
- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
	[searchBar resignFirstResponder];
	self.searchText = searchBar.text;
	[self.friendPickerController updateView];
}

// When the user presses the "cancel" button on Search -- currently unused since we don't have a button
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
	self.searchText = nil;
	[searchBar resignFirstResponder];
	[self.friendPickerController updateView];
}

- (BOOL)friendPickerViewController:(PF_FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<PF_FBGraphUser>)user
{
	if (self.searchText && ![self.searchText isEqualToString:@""]) {
		NSRange result = [user.name
								rangeOfString:self.searchText
								options:NSCaseInsensitiveSearch];
		if (result.location != NSNotFound) {
			return YES;
		} else {
			return NO;
		}
	} else {
		return YES;
	}
	return YES;
}

- (IBAction)showFBFriendPicker {
	// Setup the friend picker sub-view controller
	if (!self.friendPickerController) {
		self.friendPickerController = [[PF_FBFriendPickerViewController alloc] init];
		self.friendPickerController.title = @"Select some friends";
		self.friendPickerController.delegate = self;
	}
	
	[self.friendPickerController loadData];
	[self.friendPickerController clearSelection];

	// Show the FBFriendPicker.  Upon completion of showing this view, run the "completion" block of
	// code which shows the custom search bar for friends too.
	[self presentViewController:self.friendPickerController animated:YES completion:^(void){
		[self addSearchBarToFriendPickerView];
	}];
	
//	[self.navigationController pushViewController:self.friendPickerController animated:true];
	
//	[self presentModalViewController:self.friendPickerController animated:YES];
	
//	[self addChildViewController:self.friendPickerController];
//	[self.view addSubview:self.friendPickerController.view];
//	[self.friendPickerController updateView];
}

// Callback invoked when the user selects a friend in the FBFriendPicker.
- (void)friendPickerViewControllerSelectionDidChange:
(PF_FBFriendPickerViewController *)friendPicker
{
	NSLog(@"friendPickerViewControllerSelectionDidChange");
	// Note: Results are in friendPicker.selection
}

// Callback invoked when user hits "Cancel" when selecting FB Friends
- (void)facebookViewControllerCancelWasPressed:(id)sender {
	
	// Dismiss the FBFriendPicker
	[self dismissViewControllerAnimated:YES completion:NULL];
}

// Callback invoked whenever facebook data is dynamically loaded from the server periodically
- (void)friendPickerViewControllerDataDidChange:(PF_FBFriendPickerViewController *)friendPicker
{
	NSLog(@"friendPickerViewControllerDataDidChange");
}

// Called if an error occurs in the FBFriendPicker
- (void)friendPickerViewController:(PF_FBFriendPickerViewController *)friendPicker
                       handleError:(NSError *)error;
{
	NSLog(@"Error");
}

// Callback invoked when user hits "Done" when selecting FB Friends
- (void)facebookViewControllerDoneWasPressed:(id)sender {
	// Grab selected FB Friends and invite them.  We loop through each friend and issue an invite.
	//
	// Unfortunately due to recent Facebook API changes you need to perform one post at a time.
	// The automated/server-side way of inviting multiple friends doesn't work anymore since the
	// Graph API is deprecated
	//
	// Also there's no way to pre-populate the message box.
	//
	// One alternative is to automatically post on your wall (doesn't require a dialog box) and
	// @mention your friends, which will make stuff appear on their wall.  But not sure how
	// spammy this might feel.
	for (id<PF_FBGraphUser> user in self.friendPickerController.selection) {
		NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
												 @"http://www.ATallTale.com", @"link",
												 @"Come create a tall tale with me!", @"name",
												 @"A Tall Tale -- a fun iPhone game", @"caption",
												 @"Create fun stories together!", @"description",
												 user.id, @"to",
												 nil];
		
		// Create request for user's Facebook data
		NSString *requestPath = @"stream.publish";

		// Get the "facebook" object to perform the wall post
		
		// Method #1 (bad)
//		PF_Facebook *facebook = [[PF_Facebook alloc] initWithAppId:[[Constants data] objectForKey:@"fbAppId"] andDelegate:self];
		
		// Method #2 (better).  Currently requires user to relogin.  TODO: see:
		// https://parse.com/questions/how-do-you-make-a-facebook-dialog-request
		// http://stackoverflow.com/questions/12482351/how-to-get-share-dialog-box-with-parse-com-and-facebook-3-0-sdk
//		PF_Facebook *facebook = [PFFacebookUtils facebook];

		// Method #3 (temp fix)
		PF_FBSession *session = [PFFacebookUtils session];
		PF_Facebook *facebook = [[PF_Facebook alloc] initWithAppId:session.appID andDelegate:nil];
		facebook.accessToken = session.accessToken;
		facebook.expirationDate = session.expirationDate;
		
		// Post to wall.
		[facebook dialog:requestPath andParams:params andDelegate:self];
		
 // This code doesn't work as of 2/6/13 because of facebook changing their API
/*
		PF_FBRequest *request = [PF_FBRequest requestWithGraphPath:requestPath parameters:params HTTPMethod:@"POST"];
		[request startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
			if (!error) {
				NSLog(@"Post to Facebook successful!");
			}
			else if ([error.userInfo[PF_FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
				
				NSLog(@"OauthException: %@", error);
				
				// TODO: Logout, using something like [self logoutButtonTouchHandler:nil];
			} else {
				NSLog(@"Some other error: %@", error);
			}
		}];
*/
	}

	// Dismiss the FBFriendPicker
	[self dismissViewControllerAnimated:YES completion:NULL];
}


// Called when the dialog succeeds and is about to be dismissed.
- (void)dialogDidComplete:(PF_FBDialog *)dialog
{
	NSLog(@"dialogDidComplete!");
}

// Called when the dialog succeeds with a returning url.
- (void)dialogCompleteWithUrl:(NSURL *)url
{
	NSLog(@"dialogCompleteWithUrl!");
}

// Called when the dialog get canceled by the user.
- (void)dialogDidNotCompleteWithUrl:(NSURL *)url
{
	NSLog(@"dialogDidNotCompleteWithUrl!");
}

// Called when the dialog is cancelled and is about to be dismissed.
- (void)dialogDidNotComplete:(PF_FBDialog *)dialog
{
	NSLog(@"dialogDidNotComplete!");
}

// Called when dialog failed to load due to an error.
- (void)dialog:(PF_FBDialog*)dialog didFailWithError:(NSError *)error
{
	NSLog(@"dialog didFailWithError!");
}

////////////////////////////////////////////////////////
// END FBFriendPicker Stuff
////////////////////////////////////////////////////////

////////////////////////////////////////////////////////
// BEGIN AddressBookPicker Stuff
////////////////////////////////////////////////////////

- (IBAction)showAddressBookPicker
{
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	
	[self presentViewController:picker animated:YES completion:NULL];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}
	
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	// Make the people picker go away.  Important that this is NOT animated so that a pop-up modal
	// dialog box for sending an email or SMS doesn't interfere with this dialog box going away
	[self dismissViewControllerAnimated:NO completion:NULL];
	
	[self invitePerson:person];
	
	return NO;
}
	
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
shouldContinueAfterSelectingPerson:(ABRecordRef)person
property:(ABPropertyID)property
identifier:(ABMultiValueIdentifier)identifier
{
		return NO;
}

- (void)invitePerson:(ABRecordRef)person
{
	NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);

	// Get all phone numbers for contact
	ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
	
	// If we have no phone numbers, then get all phone numbers for linked contacts
	if (phoneNumbers == nil || ABMultiValueGetCount(phoneNumbers) == 0)
	{
		CFArrayRef linkedContacts = ABPersonCopyArrayOfAllLinkedPeople(person);
		phoneNumbers = ABMultiValueCreateMutable(kABPersonPhoneProperty);
		ABMultiValueRef linkedPhones;
		for (int i = 0; i < CFArrayGetCount(linkedContacts); i++)
		{
			ABRecordRef linkedContact = CFArrayGetValueAtIndex(linkedContacts, i);
			linkedPhones = ABRecordCopyValue(linkedContact, kABPersonPhoneProperty);
			if (linkedPhones != nil && ABMultiValueGetCount(linkedPhones) > 0)
			{
            for (int j = 0; j < ABMultiValueGetCount(linkedPhones); j++)
            {
					ABMultiValueAddValueAndLabel(phoneNumbers, ABMultiValueCopyValueAtIndex(linkedPhones, j), NULL, NULL);
            }
			}
		}
	}

	NSString* phone = nil;
	if (ABMultiValueGetCount(phoneNumbers) > 0) {
		phone = (__bridge_transfer NSString*)
		ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
	}
	
	NSString* email = nil;
	ABMultiValueRef emailAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);
	if (ABMultiValueGetCount(emailAddresses) > 0) {
		email = (__bridge_transfer NSString*)
		ABMultiValueCopyValueAtIndex(emailAddresses, 0);
	}
	
	if (phone != nil)
	{
		// Send SMS
		NSMutableArray * recipients = [[NSMutableArray alloc] init];
		[recipients addObject:phone];
		[self sendSMSToRecipients:recipients body:@"Let's create a tall tale together!  Download the game to play with me here: http://www.aTallTale.com"];
	}
	else if (email != nil)
	{
		// Send email
		[self sendEmailToRecipient:email subject:@"Let's create a Tall Tale together!" body:@"Let's create a tall tale together!  Download the game to play with me here: http://www.aTallTale.com"];
	}
	else
	{
		// TODO: Some sort of error since the user doesn't have an email / phone number
	}
}

////////////////////////////////////////////////////////
// END AddressBookPicker Stuff
////////////////////////////////////////////////////////

////////////////////////////////////////////////////////
// BEGIN Send SMS Stuff
////////////////////////////////////////////////////////

- (void)sendSMSToRecipients:(NSArray *)recipients body:(NSString *)body
{
	MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
	if([MFMessageComposeViewController canSendText])
	{
		controller.body = body;
		controller.recipients = recipients;
		controller.messageComposeDelegate = self;
		[self presentViewController:controller animated:YES completion:NULL];
	}
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
			break;
		case MessageComposeResultFailed:
			NSLog(@"Failed");
			break;
		case MessageComposeResultSent:
			NSLog(@"Send");
			break;
		default:
			break;
	}
	
	[self dismissViewControllerAnimated:YES completion:NULL];
}

////////////////////////////////////////////////////////
// END Send SMS Stuff
////////////////////////////////////////////////////////

////////////////////////////////////////////////////////
// BEGIN Send Email Stuff
////////////////////////////////////////////////////////

- (void)sendEmailToRecipient:(NSString*)recipient subject:(NSString*)subject body:(NSString*)body
{
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
		controller.mailComposeDelegate = self;
		[controller setToRecipients:[NSArray arrayWithObjects:recipient, nil]];
		[controller setSubject:subject];
		[controller setMessageBody:body isHTML:NO];
//		[self presentViewController:controller animated:YES completion:NULL];
		[self presentModalViewController:controller animated:YES];
	}
	else
	{
		// TODO: Some sort of error telling user they can't send email
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	switch (result) {
		case MFMailComposeResultCancelled:
			NSLog(@"Cancelled");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Failed");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Send");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Saved");
			break;
		default:
			break;
	}

	[self dismissViewControllerAnimated:YES completion:NULL];
}

////////////////////////////////////////////////////////
// END Send Email Stuff
////////////////////////////////////////////////////////

@end
