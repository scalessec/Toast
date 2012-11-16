//
//  ToastTestViewController.h
//  ToastTest
//
//  Copyright 2012 Charles Scalesse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToastTestViewController : UIViewController {
    
    BOOL isShowingActivity;
}

@property (nonatomic, retain) IBOutlet UIButton *activityButton;

-(IBAction)buttonPressed:(id)sender;

@end
