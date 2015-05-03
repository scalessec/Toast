//
//  ToastProperties.m
//  Toast
//
//  Created by Liron Kopinsky on 5/3/15.
//
//

#import "ToastProperties.h"

@implementation ToastProperties

/*
 *  CONFIGURE THESE VALUES TO ADJUST LOOK & FEEL,
 *  DISPLAY DURATION, ETC.
 */

// positions
NSString * const CSToastPositionTop             = @"top";
NSString * const CSToastPositionCenter          = @"center";
NSString * const CSToastPositionBottom          = @"bottom";

// general appearance
static const CGFloat CSToastMaxWidth            = 0.8;      // 80% of parent view width
static const CGFloat CSToastMaxHeight           = 0.8;      // 80% of parent view height
static const CGFloat CSToastHorizontalPadding   = 10.0;
static const CGFloat CSToastVerticalPadding     = 10.0;
static const CGFloat CSToastCornerRadius        = 10.0;
static const CGFloat CSToastOpacity             = 0.8;
static const CGFloat CSToastFontSize            = 16.0;
static const CGFloat CSToastMaxTitleLines       = 0;
static const CGFloat CSToastMaxMessageLines     = 0;
static const NSTimeInterval CSToastFadeDuration = 0.2;

// shadow appearance
static const CGFloat CSToastShadowOpacity       = 0.8;
static const CGFloat CSToastShadowRadius        = 6.0;
static const CGSize  CSToastShadowOffset        = { 4.0, 4.0 };
static const BOOL    CSToastDisplayShadow       = YES;

// display duration
static const NSTimeInterval CSToastDefaultDuration  = 3.0;

// image view size
static const CGFloat CSToastImageViewWidth      = 80.0;
static const CGFloat CSToastImageViewHeight     = 80.0;

// activity
static const CGFloat CSToastActivityWidth       = 100.0;
static const CGFloat CSToastActivityHeight      = 100.0;

// interaction
static const BOOL CSToastHidesOnTap             = YES;     // excludes activity views


+ (id)sharedProperties {
  static ToastProperties *sharedProperties = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedProperties = [[self alloc] init];
  });
  return sharedProperties;
}

-(id)init
{
  self = [super init];
  if(!self)
    return nil;
  
  _textColor = [UIColor whiteColor];
  _titleColor = [UIColor whiteColor];
  _backgroundColor = [UIColor blackColor];
  
  _position = CSToastPositionBottom;
  _hideOnTap = CSToastHidesOnTap;
  
  _maxWidth = CSToastMaxWidth;
  _maxHeight = CSToastMaxHeight;
  _horizontalPadding = CSToastHorizontalPadding;
  _verticalPadding = CSToastVerticalPadding;
  _cornerRadius = CSToastCornerRadius;
  _opacity = CSToastOpacity;
  _fontSize = CSToastFontSize;
  _maxTitleLines = CSToastMaxTitleLines;
  _maxMessageLines = CSToastMaxMessageLines;
  _fadeDuration = CSToastFadeDuration;
  
  // shadow appearance
  _shadowOpacity = CSToastShadowOpacity;
  _shadowRadius = CSToastShadowRadius;
  _shadowOffset = CSToastShadowOffset;
  _displayShadow = CSToastDisplayShadow;
  _shadowColor = [UIColor blackColor];
  
  // display duration
  _duration = CSToastDefaultDuration;
  
  // image view size
  _imageViewWidth = CSToastImageViewWidth;
  _imageViewHeight = CSToastImageViewHeight;
  
  // activity
  _activityWidth = CSToastActivityWidth;
  _activityHeight = CSToastActivityHeight;
  _activityDefaultPosition = CSToastPositionCenter;
  
  return self;
}

-(instancetype)clone
{
  ToastProperties* clone = [[ToastProperties alloc] init];
  clone.textColor = _textColor;
  clone.titleColor = _titleColor;
  clone.backgroundColor = _backgroundColor;
  
  clone.position = _position;
  clone.hideOnTap = _hideOnTap;
  
  clone.maxWidth = _maxWidth;
  clone.maxHeight = _maxHeight;
  clone.horizontalPadding = _horizontalPadding;
  clone.verticalPadding = _verticalPadding;
  clone.cornerRadius = _cornerRadius;
  clone.opacity = _opacity;
  clone.fontSize = _fontSize;
  clone.maxTitleLines = _maxTitleLines;
  clone.maxMessageLines = _maxMessageLines;
  clone.fadeDuration = _fadeDuration;
  
  // shadow appearance
  clone.shadowOpacity = _shadowOpacity;
  clone.shadowRadius = _shadowRadius;
  clone.shadowOffset = _shadowOffset;
  clone.displayShadow = _displayShadow;
  clone.shadowColor = _shadowColor;
  
  // display duration
  clone.duration = _duration;
  
  // image view size
  clone.imageViewWidth = _imageViewWidth;
  clone.imageViewHeight = _imageViewHeight;
  
  // activity
  clone.activityWidth = _activityWidth;
  clone.activityHeight = _activityHeight;
  clone.activityDefaultPosition = _activityDefaultPosition;
  
  return clone;
}

@end
