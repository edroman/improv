//
//  NewStoryViewController.m
//  Improv
//
//  Created by Ed Roman on 1/11/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import "NewStoryViewController.h"
#import <Parse/Parse.h>

@interface NewStoryViewController ()
	// Holds the friends retrieved from FB
	@property (nonatomic, strong) NSMutableArray *fbFriends;
	@property (strong, nonatomic) PF_FBFriendPickerViewController *friendPickerController;
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

	// TODO: remove
	return;
	
	if ([segue.identifier compare:@"RandomToPlayStorySegue"] == 0) {
		NSArray *results = 0;

		// TODO: Ask parse for a random user (not same as self)
		PFQuery *query;
		
		query = [PFUser query];
		[query whereKey:@"playerName" equalTo:@"Harvey Dent"];
		results = [query findObjects];
		PFUser *invitee = results[(rand() % results.count) - 1];

		// TODO: Get a random intro
		query = [PFQuery queryWithClassName:@"Intro"];
		results = [query findObjects];
		NSObject *intro = results[(rand() % results.count) - 1];
	
		// TODO: Create an empty new game with the 2 players
		PFObject *game = [PFObject objectWithClassName:@"Game"];
		[game setObject:false forKey:@"completed"];
		[game setObject:0 forKey:@"votes"];
		[game setObject:[PFUser currentUser] forKey:@"creator"];
		[game setObject:invitee forKey:@"invitee"];
		[game setObject:intro forKey:@"intro"];
		[game save];
	}
}

////////////////////////////////////////////////////////
// BEGIN FBFriendPicker Stuff
////////////////////////////////////////////////////////

@synthesize friendPickerController = _friendPickerController;

- (void)dealloc
{
	_friendPickerController.delegate = nil;
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
	
	[self presentViewController:self.friendPickerController animated:YES completion:nil];
	
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
		// TODO: Use user for stuff
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
