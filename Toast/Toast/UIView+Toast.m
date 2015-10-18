//
//  UIView+Toast.m
//  Toast
//
//  Copyright (c) 2011-2015 Charles Scalesse.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be included
//  in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "UIView+Toast.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

NSString * CSToastPositionTop       = @"CSToastPositionTop";
NSString * CSToastPositionCenter    = @"CSToastPositionCenter";
NSString * CSToastPositionBottom    = @"CSToastPositionBottom";

// Keys for values associated with the toast view
static const NSString * CSToastTimerKey             = @"CSToastTimerKey";
static const NSString * CSToastPositionKey          = @"CSToastPositionKey";
static const NSString * CSToastCompletionKey        = @"CSToastCompletionKey";

// Keys for values associated with self
static const NSString * CSToastActiveToastViewKey   = @"CSToastActiveToastViewKey";
static const NSString * CSToastActivityViewKey      = @"CSToastActivityViewKey";
static const NSString * CSToastQueueKey             = @"CSToastQueueKey";

static const NSTimeInterval CSToastDefaultDuration  = 3.0;
static const NSTimeInterval CSToastFadeDuration     = 0.2;

@interface UIView (ToastPrivate)

- (void)cs_hideToast:(UIView *)toast;
- (void)cs_toastTimerDidFinish:(NSTimer *)timer;
- (void)cs_handleToastTapped:(UITapGestureRecognizer *)recognizer;
- (CGPoint)cs_centerPointForPosition:(id)position withToast:(UIView *)toast;
- (CGSize)cs_sizeForString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode;
- (NSMutableArray *)cs_toastQueue;

@end

@implementation UIView (Toast)

#pragma mark - Toast Methods

- (void)makeToast:(NSString *)message {
    [self makeToast:message duration:CSToastDefaultDuration position:CSToastPositionBottom style:nil];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position style:(CSToastStyle *)style {
    UIView *toast = [self toastViewForMessage:message title:nil image:nil style:style];
    [self showToast:toast duration:duration position:position];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position image:(UIImage *)image style:(CSToastStyle *)style {
    UIView *toast = [self toastViewForMessage:message title:nil image:image style:style];
    [self showToast:toast duration:duration position:position];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position title:(NSString *)title style:(CSToastStyle *)style {
    UIView *toast = [self toastViewForMessage:message title:title image:nil style:style];
    [self showToast:toast duration:duration position:position];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position title:(NSString *)title image:(UIImage *)image style:(CSToastStyle *)style completion:(void(^)(BOOL didTap))completion {
    UIView *toast = [self toastViewForMessage:message title:title image:image style:style];
    [self showToast:toast duration:duration position:position completion:completion];
}

- (void)showToast:(UIView *)toast {
    [self showToast:toast duration:CSToastDefaultDuration position:CSToastPositionBottom];
}

- (void)showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position {
    [self showToast:toast duration:duration position:position completion:nil];
}

- (void)showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position completion:(void(^)(BOOL didTap))completion {
    // sanity
    if (toast == nil) return;
    
    if ([CSToastManager enqueueToastViews]) {
        if ([self.cs_toastQueue count] > 1) {
            [self.cs_toastQueue addObject:toast];
            return;
        } else {
            objc_setAssociatedObject(self, &CSToastActiveToastViewKey, toast, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    toast.center = [self cs_centerPointForPosition:position withToast:toast];
    toast.alpha = 0.0;
    
    if ([CSToastManager allowTapToDismiss]) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:toast action:@selector(cs_handleToastTapped:)];
        [toast addGestureRecognizer:recognizer];
        toast.userInteractionEnabled = YES;
        toast.exclusiveTouch = YES;
    }
    
    [self addSubview:toast];
    
    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         toast.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         NSTimer *timer = [NSTimer timerWithTimeInterval:duration target:self selector:@selector(cs_toastTimerDidFinish:) userInfo:toast repeats:NO];
                         [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
                         
                         objc_setAssociatedObject(toast, &CSToastTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         objc_setAssociatedObject(toast, &CSToastCompletionKey, completion, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                     }];
}


- (void)cs_hideToast:(UIView *)toast {
    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         toast.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [toast removeFromSuperview];
                         
                         UIView *nextToast = [[self cs_toastQueue] firstObject];
                         if (nextToast != nil) {
                             
                         }
                     }];
}

#pragma mark - Queue

- (NSMutableArray *)cs_toastQueue {
    NSMutableArray *cs_toastQueue = objc_getAssociatedObject(self, &CSToastQueueKey);
    if (cs_toastQueue == nil) {
        cs_toastQueue = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, &CSToastQueueKey, cs_toastQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cs_toastQueue;
}

#pragma mark - Events

- (void)cs_toastTimerDidFinish:(NSTimer *)timer {
    [self cs_hideToast:(UIView *)timer.userInfo];
}

- (void)cs_handleToastTapped:(UITapGestureRecognizer *)recognizer {
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(self, &CSToastTimerKey);
    [timer invalidate];
    
    void (^completion)(BOOL didTap) = objc_getAssociatedObject(self, &CSToastCompletionKey);
    if (completion) {
        completion(YES);
    }
    [self cs_hideToast:recognizer.view];
}

#pragma mark - Toast Activity Methods

- (void)makeToastActivity:(id)position {
    // sanity
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) return;
    
    CSToastStyle *style = [CSToastManager sharedStyle];
    
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, style.activitySize.width, style.activitySize.height)];
    activityView.center = [self cs_centerPointForPosition:position withToast:activityView];
    activityView.backgroundColor = style.backgroundColor;
    activityView.alpha = 0.0;
    activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityView.layer.cornerRadius = style.cornerRadius;
    
    if (style.displayShadow) {
        activityView.layer.shadowColor = [UIColor blackColor].CGColor;
        activityView.layer.shadowOpacity = style.shadowOpacity;
        activityView.layer.shadowRadius = style.shadowRadius;
        activityView.layer.shadowOffset = style.shadowOffset;
    }
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = CGPointMake(activityView.bounds.size.width / 2, activityView.bounds.size.height / 2);
    [activityView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    // associate the activity view with self
    objc_setAssociatedObject (self, &CSToastActivityViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addSubview:activityView];
    
    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     } completion:nil];
}

- (void)hideToastActivity {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:CSToastFadeDuration
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

- (CGPoint)cs_centerPointForPosition:(id)point withToast:(UIView *)toast {
    CSToastStyle *style = [CSToastManager sharedStyle];
    
    if([point isKindOfClass:[NSString class]]) {
        if([point caseInsensitiveCompare:CSToastPositionTop] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width/2, (toast.frame.size.height / 2) + style.verticalPadding);
        } else if([point caseInsensitiveCompare:CSToastPositionCenter] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        }
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }
    
    // default to bottom
    return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height - (toast.frame.size.height / 2)) - style.verticalPadding);
}

