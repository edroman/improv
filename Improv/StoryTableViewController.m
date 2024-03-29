//
//  StoryTableViewController.m
//  Improv
//
//  Created by Ed Roman on 12/30/12.
//  Copyright (c) 2012 Ghostfire Games. All rights reserved.
//

#import "StoryTableViewController.h"
#import "ViewStoryViewController.h"
#import <Parse/Parse.h>
#import "PlayStoryViewController.h"
#import "InviteFriendsViewController.h"

@interface StoryTableViewController ()

// Holds the games retrieved from Parse
@property (nonatomic, strong) NSMutableArray *finishedGames;
@property (nonatomic, strong) NSMutableArray *myTurnGames;
@property (nonatomic, strong) NSMutableArray *theirTurnGames;

@end

@implementation StoryTableViewController

// Performs initialization.  Currently not being called (not sure why)
- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) {
		// init stuff goes here
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;

	///////////////////////////////////
	// Setup "Pull to Refresh" control
	///////////////////////////////////

	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	refreshControl.tintColor = [UIColor magentaColor];
	refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
	[refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
	self.refreshControl = refreshControl;
	
	///////////////////////////////////
	// Load all games
	///////////////////////////////////
	
	// Allocate memory for our game arrays
	if (!self.finishedGames) self.finishedGames = [[NSMutableArray alloc] init];
	if (!self.myTurnGames) self.myTurnGames = [[NSMutableArray alloc] init];
	if (!self.theirTurnGames) self.theirTurnGames = [[NSMutableArray alloc] init];
}

// View becomes active - refresh
-(void)viewDidAppear:(BOOL)animated {
	// Refresh view
	[self refreshView:self.refreshControl];

	// Register for suspend/resume msgs
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector(onResume:)
																name:UIApplicationDidBecomeActiveNotification object:nil];
}

// View becomes inactive
-(void)viewDidDisappear:(BOOL)animated {
	// Stop listening to suspend/resume events
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Suspend/resume
-(void)onResume:(NSNotification *)notification {
	[self refreshView:self.refreshControl];
}

// Pull to refresh functionality
-(void)refreshView:(UIRefreshControl *)refresh {
	refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing games..."];

	// custom refresh logic would be placed here...
	[self loadGames];
}

// We call this when we're done refreshing (since refreshing is asynchronous, we call this manually)
-(void)endRefreshing {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"MMM d, h:mm a"];
	NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
									 [formatter stringFromDate:[NSDate date]]];
	self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
	[self.refreshControl endRefreshing];
}

// Helper method, called when we first load the view, and when we refresh
-(void)loadGames {
	// Clear out existing data from previous loads
	[_finishedGames removeAllObjects];
	[_myTurnGames removeAllObjects];
	[_theirTurnGames removeAllObjects];
	
	// Find all games I created
	PFQuery *query1 = [PFQuery queryWithClassName:@"Game"];
	[query1 includeKey:@"creator"];
	[query1 includeKey:@"invitee"];
	[query1 includeKey:@"currPlayer"];
	[query1 includeKey:@"intro"];
	[query1 includeKey:@"spine"];
	[query1 whereKey:@"creator" equalTo:[PFUser currentUser]];
	
	[query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
			// The find succeeded.
			NSLog(@"Successfully retrieved %d stories.", objects.count);
			
			// Store results
			for (int i=0; i < objects.count; ++i) {
				if ([[objects[i] objectForKey:@"completed"] boolValue] == true) {
					[_finishedGames addObject:objects[i]];
				}
				else {
					PFUser *currPlayer = [objects[i] objectForKey:@"currPlayer"];
					if ([currPlayer.objectId isEqualToString:[PFUser currentUser].objectId])
					{
						[_myTurnGames addObject:objects[i]];
					}
					else
					{
						[_theirTurnGames addObject:objects[i]];
					}
				}
			}
			
			// Find all games I was invited to
			PFQuery *query2 = [PFQuery queryWithClassName:@"Game"];
			[query2 includeKey:@"creator"];
			[query2 includeKey:@"invitee"];
			[query2 includeKey:@"currPlayer"];
			[query2 includeKey:@"intro"];
			[query2 includeKey:@"spine"];
			[query2 whereKey:@"invitee" equalTo:[PFUser currentUser]];
			
			[query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
				if (!error) {
					// The find succeeded.
					NSLog(@"Successfully retrieved %d stories.", objects.count);
					
					// Store results
					for (int i=0; i < objects.count; ++i) {
						if ([[objects[i] objectForKey:@"completed"] boolValue] == true) {
							[_finishedGames addObject:objects[i]];
						}
						else {
							PFUser *currPlayer = [objects[i] objectForKey:@"currPlayer"];
							if ([currPlayer.objectId isEqualToString:[PFUser currentUser].objectId])
							{
								[_myTurnGames addObject:objects[i]];
							}
							else
							{
								[_theirTurnGames addObject:objects[i]];
							}
						}
					}
					
					// reload table data, forcing a new numberOfRowsInSection()
					[self.tableView reloadData];
					
					// Stop displaying "refreshing"
					[self endRefreshing];
				} else {
					// Log details of the failure
					NSLog(@"Error: %@ %@", error, [error userInfo]);
				}
			}];
		} else {
			// Log details of the failure
			NSLog(@"Error: %@ %@", error, [error userInfo]);
		}
	}];	
}

