//
//  ToastTestAppDelegate.h
//  ToastTest
//
//  Copyright 2011 Charles Scalesse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ToastTestViewController;

@interface ToastTestAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ToastTestViewController *viewController;

@end
