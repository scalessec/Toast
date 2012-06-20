//
//  main.m
//  ToastTest
//
//  Copyright 2012 Charles Scalesse. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    #if __has_feature(objc_arc)
        @autoreleasepool {
            return UIApplicationMain(argc, argv, nil, nil);
        }
    #else
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        int retVal = UIApplicationMain(argc, argv, nil, nil);
        [pool release];
        return retVal;
    #endif
}