- (PFObject *)getGameForButtonClicked:(id)sender {
	// Figure out which game we're on
	UIButton *button = (UIButton *)sender;
	UITableViewCell *cell = [[button superview] superview];
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	//		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

	NSMutableArray *games = [self sectionToGamesArray:indexPath.section];
	PFObject *game = games[indexPath.row];
	return game;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"StoryTableToViewStorySegue"]) {
		// Figure out which game we're on
		PFObject *game = [self getGameForButtonClicked:sender];
		
		// Pass story data to the next view controller
		ViewStoryViewController *dest = (ViewStoryViewController *)segue.destinationViewController;
		dest.game = game;
	}
	else if ([[segue identifier] isEqualToString:@"StoryTableToPlayStorySegue"]) {
		// Figure out which game we're on
		PFObject *game = [self getGameForButtonClicked:sender];
		
		// Pass story data to the next view controller
		PlayStoryViewController *dest = (PlayStoryViewController *)segue.destinationViewController;
		dest.game = game;
	}
	else if ([[segue identifier] isEqualToString:@"StoryTableToInviteFriendsSegue"]) {
		// Figure out which game we're on
		PFObject *game = [self getGameForButtonClicked:sender];

		// Pass story data to the next view controller
		InviteFriendsViewController *dest = (InviteFriendsViewController *)segue.destinationViewController;
		dest.game = game;
	}
}

- (IBAction)playButtonPressed:(id)sender {
	// Get the partner for this game
	PFObject *game = [self getGameForButtonClicked:sender];
	PFUser *currPlayer = [game objectForKey:@"currPlayer"];
	PFObject *invitee = [game objectForKey:@"invitee"];
	
	// If it's our turn, then it's a "Play" button, so perform the segue
	if ([[PFUser currentUser].objectId isEqualToString:currPlayer.objectId]) {
		// Segue to invite friends if we don't have a partner
		if (invitee.objectId == nil)
		{
			[self performSegueWithIdentifier:@"StoryTableToInviteFriendsSegue" sender:sender];
		}
		// Otherwise segue to play the game
		else
		{
			[self performSegueWithIdentifier:@"StoryTableToPlayStorySegue" sender:sender];
		}
	}
	// Otherwise it's not our turn and it's a "Nudge" button, so send a push notification instead
	else
	{
		// Find devices (called "installations" in parse) associated with our partner
		PFQuery *userQuery = [PFUser query];
		[userQuery whereKey:@"objectId" equalTo:currPlayer.objectId];
		PFQuery *pushQuery = [PFInstallation query];
		[pushQuery whereKey:@"owner" matchesQuery:userQuery];
		
		// Send push notification to query
		PFPush *push = [[PFPush alloc] init];
		[push setQuery:pushQuery]; // Set our Installation query
		[push setMessage:[NSString stringWithFormat:@"Hi %@!  This is %@.  I'd love to finish up this game of A Tall Tale with you.  It's your turn!",
								[[PFUser currentUser] objectForKey:@"first_name"],
								[currPlayer objectForKey:@"first_name"]]];
		[push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			if (succeeded) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nudge Sent!"
																				message:@"A notification has been successfully sent!"
																			  delegate:nil
																  cancelButtonTitle:@"OK"
																  otherButtonTitles:nil];
				[alert show];
				NSLog(@"Sent push notification!");
			}
			else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nudge Error!"
																				message:[NSString stringWithFormat:@"Error sending a notification! %@", error]
																			  delegate:nil
																  cancelButtonTitle:@"OK"
																  otherButtonTitles:nil];
				[alert show];
				NSLog(@"Error sending push: %@", error);
			}
		}];
	}
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
	int numSections = 0;
	if (self.finishedGames.count > 0) ++numSections;
	if (self.myTurnGames.count > 0) ++numSections;
	if (self.theirTurnGames.count > 0) ++numSections;
	return numSections;
}

