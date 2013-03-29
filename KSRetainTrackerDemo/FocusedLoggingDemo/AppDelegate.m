//
//  AppDelegate.m
//  FocusedLoggingDemo
//

#import "AppDelegate.h"

#import "ViewController.h"
#import <KSRetainTracker/KSRetainTracker.h>

// Make a "fake" subclass so we track only the one we are interested in.
SYNTHESIZE_IDENTICAL_SUBCLASS(MyView, UIView)

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (void) enableWideLogging
{
    [KSRetainTracker addCondensedLogCallbacksForClass:[UIView class] callStackDepth:3];
    [KSRetainTracker setEnabled:YES];
    
    // Example
    [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void) enableFocusedLogging
{
    [KSRetainTracker addCondensedLogCallbacksForClass:[MyView class] callStackDepth:3];
    [KSRetainTracker setEnabled:YES];
    
    // Example
    [[[MyView alloc] initWithFrame:CGRectZero] autorelease];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self enableWideLogging];
//    [self enableFocusedLogging];

    #pragma unused(application)
    #pragma unused(launchOptions)
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
