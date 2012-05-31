//
//  ToastTestViewController.m
//  ToastTest
//
//  Copyright 2011 Charles Scalesse. All rights reserved.
//

#import "ToastTestViewController.h"
#import "Toast+UIView.h"

@implementation ToastTestViewController

@synthesize yellowView = _yellowView;
@synthesize activityButton = _activityButton;

#pragma mark - IBActions

-(IBAction)buttonPressed:(id)sender {
    
    switch ([sender tag]) {
            
        case 0: {
            // Make toast
            [self.view makeToast:@"This is a piece of toast."];
            break;
        }
            
        case 1: {
            // Make toast with a title
            [self.view makeToast:@"This is a piece of toast with a title." 
                        duration:3.0
                        position:@"top"
                           title:@"Toast Title"];
            
            break;
        }
            
        case 2: {
            // Make toast with an image
            [self.view makeToast:@"This is a piece of toast with an image." 
                        duration:3.0
                        position:@"center"
                           image:[UIImage imageNamed:@"toast.png"]];
            break;
        }
            
        case 3: {
            // Make toast with an image & title
            [self.view makeToast:@"This is a piece of toast with a title & image"
                        duration:3.0
                        position:@"bottom"
                           title:@"Toast Title"
                           image:[UIImage imageNamed:@"toast.png"]];
            break;
        }
        
        case 4: {
            // Show a custom view as toast
            UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 400)];
            [customView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)]; // autoresizing masks are respected on custom views
            [customView setBackgroundColor:[UIColor orangeColor]];
            
            [self.view showToast:customView
                        duration:2.0
                        position:@"center"];
            
            [customView release];
            break;
        }
            
        case 5: {
            // Show an imageView as toast, on center at point (110,110)
            UIImageView *toastView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toast.png"]];
            
            [self.view showToast:toastView 
                        duration:2.0
                        position:[NSValue valueWithCGPoint:CGPointMake(110, 110)]]; // wrap CGPoint in an NSValue object
                        
            [toastView release];
            break;
        }
            
        case 6: {
            // Make toast in a subview
            [_yellowView makeToast:@"This is a piece of toast in the center of the yellow subview."
                          duration:2.0
                          position:@"center"];
            break;
        }
            
        case 7: {
            if (!isShowingActivity) {
                [_activityButton setTitle:@"Hide Activity" forState:UIControlStateNormal];
                [self.view makeToastActivity];
            } else {
                [_activityButton setTitle:@"Show Activity" forState:UIControlStateNormal];
                [self.view hideToastActivity];
            }
            isShowingActivity = !isShowingActivity;
            break;
        }
            
        default:break;
            
    }
    
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    _yellowView = nil;
    _activityButton = nil;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_yellowView release], _yellowView = nil;
    [_activityButton release], _activityButton = nil;
    [super dealloc];
}

@end