- (CGSize)cs_sizeForString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode {
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

- (UIView *)toastViewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image style:(CSToastStyle *)style {
    // sanity
    if((message == nil) && (title == nil) && (image == nil)) return nil;

    // ensure we have a style
    if (style == nil) {
        style = [CSToastManager sharedStyle];
    }
    
    // dynamically build a toast view with any combination of message, title, & image.
    UILabel *messageLabel = nil;
    UILabel *titleLabel = nil;
    UIImageView *imageView = nil;
    
    // create the parent view
    UIView *wrapperView = [[UIView alloc] init];
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = style.cornerRadius;
    
    if (style.displayShadow) {
        wrapperView.layer.shadowColor = [UIColor blackColor].CGColor;
        wrapperView.layer.shadowOpacity = style.shadowOpacity;
        wrapperView.layer.shadowRadius = style.shadowRadius;
        wrapperView.layer.shadowOffset = style.shadowOffset;
    }

    wrapperView.backgroundColor = style.backgroundColor;
    
    if(image != nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(style.horizontalPadding, style.verticalPadding, style.imageSize.width, style.imageSize.height);
    }
    
    CGFloat imageWidth, imageHeight, imageLeft;
    
    // the imageView frame values will be used to size & position the other views
    if(imageView != nil) {
        imageWidth = imageView.bounds.size.width;
        imageHeight = imageView.bounds.size.height;
        imageLeft = style.horizontalPadding;
    } else {
        imageWidth = imageHeight = imageLeft = 0.0;
    }
    
    if (title != nil) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = style.titleNumberOfLines;
        titleLabel.font = style.titleFont;
        titleLabel.textAlignment = style.titleAlignment;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha = 1.0;
        titleLabel.text = title;
        
        // size the title label according to the length of the text
        CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * style.maxWidthPercentage) - imageWidth, self.bounds.size.height * style.maxHeightPercentage);
        CGSize expectedSizeTitle = [self cs_sizeForString:title font:titleLabel.font constrainedToSize:maxSizeTitle lineBreakMode:titleLabel.lineBreakMode];
        titleLabel.frame = CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height);
    }
    
    if (message != nil) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = style.messageNumberOfLines;
        messageLabel.font = style.messageFont;
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;
        
        // size the message label according to the length of the text
        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * style.maxWidthPercentage) - imageWidth, self.bounds.size.height * style.maxHeightPercentage);
        CGSize expectedSizeMessage = [self cs_sizeForString:message font:messageLabel.font constrainedToSize:maxSizeMessage lineBreakMode:messageLabel.lineBreakMode];
        messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
    }
    
    // titleLabel frame values
    CGFloat titleWidth, titleHeight, titleTop, titleLeft;
    
    if(titleLabel != nil) {
        titleWidth = titleLabel.bounds.size.width;
        titleHeight = titleLabel.bounds.size.height;
        titleTop = style.verticalPadding;
        titleLeft = imageLeft + imageWidth + style.horizontalPadding;
    } else {
        titleWidth = titleHeight = titleTop = titleLeft = 0.0;
    }
    
    // messageLabel frame values
    CGFloat messageWidth, messageHeight, messageLeft, messageTop;

    if(messageLabel != nil) {
        messageWidth = messageLabel.bounds.size.width;
        messageHeight = messageLabel.bounds.size.height;
        messageLeft = imageLeft + imageWidth + style.horizontalPadding;
        messageTop = titleTop + titleHeight + style.verticalPadding;
    } else {
        messageWidth = messageHeight = messageLeft = messageTop = 0.0;
    }

    CGFloat longerWidth = MAX(titleWidth, messageWidth);
    CGFloat longerLeft = MAX(titleLeft, messageLeft);
    
    // wrapper width uses the longerWidth or the image width, whatever is larger. same logic applies to the wrapper height
    CGFloat wrapperWidth = MAX((imageWidth + (style.horizontalPadding * 2)), (longerLeft + longerWidth + style.horizontalPadding));
    CGFloat wrapperHeight = MAX((messageTop + messageHeight + style.verticalPadding), (imageHeight + (style.verticalPadding * 2)));
                         
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

