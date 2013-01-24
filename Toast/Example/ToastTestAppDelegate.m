//
//  ToastTestAppDelegate.m
//  ToastTest
//
//  Copyright 2013 Charles Scalesse. All rights reserved.
//

#import "ToastTestAppDelegate.h"
#import "ToastTestViewController.h"

@implementation ToastTestAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[ToastTestViewController alloc] init] autorelease];
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