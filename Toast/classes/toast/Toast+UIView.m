//
//  Toast+UIView.m
//  Toast
//  Version 0.1
//
//  Copyright 2011 Charles Scalesse.
//

#import "Toast+UIView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define kMaxWidth               0.8
#define kMaxHeight              0.8

#define kHorizontalPadding      10.0
#define kVerticalPadding        10.0
#define kCornerRadius           10.0
#define kOpacity                0.8
#define kFontSize               16.0
#define kMaxTitleLines          999
#define kMaxMessageLines        999
#define kFadeDuration           0.2

#define kDefaultLength          3.0
#define kDefaultPosition        @"bottom"

#define kImageWidth             80.0
#define kImageHeight            80.0

static NSString *kDurationKey = @"CSToastDurationKey";


@interface UIView (ToastPrivate)

- (CGPoint)getPositionFor:(id)position toast:(UIView *)toast;
- (UIView *)makeViewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image;

@end


@implementation UIView (Toast)

#pragma mark -
#pragma mark Toast Methods

- (void)makeToast:(NSString *)message {
    [self makeToast:message duration:kDefaultLength position:kDefaultPosition];
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)point {
    UIView *toast = [self makeViewForMessage:message title:nil image:nil];
    [self showToast:toast duration:interval position:point];  
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)point title:(NSString *)title {
    UIView *toast = [self makeViewForMessage:message title:title image:nil];
    [self showToast:toast duration:interval position:point];  
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)point image:(UIImage *)image {
    UIView *toast = [self makeViewForMessage:message title:nil image:image];
    [self showToast:toast duration:interval position:point];  
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval  position:(id)point title:(NSString *)title image:(UIImage *)image {
    UIView *toast = [self makeViewForMessage:message title:title image:image];
    [self showToast:toast duration:interval position:point];  
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
    
    //use an associative reference to associate the toast view with the display interval
    objc_setAssociatedObject (toast, &kDurationKey, [NSNumber numberWithFloat:interval], OBJC_ASSOCIATION_RETAIN);
    
    [toast setCenter:toastPoint];
    [toast setAlpha:0.0];
    [self addSubview:toast];
    
    [UIView beginAnimations:@"fade_in" context:toast];
    [UIView setAnimationDuration:kFadeDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [toast setAlpha:1.0];
    [UIView commitAnimations];
    
}

#pragma mark -
#pragma mark Animation Delegate Method

- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
    
    UIView *toast = (UIView *)context;
    
    // retrieve the display interval associated with the view
    CGFloat interval = [(NSNumber *)objc_getAssociatedObject(toast, &kDurationKey) floatValue];
    
    if([animationID isEqualToString:@"fade_in"]) {
        
        [UIView beginAnimations:@"fade_out" context:toast];
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

#pragma mark -
#pragma mark Private Methods

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
    UIView *wrapperView = [[[UIView alloc] init] autorelease];
    [wrapperView.layer setCornerRadius:kCornerRadius];
    [wrapperView.layer setShadowColor:[UIColor blackColor].CGColor];
    [wrapperView.layer setShadowOpacity:0.8];
    [wrapperView.layer setShadowRadius:6.0];
    [wrapperView.layer setShadowOffset:CGSizeMake(4.0, 4.0)];

    [wrapperView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:kOpacity]];
    
    if(image != nil) {
        imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
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
        titleLabel = [[[UILabel alloc] init] autorelease];
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
        messageLabel = [[[UILabel alloc] init] autorelease];
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

@end
