//
//  LobbyViewController.m
//  Improv
//
//  Created by Ed Roman on 12/30/12.
//  Copyright (c) 2012 Ghostfire Games. All rights reserved.
//

#import "LobbyViewController.h"
#import <Parse/Parse.h>

@interface LobbyViewController ()

// Child view controller(s)
@property (nonatomic, strong) UIViewController *tableVC;

@end

@implementation LobbyViewController

@synthesize tableVC = _tableVC;

-(void)awakeFromNib{
	// instantiate and assign the child view controller to a property to have direct reference to it in
	self.tableVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StoryTableViewController"];

	// ... if necessary, configure your child view controller ...
	
	// add your child view controller to children array
	[self addChildViewController:self.tableVC];
	
	[self.tableVC didMoveToParentViewController:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	// configure chld view controller view's frame
	self.tableVC.view.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);

	// add child's view to view hierarchy
	[self.view addSubview:self.tableVC.view];

	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;
 
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end