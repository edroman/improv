//
//  LeaderboardViewController.m
//  Improv
//
//  Created by Ed Roman on 1/8/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "ViewStoryViewController.h"
#import <Parse/Parse.h>

@interface LeaderboardViewController ()

// Holds the games retrieved from Parse
@property (nonatomic, strong) NSMutableArray *games;

@end

@implementation LeaderboardViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
	if (!self.games) self.games = [[NSMutableArray alloc] init];
	
	// Load all games
	PFQuery *query = [PFQuery queryWithClassName:@"Game"];

	query.limit = 10;
	[query orderByDescending:@"votes"];
	[query includeKey:@"creator"];
	[query includeKey:@"invitee"];
	[query includeKey:@"intro"];	
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
			// The find succeeded.
			NSLog(@"Successfully retrieved %d results.", objects.count);
			
			// Store results
			for (int i=0; i < objects.count; ++i) {
				[_games addObject:objects[i]];
			}
			
			// reload table data, forcing a new numberOfRowsInSection()
			[self.tableView reloadData];
		} else {
			// Log details of the failure
			NSLog(@"Error: %@ %@", error, [error userInfo]);
		}
	}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"LeaderboardToViewStorySegue"]) {
		ViewStoryViewController *nextVC = (ViewStoryViewController *)[segue destinationViewController];

		UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
		NSIndexPath *path = [self.tableView indexPathForCell:clickedCell];
		int index = path.row;
		nextVC.game = _games[index];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return _games.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// This string should correspond to the string set in the storyboard Table View Cell prototype
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	// Set cell text
	PFObject *game = _games[indexPath.row];
	
	UILabel *playerLabel = (UILabel *)[cell viewWithTag:100];
	PFUser *obj = [game objectForKey:@"creator"];
	NSString *str = [obj objectForKey:@"name"];
	PFUser *obj2 = [game objectForKey:@"invitee"];
	NSString *str2 = [obj2 objectForKey:@"name"];
	playerLabel.text = [NSString stringWithFormat:@"By %@and %@", str, str2];

	UILabel *storyLabel = (UILabel *)[cell viewWithTag:101];
	storyLabel.text = @"It was a dark and stormy night...";		 // TODO
	
	UILabel *voteLabel = (UILabel *)[cell viewWithTag:102];
	NSString *votes = [game objectForKey:@"votes"];
	voteLabel.text = [NSString stringWithFormat:@"%@ votes", votes];
	
	return cell;
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
