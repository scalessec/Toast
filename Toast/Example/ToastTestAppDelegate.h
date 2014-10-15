//
//  ToastTestAppDelegate.h
//  ToastTest
//
//  Copyright 2014 Charles Scalesse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ToastTestViewController;

@interface ToastTestAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) ToastTestViewController *viewController;

@end