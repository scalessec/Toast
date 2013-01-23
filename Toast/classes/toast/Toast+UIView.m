//
//  Toast+UIView.m
//  Toast
//  Version 2.0
//
//  Copyright 2013 Charles Scalesse.
//

#import "Toast+UIView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

/*
 *  CONFIGURE THESE VALUES TO ADJUST LOOK & FEEL,
 *  DISPLAY DURATION, ETC.
 */

// appearance
static const CGFloat CSToastMaxWidth            = 0.8;      // 80% of parent view width
static const CGFloat CSToastMaxHeight           = 0.8;      // 80% of parent view height
static const CGFloat CSToastHorizontalPadding   = 10.0;
static const CGFloat CSToastVerticalPadding     = 10.0;
static const CGFloat CSToastCornerRadius        = 10.0;
static const CGFloat CSToastOpacity             = 0.8;
static const CGFloat CSToastFontSize            = 16.0;
static const CGFloat CSToastMaxTitleLines       = 0;
static const CGFloat CSToastMaxMessageLines     = 0;
static const CGFloat CSToastFadeDuration        = 0.2;
static const BOOL    CSToastDisplayShadow       = YES;

// display duration and length
static const CGFloat CSToastDefaultLength       = 3.0;
static const NSString * CSToastDefaultPosition  = @"bottom";

// image size
static const CGFloat CSToastImageWidth          = 80.0;
static const CGFloat CSToastImageHeight         = 80.0;

// activity
static const CGFloat CSToastActivityWidth       = 100.0;
static const CGFloat CSToastActivityHeight      = 100.0;
static const NSString * CSToastActivityDefaultPosition = @"center";

// tags & keys
static const CGFloat CSToastActivityTag         = 91325;
static const NSString * kDurationKey            = @"CSToastDurationKey";


@interface UIView (ToastPrivate)

- (CGPoint)getPositionFor:(id)position toast:(UIView *)toast;
- (UIView *)viewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image;

@end


@implementation UIView (Toast)

#pragma mark - Toast Methods

- (void)makeToast:(NSString *)message {
    [self makeToast:message duration:CSToastDefaultLength position:CSToastDefaultPosition];
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position {
    UIView *toast = [self viewForMessage:message title:nil image:nil];
    [self showToast:toast duration:interval position:position];  
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position title:(NSString *)title {
    UIView *toast = [self viewForMessage:message title:title image:nil];
    [self showToast:toast duration:interval position:position];  
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position image:(UIImage *)image {
    UIView *toast = [self viewForMessage:message title:nil image:image];
    [self showToast:toast duration:interval position:position];  
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval  position:(id)position title:(NSString *)title image:(UIImage *)image {
    UIView *toast = [self viewForMessage:message title:title image:image];
    [self showToast:toast duration:interval position:position];  
}

- (void)showToast:(UIView *)toast {
    [self showToast:toast duration:CSToastDefaultLength position:CSToastDefaultPosition];
}

- (void)showToast:(UIView *)toast duration:(CGFloat)interval position:(id)point {
    // Display a view for a given duration & position.

    CGPoint toastPoint = [self getPositionFor:point toast:toast];
    
    // use an associative reference to associate the toast view with the display interval
    objc_setAssociatedObject (toast, &kDurationKey, [NSNumber numberWithFloat:interval], OBJC_ASSOCIATION_RETAIN);
    
    toast.center = toastPoint;
    toast.alpha = 0.0;
    [self addSubview:toast];
    
    [UIView beginAnimations:@"fade_in" context:toast];
    [UIView setAnimationDuration:CSToastFadeDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    toast.alpha = 1.0;
    [UIView commitAnimations];
    
}

#pragma mark - Toast Activity Methods

- (void)makeToastActivity {
    [self makeToastActivity:CSToastActivityDefaultPosition];
}

- (void)makeToastActivity:(id)position {
    // prevent more than one activity view
    UIView *existingToast = [self viewWithTag:CSToastActivityTag];
    if (existingToast != nil) {
        [existingToast removeFromSuperview];
    }
    
    UIView *activityContainer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, CSToastActivityWidth, CSToastActivityHeight)] autorelease];
    [activityContainer setCenter:[self getPositionFor:position toast:activityContainer]];
    [activityContainer setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:CSToastOpacity]];
    [activityContainer setAlpha:0.0];
    [activityContainer setTag:CSToastActivityTag];
    [activityContainer setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityContainer.layer setCornerRadius:CSToastCornerRadius];
    if (CSToastDisplayShadow) {
        [activityContainer.layer setShadowColor:[UIColor blackColor].CGColor];
        [activityContainer.layer setShadowOpacity:0.8];
        [activityContainer.layer setShadowRadius:6.0];
        [activityContainer.layer setShadowOffset:CGSizeMake(4.0, 4.0)];
    }
    
    UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    [activityView setCenter:CGPointMake(activityContainer.bounds.size.width / 2, activityContainer.bounds.size.height / 2)];
    [activityContainer addSubview:activityView];
    [activityView startAnimating];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:CSToastFadeDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [activityContainer setAlpha:1.0];
    [UIView commitAnimations];
    
    [self addSubview:activityContainer];
}

- (void)hideToastActivity {
    UIView *existingToast = [self viewWithTag:CSToastActivityTag];
    if (existingToast != nil) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:CSToastFadeDuration];
        [UIView setAnimationDelegate:existingToast];
        [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [existingToast setAlpha:0.0];
        [UIView commitAnimations];
    }
}

