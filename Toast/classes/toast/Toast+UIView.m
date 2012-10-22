//
//  Toast+UIView.m
//  Toast
//  Version 1.2
//
//  Copyright 2012 Charles Scalesse.
//

#import "Toast+UIView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define kMaxWidth                   0.8
#define kMaxHeight                  0.8

#define kHorizontalPadding          10.0
#define kVerticalPadding            10.0
#define kCornerRadius               10.0
#define kOpacity                    0.8
#define kFontSize                   16.0
#define kMaxTitleLines              999
#define kMaxMessageLines            999
#define kFadeDuration               0.2
#define kDisplayShadow              YES

#define kDefaultLength              3.0
#define kDefaultPosition            @"bottom"

#define kImageWidth                 80.0
#define kImageHeight                80.0

#define kActivityWidth              100.0
#define kActivityHeight             100.0
#define kActivityDefaultPosition    @"center"
#define kActivityTag                91325

static NSString *kDurationKey = @"CSToastDurationKey";
static NSString *kToastKey = @"toast";


@interface UIView (ToastPrivate)

- (CGPoint)getPositionFor:(id)position toast:(UIView *)toast;
- (UIView *)makeViewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image;

- (UIView *)makeViewForMessageWithDismissButton:(NSString *)message title:(NSString *)title image:(UIImage *)image;

@end


@implementation UIView (Toast)

#pragma mark - Toast Methods

- (void)makeToastWithDismissButton:(NSString *)message 
{
    UIView*toast = [self makeViewForMessageWithDismissButton:message title:nil image:nil];
    CGPoint toastPoint = [self getPositionFor:kDefaultPosition toast:toast];
    [toast setCenter:toastPoint];
    [toast setAlpha:1.0];
    [self addSubview:toast];
}

- (void)makeToast:(NSString *)message {
    [self makeToast:message duration:kDefaultLength position:kDefaultPosition];
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position {
    UIView *toast = [self makeViewForMessage:message title:nil image:nil];
    [self showToast:toast duration:interval position:position];  
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position title:(NSString *)title {
    UIView *toast = [self makeViewForMessage:message title:title image:nil];
    [self showToast:toast duration:interval position:position];  
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position image:(UIImage *)image {
    UIView *toast = [self makeViewForMessage:message title:nil image:image];
    [self showToast:toast duration:interval position:position];  
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval  position:(id)position title:(NSString *)title image:(UIImage *)image {
    UIView *toast = [self makeViewForMessage:message title:title image:image];
    [self showToast:toast duration:interval position:position];  
}

- (void)showToast:(UIView *)toast {
    [self showToast:toast duration:kDefaultLength position:kDefaultPosition];
}

- (void)showToast:(UIView *)toast duration:(CGFloat)interval position:(id)point {
    
    /****************************************************
     *                                                  *
     * Displays a view for a given duration & position. *
     *                                                  *
     ****************************************************/
    
    CGPoint toastPoint = [self getPositionFor:point toast:toast];
    
    // use an associative reference to associate the toast view with the display interval
    objc_setAssociatedObject (toast, &kDurationKey, [NSNumber numberWithFloat:interval], OBJC_ASSOCIATION_RETAIN);
    
    [toast setCenter:toastPoint];
    [toast setAlpha:0.0];
    [self addSubview:toast];
    
    [UIView beginAnimations:@"fade_in" context:(__bridge void*)toast];
    [UIView setAnimationDuration:kFadeDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [toast setAlpha:1.0];
    [UIView commitAnimations];
    
}

#pragma mark - Toast Activity Methods

- (void)makeToastActivity {
    [self makeToastActivity:kActivityDefaultPosition];
}

- (void)makeToastActivityWithText:(NSString*)text
{
    [self makeToastActivityWithText:text position:kActivityDefaultPosition];
}


- (void)makeToastActivity:(id)position {
    // prevent more than one activity view
    UIView *existingToast = [self viewWithTag:kActivityTag];
    if (existingToast != nil) {
        [existingToast removeFromSuperview];
    }
    
    UIView *activityContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kActivityWidth, kActivityHeight)];
#if !__has_feature(objc_arc)
    [activityContainer autorelease];
#endif
    [activityContainer setCenter:[self getPositionFor:position toast:activityContainer]];
    [activityContainer setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:kOpacity]];
    [activityContainer setAlpha:0.0];
    [activityContainer setTag:kActivityTag];
    [activityContainer setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityContainer.layer setCornerRadius:kCornerRadius];
    if (kDisplayShadow) {
        [activityContainer.layer setShadowColor:[UIColor blackColor].CGColor];
        [activityContainer.layer setShadowOpacity:0.8];
        [activityContainer.layer setShadowRadius:6.0];
        [activityContainer.layer setShadowOffset:CGSizeMake(4.0, 4.0)];
    }
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
#if !__has_feature(objc_arc)
    [activityView autorelease];
#endif
    [activityView setCenter:CGPointMake(activityContainer.bounds.size.width / 2, activityContainer.bounds.size.height / 2)];
    [activityContainer addSubview:activityView];
    [activityView startAnimating];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kFadeDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [activityContainer setAlpha:1.0];
    [UIView commitAnimations];
    
    [self addSubview:activityContainer];
}

- (void)makeToastActivityWithText:(NSString*)text position:(id)position {
    // prevent more than one activity view
    UIView *existingToast = [self viewWithTag:kActivityTag];
    if (existingToast != nil) {
        [existingToast removeFromSuperview];
    }
    
    UIView *activityContainer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, kActivityWidth, kActivityHeight)] autorelease];
    [activityContainer setCenter:[self getPositionFor:position toast:activityContainer]];
    [activityContainer setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:kOpacity]];
    [activityContainer setAlpha:0.0];
    [activityContainer setTag:kActivityTag];
    [activityContainer.layer setCornerRadius:kCornerRadius];
    if (kDisplayShadow) {
        [activityContainer.layer setShadowColor:[UIColor blackColor].CGColor];
        [activityContainer.layer setShadowOpacity:0.8];
        [activityContainer.layer setShadowRadius:6.0];
        [activityContainer.layer setShadowOffset:CGSizeMake(4.0, 4.0)];
    }
    
    UIActivityIndicatorView *activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    [activityView setCenter:CGPointMake(activityContainer.bounds.size.width / 2, activityContainer.bounds.size.height / 2)];
    [activityContainer addSubview:activityView];
    [activityView startAnimating];
    
    if (text.length != 0)
    {
        UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, kActivityHeight - 30, kActivityWidth, 20)];
        textLabel.backgroundColor = [UIColor clearColor];
        [activityContainer addSubview:textLabel];
        textLabel.font = [UIFont systemFontOfSize:12];
        textLabel.text = text;
        textLabel.textAlignment = UITextAlignmentCenter;
        textLabel.textColor = [UIColor whiteColor];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kFadeDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [activityContainer setAlpha:1.0];
    [UIView commitAnimations];
    
    [self addSubview:activityContainer];
}

