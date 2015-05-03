//
//  ToastProperties.h
//  Toast
//
//  Created by Liron Kopinsky on 5/3/15.
//
//

#import <Foundation/Foundation.h>

extern NSString * const CSToastPositionTop;
extern NSString * const CSToastPositionCenter;
extern NSString * const CSToastPositionBottom;

@interface ToastProperties : NSObject

@property (nonatomic, strong) UIColor* backgroundColor;
@property (nonatomic, strong) UIColor* textColor;
@property (nonatomic, strong) UIColor* titleColor;

@property (nonatomic, strong) id position;
@property BOOL hideOnTap;

@property CGFloat maxWidth;
@property CGFloat maxHeight;
@property CGFloat horizontalPadding;
@property CGFloat verticalPadding;
@property CGFloat cornerRadius;
@property CGFloat opacity;
@property CGFloat fontSize;
@property CGFloat maxTitleLines;
@property CGFloat maxMessageLines;
@property NSTimeInterval fadeDuration;

// shadow appearance
@property CGFloat shadowOpacity;
@property CGFloat shadowRadius;
@property CGSize  shadowOffset;
@property BOOL displayShadow;
@property (nonatomic, strong) UIColor* shadowColor;

// display duration
@property NSTimeInterval duration;

// image view size
@property CGFloat imageViewWidth;
@property CGFloat imageViewHeight;

// activity
@property CGFloat activityWidth;
@property CGFloat activityHeight;
@property (nonatomic, strong) NSString * activityDefaultPosition;

-(instancetype)clone;
+ (id)sharedProperties;
@end
