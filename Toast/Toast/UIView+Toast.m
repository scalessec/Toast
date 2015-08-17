//
//  UIView+Toast.m
//  Toast
//
//  Copyright 2014 Charles Scalesse.
//


#import "UIView+Toast.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#import "ToastProperties.h"

// associative reference keys
static const NSString * CSToastTimerKey         = @"CSToastTimerKey";
static const NSString * CSToastActivityViewKey  = @"CSToastActivityViewKey";
static const NSString * CSToastTapCallbackKey   = @"CSToastTapCallbackKey";

static const NSString * CSToastViewKey   = @"CSToastViewKey";
static const NSString * CSToastPropertiesKey   = @"CSToastPropertiesKey";
@interface UIView (ToastPrivate)

- (void)hideToast:(UIView *)toast
       properties:(ToastProperties*)properties;
- (void)toastTimerDidFinish:(NSTimer *)timer;
- (void)handleToastTapped:(UITapGestureRecognizer *)recognizer;
- (CGPoint)centerPointForProperties:(ToastProperties*)properties toast:(UIView *)toast;
- (UIView *)viewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image properties:(ToastProperties*)properties;
- (CGSize)sizeForString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end


@implementation UIView (Toast)

#pragma mark - Toast Methods

- (void)makeToast:(NSString *)message {
    [self makeToast:message properties:nil];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position {
    [self makeToast:message duration:duration position:position title:nil image:nil];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position title:(NSString *)title {
    [self makeToast:message duration:duration position:position title:title image:nil];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position image:(UIImage *)image {
    [self makeToast:message duration:duration position:position title:nil image:image];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration  position:(id)position title:(NSString *)title image:(UIImage *)image {
    ToastProperties* properties = [[ToastProperties sharedProperties] clone];
    properties.duration = duration;
    properties.position = position;
  
    [self makeToast:message title:title image:image properties:properties];
}

- (void)makeToast:(NSString *)message properties:(ToastProperties*)properties {
    [self makeToast:message title:nil image:nil properties:properties];
}

- (void)makeToast:(NSString *)message title:(NSString *)title image:(UIImage *)image properties:(ToastProperties*)properties{
  UIView *toast = [self viewForMessage:message title:title image:image properties:properties];
  [self showToast:toast properties:properties];
}

- (void)showToast:(UIView *)toast {
    [self showToast:toast properties:nil];
}
- (void)showToast:(UIView *)toast duration:(NSTimeInterval)interval position:(id)point
{
  [self showToast:toast duration:interval position:point tapCallback:nil];
}
- (void)showToast:(UIView *)toast duration:(NSTimeInterval)interval position:(id)point
      tapCallback:(void(^)(void))tapCallback
{
  ToastProperties* properties = [ToastProperties sharedProperties];
  properties = [properties clone];
  properties.duration = interval;
  properties.position = point;
  [self showToast:toast properties:properties tapCallback:tapCallback];
}
- (void)showToast:(UIView *)toast properties:(ToastProperties*)properties {
    [self showToast:toast properties:properties tapCallback:nil];
}

- (void)showToast:(UIView *)toast properties:(ToastProperties*)properties
      tapCallback:(void(^)(void))tapCallback
{
    if(!properties)
        properties = [ToastProperties sharedProperties];
    toast.center = [self centerPointForProperties:properties toast:toast];
    toast.alpha = 0.0;
    
    if (properties.hideOnTap) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:toast action:@selector(handleToastTapped:)];
        [toast addGestureRecognizer:recognizer];
        toast.userInteractionEnabled = YES;
        toast.exclusiveTouch = YES;
    }
    
    [self addSubview:toast];
    
    [UIView animateWithDuration:properties.fadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         toast.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         NSDictionary* info = @{CSToastViewKey: toast, CSToastPropertiesKey:properties};
                         NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:properties.duration target:self selector:@selector(toastTimerDidFinish:) userInfo:info repeats:NO];
                         // associate the timer with the toast view
                         objc_setAssociatedObject (toast, &CSToastTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         objc_setAssociatedObject (toast, &CSToastTapCallbackKey, tapCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                     }];
}


- (void)hideToast:(UIView *)toast
properties:(ToastProperties*)properties
{
    if(!properties)
        properties = [ToastProperties sharedProperties];
    [UIView animateWithDuration:properties.fadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         toast.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [toast removeFromSuperview];
                     }];
}

#pragma mark - Events

- (void)toastTimerDidFinish:(NSTimer *)timer {
    NSDictionary* info = timer.userInfo;
    UIView* toastView = info[CSToastViewKey];
    ToastProperties* properties = info[CSToastPropertiesKey];
    [self hideToast:toastView properties:properties];
}

- (void)handleToastTapped:(UITapGestureRecognizer *)recognizer {
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(self, &CSToastTimerKey);
  
    ToastProperties* properties = nil;
    if(timer)
    {
        NSDictionary* info = timer.userInfo;
        if(info)
        {
            properties = info[CSToastPropertiesKey];
        }
        [timer invalidate];
    }
  
    void (^callback)(void) = objc_getAssociatedObject(self, &CSToastTapCallbackKey);
    if (callback) {
        callback();
    }
    [self hideToast:recognizer.view properties:properties];
}

#pragma mark - Toast Activity Methods

- (void)makeToastActivity {
    [self makeToastActivity:nil];
}

- (void)makeToastActivity:(ToastProperties*)properties {
    // sanity
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) return;
  
    if(!properties)
        properties = [ToastProperties sharedProperties];
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, properties.activityWidth, properties.activityHeight)];
    activityView.center = [self centerPointForProperties:properties toast:activityView];
    activityView.backgroundColor = [properties.backgroundColor colorWithAlphaComponent:properties.opacity];
    activityView.alpha = 0.0;
    activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityView.layer.cornerRadius = properties.cornerRadius;
    
    if (properties.displayShadow) {
        activityView.layer.shadowColor = properties.shadowColor.CGColor;
        activityView.layer.shadowOpacity = properties.shadowOpacity;
        activityView.layer.shadowRadius = properties.shadowRadius;
        activityView.layer.shadowOffset = properties.shadowOffset;
    }
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = CGPointMake(activityView.bounds.size.width / 2, activityView.bounds.size.height / 2);
    [activityView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    // associate the activity view with self
    objc_setAssociatedObject (self, &CSToastActivityViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addSubview:activityView];
    
    [UIView animateWithDuration:properties.fadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     } completion:nil];
}

