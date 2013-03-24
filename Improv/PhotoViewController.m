#import "PhotoViewController.h"
#import "ImageScrollView.h"
#import <AVFoundation/AVFoundation.h>

AVAudioPlayer *audioPlayer;
BOOL musicInitialized = FALSE;

@interface PhotoViewController ()
{
    NSUInteger _pageIndex;
}
@end

@implementation PhotoViewController

+ (PhotoViewController *)photoViewControllerForPageIndex:(NSUInteger)pageIndex
{
    if (pageIndex < [ImageScrollView imageCount])
    {
        return [[self alloc] initWithPageIndex:pageIndex];
    }
    return nil;
}

- (id)initWithPageIndex:(NSInteger)pageIndex
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _pageIndex = pageIndex;
    }
    return self;
}

- (NSInteger)pageIndex
{
    return _pageIndex;
}

- (void)loadView
{
    ImageScrollView *scrollView = [[ImageScrollView alloc] init];
    scrollView.index = _pageIndex;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = scrollView;

	////////////////////
	// Audio stuff
	////////////////////

	if (!musicInitialized)
	{
		musicInitialized = TRUE;
		NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Romance.mp3", [[NSBundle mainBundle] resourcePath]]];
		
		NSError *error;
		audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
		audioPlayer.numberOfLoops = -1;
		
		if (audioPlayer == nil) NSLog([error description]);
		else [audioPlayer play];
	}
}

// (this can also be defined in Info.plist via UISupportedInterfaceOrientations)
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