#pragma mark - Animation Delegate Method

- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
    UIView *toast = (UIView *)context;

    // retrieve the display interval associated with the view
    CGFloat interval = [(NSNumber *)objc_getAssociatedObject(toast, &kDurationKey) floatValue];
    
    if([animationID isEqualToString:@"fade_in"]) {
        
        [UIView beginAnimations:@"fade_out" context:toast];
        [UIView setAnimationDelay:interval];
        [UIView setAnimationDuration:CSToastFadeDuration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [toast setAlpha:0.0];
        [UIView commitAnimations];
        
    } else if ([animationID isEqualToString:@"fade_out"]) {
        
        [toast removeFromSuperview];
        
    }
    
}

#pragma mark - Private Methods

- (CGPoint)getPositionFor:(id)point toast:(UIView *)toast {
    // Convert string literals @"top", @"bottom", @"center", or any point wrapped in an
    // NSValue object into a CGPoint                                            

    if([point isKindOfClass:[NSString class]]) {
        
        if( [point caseInsensitiveCompare:@"top"] == NSOrderedSame ) {
            return CGPointMake(self.bounds.size.width/2, (toast.frame.size.height / 2) + CSToastVerticalPadding);
        } else if( [point caseInsensitiveCompare:@"bottom"] == NSOrderedSame ) {
            return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height - (toast.frame.size.height / 2)) - CSToastVerticalPadding);
        } else if( [point caseInsensitiveCompare:@"center"] == NSOrderedSame ) {
            return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        }
        
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }
    
    NSLog(@"Error: Invalid position for toast.");
    return [self getPositionFor:CSToastDefaultPosition toast:toast];
}