- (void)hideToastActivity {
    UIView *existingToast = [self viewWithTag:kActivityTag];
    if (existingToast != nil) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kFadeDuration];
        [UIView setAnimationDelegate:existingToast];
        [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [existingToast setAlpha:0.0];
        [UIView commitAnimations];
    }
}

#pragma mark - Animation Delegate Method

- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
    
    UIView *toast = (UIView *)(__bridge id)context;
    
    // retrieve the display interval associated with the view
    CGFloat interval = [(NSNumber *)objc_getAssociatedObject(toast, &kDurationKey) floatValue];
    
    if([animationID isEqualToString:@"fade_in"]) {
        
        [UIView beginAnimations:@"fade_out" context:(__bridge void*)toast];
        [UIView setAnimationDelay:interval];
        [UIView setAnimationDuration:kFadeDuration];
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
    
    /*************************************************************************************
     *                                                                                   *
     * Converts string literals @"top", @"bottom", @"center", or any point wrapped in an *
     * NSValue object into a CGPoint                                                     *
     *                                                                                   *
     *************************************************************************************/
    
    if([point isKindOfClass:[NSString class]]) {
        
        if( [point caseInsensitiveCompare:@"top"] == NSOrderedSame ) {
            return CGPointMake(self.bounds.size.width/2, (toast.frame.size.height / 2) + kVerticalPadding);
        } else if( [point caseInsensitiveCompare:@"bottom"] == NSOrderedSame ) {
            return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height - (toast.frame.size.height / 2)) - kVerticalPadding);
        } else if( [point caseInsensitiveCompare:@"center"] == NSOrderedSame ) {
            return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        }
        
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }
    
    NSLog(@"Error: Invalid position for toast.");
    return [self getPositionFor:kDefaultPosition toast:toast];
}

