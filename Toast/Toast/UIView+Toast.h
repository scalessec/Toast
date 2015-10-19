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

/**
 Toast is an Objective-C category that adds toast notifications to the UIView
 object class. It is intended to be simple and lightweight. Most toast
 notifications can be triggered with a single line of code.
 
 The `makeToast:` methods create a new view and then display it as toast.
 
 The `showToast:` methods display any view as toast.
 
 */
@interface UIView (Toast)

/**
 Creates and presents a new toast view with a message and displays it with the
 default duration and position. Styled using the shared style.
 
 @param message The message to be displayed
 */
- (void)makeToast:(NSString *)message;

/**
 Creates and presents a new toast view with a message. Duration, position, and
 style can be set explicitly.
 
 @param message The message to be displayed
 @param duration The notification duration
 @param position The toast's center point. Can be one of the predefined CSToastPosition
                 constants or a CGPoint wrapped in an NSValue object.
 @param style The style. The shared style will be used when nil
 */
- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)interval
         position:(id)position
            style:(CSToastStyle *)style;

/**
 Creates and presents a new toast view with a message and image. Duration, position,
 and style can be set explicitly.
 
 @param message The message to be displayed
 @param duration The notification duration
 @param position The toast's center point. Can be one of the predefined CSToastPosition
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
 Creates and presents a new toast view with a message and title. Duration, position,
 and style can be set explicitly.
 
 @param message The message to be displayed
 @param duration The notification duration
 @param position The toast's center point. Can be one of the predefined CSToastPosition
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
 Creates and presents a new toast view with a message, title, and image. Duration,
 position, and style can be set explicitly. The completion block executes when the
 toast view completes. `didTap` will be `YES` if the toast view was dismissed from 
 a tap.
 
 @param message The message to be displayed
 @param duration The notification duration
 @param position The toast's center point. Can be one of the predefined CSToastPosition
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

/**
 Creates a new toast view with any combination of message, title, and image.
 The look and feel is configured via the style. Unlike the `makeToast:` methods,
 this method does not present the toast view automatically. One of the showToast:
 methods must be used to present the resulting view.
 
 @param message The message to be displayed
 @param title The title
 @param image The image
 @param style The style. The shared style will be used when nil
 @return The newly created toast view
 */
- (UIView *)toastViewForMessage:(NSString *)message
                          title:(NSString *)title
                          image:(UIImage *)image
                          style:(CSToastStyle *)style;

/**
 Creates and displays a new toast activity indicator view at an explicit position.
 
 @warning Only one toast activity indicator view can be presented per superview. Subsequent
 calls to `makeToastActivity:` will be ignored until hideToastActivity is called.
 
 @warning `makeToastActivity:` works independently of the showToast: methods. Toast activity
 views can be presented and dismissed while toast views are being displayed. `makeToastActivity:`
 has no affect on the queueing behavior of the showToast: methods.
 
 @param position The toast's center point. Can be one of the predefined CSToastPosition
                 constants or a CGPoint wrapped in an NSValue object.
 @return The newly created toast view
 */
- (void)makeToastActivity:(id)position;

/**
 Dismisses the active toast activity indicator view.
 */
- (void)hideToastActivity;

/**
 Displays any view as toast using the default duration and position.
 
 @param toast The view to be displayed as toast
 */
- (void)showToast:(UIView *)toast;

/**
 Displays any view as toast at a provided position and duration.
 
 @param toast The view to be displayed as toast
 @param duration The notification duration
 @param position The toast's center point. Can be one of the predefined CSToastPosition
                 constants or a CGPoint wrapped in an NSValue object.
 */
- (void)showToast:(UIView *)toast
         duration:(NSTimeInterval)duration
         position:(id)position;

/**
 Displays any view as toast at a provided position and duration. The completion block 
 executes when the toast view completes. `didTap` will be `YES` if the toast view was 
 dismissed from a tap.
 
 @param toast The view to be displayed as toast
 @param duration The notification duration
 @param position The toast's center point. Can be one of the predefined CSToastPosition
                 constants or a CGPoint wrapped in an NSValue object.
 @param completion The completion block, executed after the toast view disappears.
                   didTap will be YES if the toast view was dismissed from a tap.
 */
- (void)showToast:(UIView *)toast
         duration:(NSTimeInterval)duration
         position:(id)position
       completion:(void(^)(BOOL didTap))completion;

@end