// Transforms a section number into the corresponding array of games.  The section number may not
// always map to the same array since we don't include sections for empty game arrays.
-(NSMutableArray *)sectionToGamesArray:(NSInteger)section
{
	if (section == 0)
	{
		if (_myTurnGames.count > 0) return _myTurnGames;
		else if (_theirTurnGames.count > 0) return _theirTurnGames;
		else return _finishedGames;
	}
	else if (section == 1)
	{
		if (_myTurnGames.count > 0)
		{
			if (_theirTurnGames.count > 0) return _theirTurnGames;
			else if (_finishedGames.count > 0) return _finishedGames;
			else
			{
				// TODO: ERROR
				return 0;
			}
		}
		else return _finishedGames;
	}
	else return _finishedGames;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	NSMutableArray *games = [self sectionToGamesArray:section];
	return games.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Get the game array for this section
	NSMutableArray *games = [self sectionToGamesArray:indexPath.section];
	
	// This string should correspond to the string set in the storyboard Table View Cell prototype
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	///////////////////////
	// Populate cell
	///////////////////////

	// Error check
	if (indexPath.row >= games.count)
	{
		NSLog(@"Warning: cellForRowAtIndexPath called with an invalid range");
		return cell;
	}
	
	PFObject *game = games[indexPath.row];
	
	// Partner name
	UILabel *playerLabel = (UILabel *)[cell viewWithTag:100];
	PFUser *creator = [game objectForKey:@"creator"];
	PFUser *invitee = [game objectForKey:@"invitee"];
	PFUser *partner = ([[PFUser currentUser].objectId isEqualToString:creator.objectId]) ? invitee : creator;
	NSString *str = [partner objectForKey:@"name"];
	if (str == NULL) playerLabel.text = @"No partner chosen yet";
	else playerLabel.text = [NSString stringWithFormat:@"%@%@", @"Game with ", str];

	// Intro
	UILabel *storyLabel = (UILabel *)[cell viewWithTag:101];
	storyLabel.text = [[game objectForKey:@"intro"] objectForKey:@"value"];
	
	// Display "Play" for games where it's my turn, "Nudge" for games where it's not my turn,
	// and hide button otherwise
	UIButton *playButton = (UIButton *)[cell viewWithTag:102];
	if (games == _myTurnGames) [playButton setTitle:@"Play" forState:UIControlStateNormal];
	else if (games == _theirTurnGames) [playButton setTitle:@"Nudge" forState:UIControlStateNormal];
	else playButton.hidden = YES;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Get the game array for this section
	NSMutableArray *games = [self sectionToGamesArray:indexPath.section];
	
	// Swipable DELETE button for games
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		// Remove turns via Parse
		PFQuery *query = [PFQuery queryWithClassName:@"Turn"];
		[query whereKey:@"Game" equalTo:games[indexPath.row]];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			for (int i=0; i < objects.count; ++i)
			{
				PFObject *turn = objects[i];
				[turn deleteInBackground];
			}
		}];
		
		// Remove game via Parse
		[games[indexPath.row] deleteInBackground];

		// Remove game from array
		[games removeObjectAtIndex:indexPath.row];
		
		// Remove game from UI
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	// Get the game array for this section
	NSMutableArray *games = [self sectionToGamesArray:section];

	if (games == _myTurnGames) return @"Current Games - My Turn";
	else if(games == _theirTurnGames) return @"Current Games - Their Turn";
	else return @"Completed Games";
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
	 // ...
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 */
}

@end
