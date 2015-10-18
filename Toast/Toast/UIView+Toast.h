//
//  UIView+Toast.h
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

#import <UIKit/UIKit.h>

extern const NSString * CSToastPositionTop;
extern const NSString * CSToastPositionCenter;
extern const NSString * CSToastPositionBottom;

@class CSToastStyle;

@interface UIView (Toast)

/**
 Creates a new toast view with a message and displays it with the default
 duration and position. Styled using the shared style.
 
 @param message The message to be displayed
 */
- (void)makeToast:(NSString *)message;

/**
 Creates a new toast view with a message. Duration, position, and style
 can be set explicitly.
 
 @param message The message to be displayed
 @param duration The notification duration
 @param position The toast position. Can be one of the predefined CSToastPosition
                 constants or a CGPoint wrapped in an NSValue object.
 @param style The style. The shared style will be used when nil
 */
- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)interval
         position:(id)position
            style:(CSToastStyle *)style;

/**
 Creates a new toast view with a message and image. Duration, position, and
 style can be set explicitly.
 
 @param message The message to be displayed
 @param duration The notification duration
 @param position The toast position. Can be one of the predefined CSToastPosition
                 constants or a CGPoint wrapped in an NSValue object.
 @param image The image
 @param style The style. The shared style will be used when nil
 */
- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)interval
         position:(id)position
            image:(UIImage *)image
            style:(CSToastStyle *)style;

/**
 Creates a new toast view with a message and title. Duration, position, and
 style can be set explicitly.
 
 @param message The message to be displayed
 @param duration The notification duration
 @param position The toast position. Can be one of the predefined CSToastPosition
                 constants or a CGPoint wrapped in an NSValue object.
 @param title The title
 @param style The style. The shared style will be used when nil
 */
- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)interval
         position:(id)position
            title:(NSString *)title
            style:(CSToastStyle *)style;

/**
 Creates a new toast view with a message, title, and image. Duration, position, and
 style can be set explicitly. The completion block executes when the toast view completes.
 didTap will be YES if the toast view was dismissed from a tap.
 
 @param message The message to be displayed
 @param duration The notification duration
 @param position The toast position. Can be one of the predefined CSToastPosition
                 constants or a CGPoint wrapped in an NSValue object.
 @param title The title
 @param image The image
 @param style The style. The shared style will be used when nil
 @param completion The completion block, executed after the toast view disappears.
                   didTap will be YES if the toast view was dismissed from a tap.
 */
- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)interval
         position:(id)position
            title:(NSString *)title
            image:(UIImage *)image
            style:(CSToastStyle *)style
       completion:(void(^)(BOOL didTap))completion;

- (void)makeToastActivity:(id)position;

- (void)hideToastActivity;

- (void)showToast:(UIView *)toast;

- (void)showToast:(UIView *)toast
         duration:(NSTimeInterval)duration
         position:(id)position;

- (void)showToast:(UIView *)toast
         duration:(NSTimeInterval)duration
         position:(id)position
       completion:(void(^)(BOOL didTap))completion;

@end

@interface CSToastStyle : NSObject

@property (strong, nonatomic) UIColor *backgroundColor;
@property (assign, nonatomic) CGFloat maxWidthPercentage;
@property (assign, nonatomic) CGFloat maxHeightPercentage;
@property (assign, nonatomic) CGFloat horizontalPadding;
@property (assign, nonatomic) CGFloat verticalPadding;
@property (assign, nonatomic) CGFloat cornerRadius;
@property (strong, nonatomic) UIFont *titleFont;
@property (strong, nonatomic) UIFont *messageFont;
@property (assign, nonatomic) NSTextAlignment titleAlignment;
@property (assign, nonatomic) NSTextAlignment messageAlignment;
@property (assign, nonatomic) CGFloat titleNumberOfLines;
@property (assign, nonatomic) CGFloat messageNumberOfLines;
@property (assign, nonatomic) BOOL displayShadow;
@property (assign, nonatomic) CGFloat shadowOpacity;
@property (assign, nonatomic) CGFloat shadowRadius;
@property (assign, nonatomic) CGSize shadowOffset;
@property (assign, nonatomic) CGSize imageSize;
@property (assign, nonatomic) CGSize activitySize;

- (instancetype)initWithDefaultStyle NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

@interface CSToastManager : NSObject

+ (void)setSharedStyle:(CSToastStyle *)sharedStyle;

+ (CSToastStyle *)sharedStyle;

+ (void)setAllowTapToDismiss:(BOOL)allowTapToDismiss;

+ (BOOL)allowTapToDismiss;

+ (void)setEnqueueToastViews:(BOOL)enqueueToastViews;

+ (BOOL)enqueueToastViews;

@end