- (UIView *)makeViewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image {
    
    /***********************************************************************************
     *                                                                                 *
     * Dynamically build a toast view with any combination of message, title, & image. *
     *                                                                                 *
     ***********************************************************************************/
    
    if((message == nil) && (title == nil) && (image == nil)) return nil;

    UILabel *messageLabel = nil;
    UILabel *titleLabel = nil;
    UIImageView *imageView = nil;
    
    // create the parent view
    UIView *wrapperView = [[UIView alloc] init];
#if !__has_feature(objc_arc)
    [wrapperView autorelease];
#endif
    [wrapperView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [wrapperView.layer setCornerRadius:kCornerRadius];
    if (kDisplayShadow) {
        [wrapperView.layer setShadowColor:[UIColor blackColor].CGColor];
        [wrapperView.layer setShadowOpacity:0.8];
        [wrapperView.layer setShadowRadius:6.0];
        [wrapperView.layer setShadowOffset:CGSizeMake(4.0, 4.0)];
    }

    [wrapperView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:kOpacity]];
    
    if(image != nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
#if !__has_feature(objc_arc)
        [imageView autorelease];
#endif
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setFrame:CGRectMake(kHorizontalPadding, kVerticalPadding, kImageWidth, kImageHeight)];
    }
    
    CGFloat imageWidth, imageHeight, imageLeft;
    
    // the imageView frame values will be used to size & position the other views
    if(imageView != nil) {
        imageWidth = imageView.bounds.size.width;
        imageHeight = imageView.bounds.size.height;
        imageLeft = kHorizontalPadding;
    } else {
        imageWidth = imageHeight = imageLeft = 0.0;
    }
    
    if (title != nil) {
        titleLabel = [[UILabel alloc] init];
#if !__has_feature(objc_arc)
        [titleLabel autorelease];
#endif
        [titleLabel setNumberOfLines:kMaxTitleLines];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:kFontSize]];
        [titleLabel setTextAlignment:UITextAlignmentLeft];
        [titleLabel setLineBreakMode:UILineBreakModeWordWrap];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setAlpha:1.0];
        [titleLabel setText:title];
        
        // size the title label according to the length of the text
        CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * kMaxWidth) - imageWidth, self.bounds.size.height * kMaxHeight);
        CGSize expectedSizeTitle = [title sizeWithFont:titleLabel.font constrainedToSize:maxSizeTitle lineBreakMode:titleLabel.lineBreakMode]; 
        [titleLabel setFrame:CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height)];
    }
    
    if (message != nil) {
        messageLabel = [[UILabel alloc] init];
#if !__has_feature(objc_arc)
        [messageLabel autorelease];
#endif
        [messageLabel setNumberOfLines:kMaxMessageLines];
        [messageLabel setFont:[UIFont systemFontOfSize:kFontSize]];
        [messageLabel setLineBreakMode:UILineBreakModeWordWrap];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setAlpha:1.0];
        [messageLabel setText:message];
        
        // size the message label according to the length of the text
        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * kMaxWidth) - imageWidth, self.bounds.size.height * kMaxHeight);
        CGSize expectedSizeMessage = [message sizeWithFont:messageLabel.font constrainedToSize:maxSizeMessage lineBreakMode:messageLabel.lineBreakMode]; 
        [messageLabel setFrame:CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height)];
    }
    
    // titleLabel frame values
    CGFloat titleWidth, titleHeight, titleTop, titleLeft;
    
    if(titleLabel != nil) {
        titleWidth = titleLabel.bounds.size.width;
        titleHeight = titleLabel.bounds.size.height;
        titleTop = kVerticalPadding;
        titleLeft = imageLeft + imageWidth + kHorizontalPadding;
    } else {
        titleWidth = titleHeight = titleTop = titleLeft = 0.0;
    }
    
    // messageLabel frame values
    CGFloat messageWidth, messageHeight, messageLeft, messageTop;

    if(messageLabel != nil) {
        messageWidth = messageLabel.bounds.size.width;
        messageHeight = messageLabel.bounds.size.height;
        messageLeft = imageLeft + imageWidth + kHorizontalPadding;
        messageTop = titleTop + titleHeight + kVerticalPadding;
    } else {
        messageWidth = messageHeight = messageLeft = messageTop = 0.0;
    }
    

    CGFloat longerWidth = MAX(titleWidth, messageWidth);
    CGFloat longerLeft = MAX(titleLeft, messageLeft);
    
    // wrapper width uses the longerWidth or the image width, whatever is larger. same logic applies to the wrapper height
    CGFloat wrapperWidth = MAX((imageWidth + (kHorizontalPadding * 2)), (longerLeft + longerWidth + kHorizontalPadding));    
    CGFloat wrapperHeight = MAX((messageTop + messageHeight + kVerticalPadding), (imageHeight + (kVerticalPadding * 2)));
                         
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

#pragma mark- With DismissButton

- (void)dismissToast:(id)sender
{
    UIView *toast = objc_getAssociatedObject(sender, &kToastKey);
    
    [UIView beginAnimations:@"fade_in" context:toast];
    [UIView setAnimationDuration:kFadeDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [toast setAlpha:1.0];
    [UIView commitAnimations];
}

- (UIView *)makeViewForMessageWithDismissButton:(NSString *)message title:(NSString *)title image:(UIImage *)image 
{
    UIView *wrapperView = [self makeViewForMessage:message title:title image:image];
    
    UIButton *btn_dismiss = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_dismiss setImage:[UIImage imageNamed:@"dismiss.png"] forState:UIControlStateNormal];
    [wrapperView addSubview:btn_dismiss];
    [wrapperView bringSubviewToFront:btn_dismiss];
    btn_dismiss.frame = CGRectMake( wrapperView.bounds.size.width - 20, 0 , 13, 13);
    objc_setAssociatedObject (btn_dismiss, &kToastKey, wrapperView, OBJC_ASSOCIATION_RETAIN);
    [btn_dismiss addTarget:self action:@selector(dismissToast:) forControlEvents:UIControlEventTouchUpInside];
    
    wrapperView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3];
    [wrapperView.layer setCornerRadius:kCornerRadius/2];
    
    return  wrapperView;
}


@end
