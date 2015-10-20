Toast for iOS
=============

[![Build Status](https://travis-ci.org/scalessec/Toast.svg?branch=2.4)](https://travis-ci.org/scalessec/Toast)

Toast is an Objective-C category that adds toast notifications to the UIView object class. It is intended to be simple, lightweight, and easy to use. Most
 toast notifications can be triggered with a single line of code.


Screenshots
---------
![Toast Screenshots](http://i.imgur.com/oM28l.png)


Basic Examples
---------
```objc
// basic usage
[self.view makeToast:@"This is a piece of toast."];

// toast with duration, title, and position
[self.view makeToast:@"This is a piece of toast with a title." 
            duration:3.0
            position:CSToastPositionTop
               title:@"Toast Title"
               style:nil];
            
// toast with explicity duration and position
[self.view makeToast:@"This is a piece of toast with an image." 
            duration:3.0
            position:[NSValue valueWithCGPoint:CGPointMake(110, 110)]
               style:nil];

// toast with title, message, image, and completion block
[self.view makeToast:@"This is a piece of toast with a title & image"
            duration:3.0
            position:CSToastPositionBottom
               title:@"Toast Title"
               image:[UIImage imageNamed:@"toast.png"]
               style:nil
          completion:^(BOOL didTap) {
              NSLog(@"completion block, from tap: %@", didTap ? @"YES" : @"NO");
          }];
                
// display toast with an activity spinner
[self.view makeToastActivity:CSToastPositionCenter];

// display any view as toast
[self.view showToast:myView];
```

But wait, there's more!
---------
```objc
// create a new style
CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];

// this is just one of many style options
style.messageColor = [UIColor orangeColor];

// present the toast with the new style
[self.view makeToast:@"This is a piece of toast."
            duration:3.0
            position:CSToastPositionBottom
               style:style];

// or perhaps you want to use this style for all toasts going forward?
[CSToastManager setSharedStyle:style];

// now all toast views will now have orange text by default
[self.view makeToast:@"This text will be orange now."];

// toggle "tap to dismiss" functionality
[CSToastManager setAllowTapToDismiss:YES];

// toggle queueing behavior
[CSToastManager setQueueToastViews:YES];
            
```
    
See the demo project for more examples.


Setup Instructions
------------------
Install with [CocoaPods](http://cocoapods.org) by adding the following to your Podfile:

``` ruby
platform :ios, '7.0'
pod 'Toast', '~> 3.0'
```

or add manually: 

1. Add `UIView+Toast.h` & `UIView+Toast.m` to your project.
2. Link against QuartzCore.


MIT License
-----------
    Copyright (c) 2011-2015 Charles Scalesse.

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
