//
//  AppDelegate.m
//  LogDemo
//

#import "AppDelegate.h"

#import "ViewController.h"

#import <KSRetainTracker/KSRetainTracker.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Condensed stack trace logger
    [KSRetainTracker addCondensedLogCallbacksForClass:[UIView class] callStackDepth:3];
    
    // Full stack trace logger
//    [KSRetainTracker addFullLogCallbacksForClass:[UIView class] callStackDepth:3];
    
    [KSRetainTracker setEnabled:YES];
    

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