- (void)hideToastActivity
{
  [self hideToastActivity:nil];
}
- (void)hideToastActivity:(ToastProperties*)properties {
    if(!properties)
      properties = [ToastProperties sharedProperties];
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) {
      [UIView animateWithDuration:properties.fadeDuration
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &CSToastActivityViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         }];
    }
}

#pragma mark - Helpers
- (CGPoint)centerPointForProperties:(ToastProperties*)properties toast:(UIView *)toast {
    if(!properties)
        properties = [ToastProperties sharedProperties];
  
    id point = properties.position;
    if([point isKindOfClass:[NSString class]]) {
        if([point caseInsensitiveCompare:CSToastPositionTop] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width/2, (toast.frame.size.height / 2) + properties.verticalPadding);
        } else if([point caseInsensitiveCompare:CSToastPositionCenter] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        }
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }
    
    // default to bottom
    return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height - (toast.frame.size.height / 2)) - properties.verticalPadding);
}

- (CGSize)sizeForString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode {
    if ([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = lineBreakMode;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
        CGRect boundingRect = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        return CGSizeMake(ceilf(boundingRect.size.width), ceilf(boundingRect.size.height));
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [string sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
}

- (UIView *)viewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image properties:(ToastProperties*)properties {
    // sanity
    if((message == nil) && (title == nil) && (image == nil)) return nil;
  
    if(!properties)
        properties = [ToastProperties sharedProperties];

    // dynamically build a toast view with any combination of message, title, & image.
    UILabel *messageLabel = nil;
    UILabel *titleLabel = nil;
    UIImageView *imageView = nil;
    
    // create the parent view
    UIView *wrapperView = [[UIView alloc] init];
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = properties.cornerRadius;
    
    if (properties.displayShadow) {
        wrapperView.layer.shadowColor = properties.shadowColor.CGColor;
        wrapperView.layer.shadowOpacity = properties.shadowOpacity;
        wrapperView.layer.shadowRadius = properties.shadowRadius;
        wrapperView.layer.shadowOffset = properties.shadowOffset;
    }

    wrapperView.backgroundColor = [properties.backgroundColor colorWithAlphaComponent:properties.opacity];
    
    if(image != nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(properties.horizontalPadding, properties.verticalPadding, properties.imageViewWidth, properties.imageViewHeight);
    }
    
    CGFloat imageWidth, imageHeight, imageLeft;
    
    // the imageView frame values will be used to size & position the other views
    if(imageView != nil) {
        imageWidth = imageView.bounds.size.width;
        imageHeight = imageView.bounds.size.height;
        imageLeft = properties.horizontalPadding;
    } else {
        imageWidth = imageHeight = imageLeft = 0.0;
    }
    
    if (title != nil) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = properties.maxTitleLines;
        titleLabel.font = [UIFont boldSystemFontOfSize:properties.fontSize];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textColor = properties.titleColor;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha = 1.0;
        titleLabel.text = title;
        
        // size the title label according to the length of the text
        CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * properties.maxWidth) - imageWidth, self.bounds.size.height * properties.maxHeight);
        CGSize expectedSizeTitle = [self sizeForString:title font:titleLabel.font constrainedToSize:maxSizeTitle lineBreakMode:titleLabel.lineBreakMode];
        titleLabel.frame = CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height);
    }
    
    if (message != nil) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = properties.maxMessageLines;
        messageLabel.font = [UIFont systemFontOfSize:properties.fontSize];
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.textColor = properties.textColor;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;
        
        // size the message label according to the length of the text
        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * properties.maxWidth) - imageWidth, self.bounds.size.height * properties.maxHeight);
        CGSize expectedSizeMessage = [self sizeForString:message font:messageLabel.font constrainedToSize:maxSizeMessage lineBreakMode:messageLabel.lineBreakMode];
        messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
    }
    
    // titleLabel frame values
    CGFloat titleWidth, titleHeight, titleTop, titleLeft;
    
    if(titleLabel != nil) {
        titleWidth = titleLabel.bounds.size.width;
        titleHeight = titleLabel.bounds.size.height;
        titleTop = properties.verticalPadding;
        titleLeft = imageLeft + imageWidth + properties.horizontalPadding;
    } else {
        titleWidth = titleHeight = titleTop = titleLeft = 0.0;
    }
    
    // messageLabel frame values
    CGFloat messageWidth, messageHeight, messageLeft, messageTop;

    if(messageLabel != nil) {
        messageWidth = messageLabel.bounds.size.width;
        messageHeight = messageLabel.bounds.size.height;
        messageLeft = imageLeft + imageWidth + properties.horizontalPadding;
        messageTop = titleTop + titleHeight + properties.verticalPadding;
    } else {
        messageWidth = messageHeight = messageLeft = messageTop = 0.0;
    }

    CGFloat longerWidth = MAX(titleWidth, messageWidth);
    CGFloat longerLeft = MAX(titleLeft, messageLeft);
    
    // wrapper width uses the longerWidth or the image width, whatever is larger. same logic applies to the wrapper height
    CGFloat wrapperWidth = MAX((imageWidth + (properties.horizontalPadding * 2)), (longerLeft + longerWidth + properties.horizontalPadding));
    CGFloat wrapperHeight = MAX((messageTop + messageHeight + properties.verticalPadding), (imageHeight + (properties.verticalPadding * 2)));
                         
    wrapperView.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight);
    
    if(titleLabel != nil) {
        titleLabel.frame = CGRectMake(titleLeft, titleTop, titleWidth, titleHeight);
        [wrapperView addSubview:titleLabel];
    }
    
    if(messageLabel != nil) {
        messageLabel.frame = CGRectMake(messageLeft, messageTop, messageWidth, messageHeight);
        [wrapperView addSubview:messageLabel];
    }
    
    if(imageView != nil) {
        [wrapperView addSubview:imageView];
    }
        
    return wrapperView;
}

@end