/**
 `CSToastStyle` instances define the look and feel for toast views created via the 
 `makeToast:` methods as well for toast views created directly with
 `toastViewForMessage:title:image:style:`.
 
 @warning `CSToastStyle` offers relatively simple styling options for the default
 toast view. If you require a toast view with more complex UI, it probably makes more
 sense to create your own custom UIView subclass and present it with the `showToast:`
 methods.
 */
@interface CSToastStyle : NSObject

/**
 The background color. Default is `[UIColor blackColor]` at 80% opacity.
 */
@property (strong, nonatomic) UIColor *backgroundColor;

/**
 A percentage value from 0.0 to 1.0, representing the maximum width of the toast
 view relative to it's superview. Default is 0.8 (80% of the superview's width).
 */
@property (assign, nonatomic) CGFloat maxWidthPercentage;

/**
 A percentage value from 0.0 to 1.0, representing the maximum height of the toast
 view relative to it's superview. Default is 0.8 (80% of the superview's height).
 */
@property (assign, nonatomic) CGFloat maxHeightPercentage;

/**
 The spacing from the horizontal edge of the toast view to the content. When an image
 is present, this is also used as the padding between the image and the text.
 Default is 10.0.
 */
@property (assign, nonatomic) CGFloat horizontalPadding;

/**
 The spacing from the vertical edge of the toast view to the content. When a title
 is present, this is also used as the padding between the title and the message.
 Default is 10.0.
 */
@property (assign, nonatomic) CGFloat verticalPadding;

/**
 The corner radius. Default is 10.0.
 */
@property (assign, nonatomic) CGFloat cornerRadius;

/**
 The title font. Default is `[UIFont boldSystemFontOfSize:16.0]`.
 */
@property (strong, nonatomic) UIFont *titleFont;

/**
 The message font. Default is `[UIFont systemFontOfSize:16.0]`.
 */
@property (strong, nonatomic) UIFont *messageFont;

/**
 The title text alignment. Default is `NSTextAlignmentLeft`.
 */
@property (assign, nonatomic) NSTextAlignment titleAlignment;

/**
 The message text alignment. Default is `NSTextAlignmentLeft`.
 */
@property (assign, nonatomic) NSTextAlignment messageAlignment;

/**
 The maximum number of lines for the title. The default is 0 (no limit).
 */
@property (assign, nonatomic) CGFloat titleNumberOfLines;

/**
 The maximum number of lines for the message. The default is 0 (no limit).
 */
@property (assign, nonatomic) CGFloat messageNumberOfLines;

/**
 Enable or disable a shadow on the toast view. Default is `NO`.
 */
@property (assign, nonatomic) BOOL displayShadow;

/**
 A value from 0.0 to 1.0, representing the opacity of the shadow.
 Default is 0.8 (80% opacity).
 */
@property (assign, nonatomic) CGFloat shadowOpacity;

/**
 The shadow radius. Default is 6.0.
 */
@property (assign, nonatomic) CGFloat shadowRadius;

/**
 The shadow offset. The default is `CGSizeMake(4.0, 4.0)(4.0, 4.0)`.
 */
@property (assign, nonatomic) CGSize shadowOffset;

/**
 The image size. The default is `CGSizeMake(80.0, 80.0)`.
 */
@property (assign, nonatomic) CGSize imageSize;

/**
 The size of the toast activity view when `makeToastActivity:` is called.
 Default is `CGSizeMake(100.0, 100.0)`.
 */
@property (assign, nonatomic) CGSize activitySize;

/**
 @warning Creates a new instance of `CSToastStyle` with all the
 defaults values set. 
 */
- (instancetype)initWithDefaultStyle NS_DESIGNATED_INITIALIZER;

/**
 @warning Only the designated initializer should be used to create
 and instance of `CSToastStyle`.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

/**
 `CSToastManager` provides general configuration options for toast notifications
 and is backed by a singleton instance.
 */
@interface CSToastManager : NSObject

/**
 
 @param sharedStyle
 */
+ (void)setSharedStyle:(CSToastStyle *)sharedStyle;

/**
 
 @return
 */
+ (CSToastStyle *)sharedStyle;

/**
 
 @param allowTapToDismiss
 */
+ (void)setAllowTapToDismiss:(BOOL)allowTapToDismiss;

/**
 
 @return
 */
+ (BOOL)allowTapToDismiss;

/**
 
 @param enqueueToastViews
 */
+ (void)setEnqueueToastViews:(BOOL)enqueueToastViews;

/**
 
 @return
 */
+ (BOOL)enqueueToastViews;

@end
