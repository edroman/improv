#import "IntroViewController.h"
#import "IntroPageViewController.h"
#import "ImageScrollView.h"
#import "LoginViewcontroller.h"
#import "ImprovAppDelegate.h"

@interface IntroViewController ()
@end

@implementation IntroViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Create the first page's view controller
	IntroPageViewController *pageZero = [self getController:0];
	
	// Set us to point to that
/*
	[self setViewControllers:@[pageZero]
						direction:UIPageViewControllerNavigationDirectionForward
						 animated:NO
					  completion:NULL];
*/
	
	// add child view controller to children array
	[self addChildViewController:pageZero];
	
	// Signal the child content view controller that it has been added to the container view controller
	[pageZero didMoveToParentViewController:self];

	// configure chld view controller view's frame
	pageZero.view.frame=CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
	
	// add child's view to view hierarchy
	[self.view addSubview:pageZero.view];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	return [self setup];
}

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	return [self setup];
}
*/

// Initialization
- (id) setup
{
	id _id = [super init];
	
	self.dataSource = self;
	self.delegate = self;

	return _id;
}

// Required method of UIPageViewDataSource -- gets the previous view controller
- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(IntroPageViewController *)vc
{
	NSUInteger index = vc.pageIndex;
	return [self getController:(index - 1)];
}

// Required method of UIPageViewDataSource -- gets the next view controller
- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(IntroPageViewController *)vc
{
	NSUInteger index = vc.pageIndex;
	return [self getController:(index + 1)];
}

// Finds a IntroPageViewController, creating one if needed, for the corresponding page
- (IntroPageViewController *)getController:(NSUInteger)pageIndex
{
	if (pageIndex < [ImageScrollView imageCount])
	{
		// return [[IntroPageViewController alloc] initWithPageIndex:pageIndex];
//		ImprovAppDelegate *del = (ImprovAppDelegate *)[UIApplication sharedApplication].delegate;
//		UINavigationController *nav = (UINavigationController*) del.window.rootViewController;
		IntroPageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroPageViewController"];
		[vc setIndex:pageIndex];
		return vc;
	}
	return nil;
}

// (this can also be defined in Info.plist via UISupportedInterfaceOrientations)
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
