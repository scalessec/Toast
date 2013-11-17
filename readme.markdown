Toast for iOS
=============
*Version 2.1*

Toast is an Objective-C category that adds Android-style toast notifications to the UIView object class. It is intended to be simple, lightweight, and easy to use.

What's New
---------
 - Refactored to support ARC.
 - Added tap to dismiss support, enabled by default. This can be toggled with the `CSToastHidesOnTap` flag.
 - The toast delay duration is now implemented with NSTimer instead of the UIView animation's delay property. 
 - iOS7-related UI updates for the demo app.

Screenshots
---------
![Toast Screenshots](http://i.imgur.com/oM28l.png)

Examples
---------
    // basic usage
    [self.view makeToast:@"This is a piece of toast."];

    // toast with duration, title, and position
    [self.view makeToast:@"This is a piece of toast with a title." 
                 duration:3.0
                 position:@"top"
                    title:@"Toast Title"];
            
    // toast with an image
    [self.view makeToast:@"This is a piece of toast with an image." 
                duration:3.0
                position:[NSValue valueWithCGPoint:CGPointMake(110, 110)]
                   image:[UIImage imageNamed:@"toast.png"]];
                
    // display toast with an activity spinner
    [self.view makeToastActivity];
    
See the demo project for more examples.


Setup Instructions
------------------
1. Add `Toast+UIView.h` & `Toast+UIView.m` to your project.
2. Link against QuartzCore.


MIT License
-----------
    Copyright (c) 2013 Charles Scalesse.

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