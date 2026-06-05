//
//  main.m
//  doubleH3lix
//
//  Created by tihmstar on 18.02.18.
//  Copyright © 2018 tihmstar.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#include <dlfcn.h>
int (*dsystem)(const char *) = 0;

int main(int argc, char * argv[]) {
    dsystem = dlsym(RTLD_DEFAULT,"system");
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

