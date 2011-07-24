//
//  ToastTestAppDelegate.m
//  ToastTest
//
//  Copyright 2011 Charles Scalesse. All rights reserved.
//

#import "ToastTestAppDelegate.h"
#import "ToastTestViewController.h"

@implementation ToastTestAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
    
}

- (void)dealloc {
    
    [_window release];
    [_viewController release];
    [super dealloc];
    
}

@end