@implementation CSToastStyle

#pragma mark - Constructors

- (instancetype)initWithDefaultStyle {
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        self.maxWidthPercentage = 0.8;
        self.maxHeightPercentage = 0.8;
        self.horizontalPadding = 10.0;
        self.verticalPadding = 10.0;
        self.cornerRadius = 10.0;
        self.titleFont = [UIFont boldSystemFontOfSize:16.0];
        self.messageFont = [UIFont systemFontOfSize:16.0];
        self.titleAlignment = NSTextAlignmentLeft;
        self.messageAlignment = NSTextAlignmentLeft;
        self.titleNumberOfLines = 0;
        self.messageNumberOfLines = 0;
        self.displayShadow = NO;
        self.shadowOpacity = 0.8;
        self.shadowRadius = 6.0;
        self.shadowOffset = CGSizeMake(4.0, 4.0);
        self.imageSize = CGSizeMake(80.0, 80.0);
        self.activitySize = CGSizeMake(100.0, 100.0);
    }
    return self;
}

- (instancetype)init NS_UNAVAILABLE {
    return nil;
}

@end

@interface CSToastManager ()

@property (strong, nonatomic) CSToastStyle *sharedStyle;
@property (assign, nonatomic) BOOL allowTapToDismiss;
@property (assign, nonatomic) BOOL enqueueToastViews;

@end

@implementation CSToastManager

#pragma mark - Constructors

+ (instancetype)sharedManager {
    static CSToastManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sharedStyle = [[CSToastStyle alloc] initWithDefaultStyle];
        self.allowTapToDismiss = YES;
        self.enqueueToastViews = YES;
    }
    return self;
}

#pragma mark - Singleton Methods

+ (void)setSharedStyle:(CSToastStyle *)sharedStyle {
    [[self sharedManager] setSharedStyle:sharedStyle];
}

+ (CSToastStyle *)sharedStyle {
    return [[self sharedManager] sharedStyle];
}

+ (void)setAllowTapToDismiss:(BOOL)allowTapToDismiss {
    [[self sharedManager] setAllowTapToDismiss:allowTapToDismiss];
}

+ (BOOL)allowTapToDismiss {
    return [[self sharedManager] allowTapToDismiss];
}

+ (void)setEnqueueToastViews:(BOOL)enqueueToastViews {
    [[self sharedManager] setEnqueueToastViews:enqueueToastViews];
}

+ (BOOL)enqueueToastViews {
    return [[self sharedManager] enqueueToastViews];
}

@end
