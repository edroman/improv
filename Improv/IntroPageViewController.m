//
//  IntroPageViewController.m
//  Improv
//
//  Created by Ed Roman on 1/27/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import "IntroPageViewController.h"
#import "ImageScrollView.h"
#import "LoginViewController.h"
#import "ImprovAppDelegate.h"
#import "IntroViewController.h"

@interface IntroPageViewController ()
{
	NSUInteger _pageIndex;
}
@end

@implementation IntroPageViewController

- (NSInteger)pageIndex
{
	return _pageIndex;
}

- (void) setIndex:(NSUInteger)index
{
	_pageIndex = index;
}

- (id)initWithPageIndex:(NSUInteger)index
{
	self = [super initWithNibName:nil bundle:nil];

	if (self) {
		[self setIndex:index];
		
		// Custom initialization
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
	[super loadView];
	
	ImageScrollView *view = self.view;
	view.index = _pageIndex;

/*
	ImageScrollView *scrollView = [[ImageScrollView alloc] init];
	scrollView.index = _pageIndex;
	scrollView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view = scrollView;

	if (_pageIndex == 2)
	{
		CGRect screenRect = [[UIScreen mainScreen] bounds];
		CGFloat screenWidth = screenRect.size.width;
		CGFloat screenHeight = screenRect.size.height;
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		button.frame = CGRectMake(screenWidth/2.0f - 25.0f, screenHeight/2.0f - 25.0f, 50.0f, 50.0f);
		button.tag = 101;
		[button setTitle:@"Begin" forState:UIControlStateNormal];
		[button addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
		
		[self.view addSubview:button];
	}
*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressedButton:(id)sender
{
//	UINavigationController *nav = self.navigationController;
//	UIViewController *vc =  [nav visibleViewController];
// [vc performSegueWithIdentifier:@"IntroToLoginSegue" sender:sender];

	// Get the nav controller
	// ImprovAppDelegate *del = (ImprovAppDelegate *)[UIApplication sharedApplication].delegate;
	// UINavigationController *nav = del.navController;
	
	// Use the nav controller's storyboard to instantiate the view controller so that we'll get its segues
	// Then present the new view controller -- use our parent since that's where the segue comes from
	// LoginViewController *myNewVC = [nav.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
	// [self presentViewController:myNewVC animated:YES completion:nil];

	// IntroViewController *vc = (IntroViewController*) [nav topViewController];
	// [vc performSegueWithIdentifier:@"IntroToLoginSegue" sender:sender];
	
	[self performSegueWithIdentifier:@"IntroToLoginSegue" sender:sender];
}

@end
