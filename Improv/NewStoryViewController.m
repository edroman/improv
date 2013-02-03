//
//  NewStoryViewController.m
//  Improv
//
//  Created by Ed Roman on 1/11/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import "NewStoryViewController.h"
#import <Parse/Parse.h>
#import "PlayStoryViewController.h"

@interface NewStoryViewController ()
// Holds the friends retrieved from FB
@property (nonatomic, strong) NSMutableArray *fbFriends;
@property (strong, nonatomic) PF_FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;
@end

@implementation NewStoryViewController

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

// Triggered when user clicks "random".
// Prepares for the transition to a new game, but beforeso, pairs user up with a random user.
//
// This could later be smarter about re-activing old users while
// balancing the experience for new users.  Could cycle via push notifications between users until
// someone responds, and then begin a game with that pair.
//
// TODO: need to have user be urged to accept push notifications somewhere.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

	if ([segue.identifier compare:@"RandomToPlayStorySegue"] == 0) {
		NSArray *results = 0;

		// TODO: Ask parse for a random user (not same as self).
		// The algorithm below works but it gets ALL users, so no good
		// See https://parse.com/questions/is-it-possible-to-query-for-a-random-object
		
		PFQuery *query;

		// Get a random partner
		PFUser *invitee;
		do {
			query = [PFUser query];
			results = [query findObjects];
			invitee = results[rand() % results.count];
		}
		while (invitee.objectId == [PFUser currentUser].objectId);

		// Get a random intro
		query = [PFQuery queryWithClassName:@"Intro"];
		results = [query findObjects];
		NSObject *intro = results[rand() % results.count];
		
		// Get a random story spine
		query = [PFQuery queryWithClassName:@"Spine"];
		results = [query findObjects];
		NSObject *spine = results[rand() % results.count];
	
		// Create an empty new game with the 2 players
		PFObject *game = [PFObject objectWithClassName:@"Game"];
		[game setObject:[NSNumber numberWithBool:false] forKey:@"completed"];
		[game setObject:[NSNumber numberWithInt:0] forKey:@"votes"];
		[game setObject:[NSNumber numberWithInt:1] forKey:@"turn"];
		[game setObject:[PFUser currentUser] forKey:@"creator"];
		[game setObject:invitee forKey:@"invitee"];
		[game setObject:intro forKey:@"intro"];
		[game setObject:spine forKey:@"spine"];
		[game setObject:[PFUser currentUser] forKey:@"currPlayer"];
		[game save];
		
		// Send the resulting new game to the PlayViewController
		PlayStoryViewController *controller = (PlayStoryViewController *)segue.destinationViewController;
		controller.game = game;
	}
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

// Callback invoked when user hits "Done" when selecting FB Friends
- (void)facebookViewControllerDoneWasPressed:(id)sender {
	// Grab selected FB Friends and invite them
	for (id<PF_FBGraphUser> user in self.friendPickerController.selection) {
		NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
												 @"http://www.ATallTale.com", @"link",
												 @"Come create a tall tale with me!", @"name",
												 @"A Tall Tale -- a fun iPhone game", @"caption",
												 @"Create fun stories together!", @"description",
//												 @"message", @"message",
												 nil];
		
		// Create request for user's Facebook data
		NSString *requestPath = [NSString stringWithFormat:@"/%@/feed", user.id];
		
		// Send request to Facebook
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
	}

	// Dismiss the FBFriendPicker
	[self dismissViewControllerAnimated:YES completion:NULL];
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
	[self invitePerson:person];
	[self dismissViewControllerAnimated:YES completion:NULL];
	
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
		
	NSString* phone = nil;
	ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
	if (ABMultiValueGetCount(phoneNumbers) > 0) {
		phone = (__bridge_transfer NSString*)
		ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
	} else {
		phone = @"[None]";
	}
	
	// TODO: Use Twilio or iPhone SMS to send invite
	// TODO: Invite via email if they don't have a phone number
}

////////////////////////////////////////////////////////
// END AddressBookPicker Stuff
////////////////////////////////////////////////////////

@end
