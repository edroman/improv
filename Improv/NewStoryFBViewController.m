//
//  NewStoryFBViewController.m
//  Improv
//
//  Created by Ed Roman on 12/30/12.
//  Copyright (c) 2012 Ghostfire Games. All rights reserved.
//
// TODO: List existing FB friends who have accounts on the main page, allowing users to start a new game
// with them, which is the path people take once they accept the FB request.  (post MVP) If someone is
// already a user, then skip this since you can start playing right away.
//
// TODO: Perform FB wall post on friend's wall once user clicks a row
//
// TODO (post-MVP): If performance is bad then only load X friends at a time or dynamically load images
//
// TODO (post-MVP): If the user is already a player, then don't do a FB request and instead start a new game.
// Perhaps do a perepareForSegue as in StoryTableViewController.m.
// We won't have 2 sections / prioritize users who are already playing since that hurts virality.
// Instead, just mark users somehow in the list as already playing.

#import "NewStoryFBViewController.h"
#import <Parse/Parse.h>

@interface NewStoryFBViewController ()

// Holds the friends retrieved from FB
@property (nonatomic, strong) NSMutableArray *friends;

@property (retain, nonatomic) PF_FBFriendPickerViewController *friendPickerController;

@end

@implementation NewStoryFBViewController

@synthesize friendPickerController = _friendPickerController;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// Allocate memory for our friend list
	if (!self.friends) self.friends = [[NSMutableArray alloc] init];
	

	if (!self.friendPickerController) {
		self.friendPickerController = [[PF_FBFriendPickerViewController alloc]
												 initWithNibName:nil bundle:nil];
		self.friendPickerController.title = @"Select friends";
	}
	
	[self.friendPickerController loadData];
	[self.navigationController pushViewController:self.friendPickerController
													 animated:true];
}

- (void)viewDidUnload {
	self.friendPickerController = nil;
	
	[super viewDidUnload];
}

- (IBAction)pickFriendsButtonClick:(id)sender {
	if (self.friendPickerController == nil) {
		// Create friend picker, and get data loaded into it.
		self.friendPickerController = [[PF_FBFriendPickerViewController alloc] init];
		self.friendPickerController.title = @"Pick Friends";
		self.friendPickerController.delegate = self;
	}
	
	[self.friendPickerController loadData];
	[self.friendPickerController clearSelection];
	
	[self presentViewController:self.friendPickerController animated:YES completion:NULL];
	// (iOS 4.0) [self presentModalViewController:self.friendPickerController animated:YES];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
	// we pick up the users from the selection
	// note that self.selection is a property inherited from our base class
	for (id<PF_FBGraphUser> user in self.friendPickerController.selection) {
		// TODO: Use user for stuff
	}
	
	[self inviteAndDismiss];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
	[self inviteAndDismiss];
}

- (void)inviteAndDismiss {
	// TODO: Invite, with parameters passed to this
	
	[self dismissModalViewControllerAnimated:YES];
}



/*

- (void)getFriendsResponse {
	// TODO: Use PF_FBFriendPickerViewController

	FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:@"me/friends" withGetVars:nil];// me/feed
	//parse our json
   SBJSON *parser = [[SBJSON alloc] init];
   NSDictionary *   facebook_response = [parser objectWithString:fb_graph_response.htmlResponse error:nil];
   //init array
	NSMutableArray * feed = (NSMutableArray *) [facebook_response objectForKey:@"data"];
	NSMutableArray *recentFriends = [[NSMutableArray alloc] init];
	
	//adding values to array
	for (NSDictionary *d in feed) {
		
		NSLog(@"see Dicitonary :%@",d );
		facebook   = [[Facebook alloc]initWithFacebookDictionary:d ];
		[recentFriends addObject:facebook];
		NSLog(@"Postsss :->>>%@",[facebook sender]);
		
		[facebook release];
	}
	
	friends = recentFriends;
	
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return _friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Find the right cell.  This string should correspond to the string set in the cell prototype
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	// TODO: Type cast this properly
	// NSObject *friend = _friends[indexPath.row];
	
	////////////////////////////////////
	// Set cell text
	////////////////////////////////////
	
	// TODO: cell.textLabel.text = ...

	////////////////////////////////////
	// Set cell image
	////////////////////////////////////

	// TODO: Set Image from array of images
	// cell.imageView.image = ...
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Navigation logic may go here. Create and push another view controller.
 // <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
 // ...
 // Pass the selected object to the new view controller.
 // [self.navigationController pushViewController:detailViewController animated:YES];
 
 
 // TODO: Fix
 NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
 @"http://www.ATallTale.com", @"link",
 @"Come create a tall tale with me!", @"name",
 @"A Tall Tale", @"caption",
 @"...tell stories with your friends!", @"description",
 nil];
 
 // Create request for user's Facebook data
 // TODO: Type cast this properly
 NSObject *friend = _friends[indexPath.row];
 NSString *requestPath = [NSString stringWithFormat:@"/%@/feed", friend.fbID];
 
 
 // Send request to Facebook
 PF_FBRequest *request = [PF_FBRequest requestWithGraphPath:requestPath parameters:params HTTPMethod:nil];
 [request startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
 if (!error) {
 NSLog(@"Post to Facebook successful!");
 }
 else if ([error.userInfo[PF_FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
 
 NSLog(@"The facebook session was invalidated");
 
 // TODO: Logout, using something like [self logoutButtonTouchHandler:nil];
 } else {
 NSLog(@"Some other error: %@", error);
 }
 }];
 
}
 
*/

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

@end