- (UIView *)viewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image {
    // sanity
    if((message == nil) && (title == nil) && (image == nil)) return nil;

    // Dynamically build a toast view with any combination of message, title, & image.
    UILabel *messageLabel = nil;
    UILabel *titleLabel = nil;
    UIImageView *imageView = nil;
    
    // create the parent view
    UIView *wrapperView = [[[UIView alloc] init] autorelease];
    [wrapperView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [wrapperView.layer setCornerRadius:CSToastCornerRadius];
    if (CSToastDisplayShadow) {
        [wrapperView.layer setShadowColor:[UIColor blackColor].CGColor];
        [wrapperView.layer setShadowOpacity:0.8];
        [wrapperView.layer setShadowRadius:6.0];
        [wrapperView.layer setShadowOffset:CGSizeMake(4.0, 4.0)];
    }

    [wrapperView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:CSToastOpacity]];
    
    if(image != nil) {
        imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setFrame:CGRectMake(CSToastHorizontalPadding, CSToastVerticalPadding, CSToastImageWidth, CSToastImageHeight)];
    }
    
    CGFloat imageWidth, imageHeight, imageLeft;
    
    // the imageView frame values will be used to size & position the other views
    if(imageView != nil) {
        imageWidth = imageView.bounds.size.width;
        imageHeight = imageView.bounds.size.height;
        imageLeft = CSToastHorizontalPadding;
    } else {
        imageWidth = imageHeight = imageLeft = 0.0;
    }
    
    if (title != nil) {
        titleLabel = [[[UILabel alloc] init] autorelease];
        [titleLabel setNumberOfLines:CSToastMaxTitleLines];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:CSToastFontSize]];
        [titleLabel setTextAlignment:UITextAlignmentLeft];
        [titleLabel setLineBreakMode:UILineBreakModeWordWrap];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setAlpha:1.0];
        [titleLabel setText:title];
        
        // size the title label according to the length of the text
        CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * CSToastMaxWidth) - imageWidth, self.bounds.size.height * CSToastMaxHeight);
        CGSize expectedSizeTitle = [title sizeWithFont:titleLabel.font constrainedToSize:maxSizeTitle lineBreakMode:titleLabel.lineBreakMode]; 
        [titleLabel setFrame:CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height)];
    }
    
    if (message != nil) {
        messageLabel = [[[UILabel alloc] init] autorelease];
        [messageLabel setNumberOfLines:CSToastMaxMessageLines];
        [messageLabel setFont:[UIFont systemFontOfSize:CSToastFontSize]];
        [messageLabel setLineBreakMode:UILineBreakModeWordWrap];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setAlpha:1.0];
        [messageLabel setText:message];
        
        // size the message label according to the length of the text
        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * CSToastMaxWidth) - imageWidth, self.bounds.size.height * CSToastMaxHeight);
        CGSize expectedSizeMessage = [message sizeWithFont:messageLabel.font constrainedToSize:maxSizeMessage lineBreakMode:messageLabel.lineBreakMode]; 
        [messageLabel setFrame:CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height)];
    }
    
    // titleLabel frame values
    CGFloat titleWidth, titleHeight, titleTop, titleLeft;
    
    if(titleLabel != nil) {
        titleWidth = titleLabel.bounds.size.width;
        titleHeight = titleLabel.bounds.size.height;
        titleTop = CSToastVerticalPadding;
        titleLeft = imageLeft + imageWidth + CSToastHorizontalPadding;
    } else {
        titleWidth = titleHeight = titleTop = titleLeft = 0.0;
    }
    
    // messageLabel frame values
    CGFloat messageWidth, messageHeight, messageLeft, messageTop;

    if(messageLabel != nil) {
        messageWidth = messageLabel.bounds.size.width;
        messageHeight = messageLabel.bounds.size.height;
        messageLeft = imageLeft + imageWidth + CSToastHorizontalPadding;
        messageTop = titleTop + titleHeight + CSToastVerticalPadding;
    } else {
        messageWidth = messageHeight = messageLeft = messageTop = 0.0;
    }
    

    CGFloat longerWidth = MAX(titleWidth, messageWidth);
    CGFloat longerLeft = MAX(titleLeft, messageLeft);
    
    // wrapper width uses the longerWidth or the image width, whatever is larger. same logic applies to the wrapper height
    CGFloat wrapperWidth = MAX((imageWidth + (CSToastHorizontalPadding * 2)), (longerLeft + longerWidth + CSToastHorizontalPadding));    
    CGFloat wrapperHeight = MAX((messageTop + messageHeight + CSToastVerticalPadding), (imageHeight + (CSToastVerticalPadding * 2)));
                         
    [wrapperView setFrame:CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight)];
    
    if(titleLabel != nil) {
        [titleLabel setFrame:CGRectMake(titleLeft, titleTop, titleWidth, titleHeight)];
        [wrapperView addSubview:titleLabel];
    }
    
    if(messageLabel != nil) {
        [messageLabel setFrame:CGRectMake(messageLeft, messageTop, messageWidth, messageHeight)];
        [wrapperView addSubview:messageLabel];
    }
    
    if(imageView != nil) {
        [wrapperView addSubview:imageView];
    }
        
    return wrapperView;
}

@end
