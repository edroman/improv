@class ImprovViewController;

@interface ImprovAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (nonatomic, strong) IBOutlet ImprovViewController *viewController;

@property (retain, nonatomic) UINavigationController *navController;

@end
