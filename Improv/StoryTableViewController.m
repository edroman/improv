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

@interface StoryTableViewController ()

// Holds the games retrieved from Parse
@property (nonatomic, strong) NSMutableArray *finishedGames;
@property (nonatomic, strong) NSMutableArray *unfinishedGames;

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
	
	// Allocate memory for our game arrays
	if (!self.finishedGames) self.finishedGames = [[NSMutableArray alloc] init];
	if (!self.unfinishedGames) self.unfinishedGames = [[NSMutableArray alloc] init];
	
	///////////////////////////////////
	// Load all games
	///////////////////////////////////

	// Find all games I created
	PFQuery *query1 = [PFQuery queryWithClassName:@"Game"];
	[query1 includeKey:@"creator"];
	[query1 includeKey:@"invitee"];
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
					[_unfinishedGames addObject:objects[i]];
				}
			}

			// Find all games I was invited to
			PFQuery *query2 = [PFQuery queryWithClassName:@"Game"];
			[query2 includeKey:@"creator"];
			[query2 includeKey:@"invitee"];
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
							[_unfinishedGames addObject:objects[i]];
						}
					}
					
					// reload table data, forcing a new numberOfRowsInSection()
					[self.tableView reloadData];
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
	NSMutableArray *games = (indexPath.section == 0 ? _unfinishedGames : _finishedGames);
	PFObject *game = games[indexPath.row];
	return game;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
	if ([identifier isEqualToString:@"StoryTableToPlayStorySegue"]) {
		// TODO: If it's not our turn, then send a push notification and return FALSE
		// else return TRUE
		PFObject *game = [self getGameForButtonClicked:sender];
		PFUser *currPlayer = [game objectForKey:@"currPlayer"];
		if ([[PFUser currentUser].objectId isEqualToString:currPlayer.objectId]) {
			return TRUE;
		}
		return FALSE;
	}
	else {
		return TRUE;
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"StoryTableToViewStorySegue"]) {
		ViewStoryViewController *nextVC = (ViewStoryViewController *)[segue destinationViewController];

		PFObject *game = [self getGameForButtonClicked:sender];

		nextVC.game = game;
	}
	else if ([[segue identifier] isEqualToString:@"StoryTableToPlayStorySegue"]) {
		// Figure out which game we're on
		PFObject *game = [self getGameForButtonClicked:sender];
		
		// Pass story data to the PlayStoryViewController
		PlayStoryViewController *controller = (PlayStoryViewController *)segue.destinationViewController;
		controller.game = game;
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
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Determine if we're referencing finished or unfinished game data
	NSMutableArray *games = (section == 0 ? _unfinishedGames : _finishedGames);
	
	// Return the number of rows in the section.
	return games.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Determine if we're referencing finished or unfinished game data
	NSMutableArray *games = (indexPath.section == 0 ? _unfinishedGames : _finishedGames);
	
	// This string should correspond to the string set in the storyboard Table View Cell prototype
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	///////////////////////
	// Populate cell
	///////////////////////

	PFObject *game = games[indexPath.row];
	
	// Partner name
	UILabel *playerLabel = (UILabel *)[cell viewWithTag:100];
	PFUser *creator = [game objectForKey:@"creator"];
	PFUser *invitee = [game objectForKey:@"invitee"];
	PFUser *partner = ([[PFUser currentUser].objectId isEqualToString:creator.objectId]) ? invitee : creator;
	NSString *str = [partner objectForKey:@"name"];
	playerLabel.text = [NSString stringWithFormat:@"%@%@", @"Game with ", str];

	// Intro
	UILabel *storyLabel = (UILabel *)[cell viewWithTag:101];
	storyLabel.text = [[game objectForKey:@"intro"] objectForKey:@"value"];
	
	// "Play" or "Nudge" button
	PFUser *currPlayer = [game objectForKey:@"currPlayer"];
	UIButton *playButton = (UIButton *)[cell viewWithTag:102];
	if (![[PFUser currentUser].objectId isEqualToString:currPlayer.objectId])
	{
		[playButton setTitle:@"Nudge" forState:UIControlStateNormal];
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Determine if we're referencing finished or unfinished game data
	NSMutableArray *games = (indexPath.section == 0 ? _unfinishedGames : _finishedGames);
	
	// Swipable DELETE button for games
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
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
	if(section == 0) return @"Current Games";
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
