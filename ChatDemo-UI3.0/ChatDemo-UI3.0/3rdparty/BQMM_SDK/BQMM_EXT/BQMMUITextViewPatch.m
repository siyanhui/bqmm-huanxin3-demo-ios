////
////  BQMMUITextViewPatch.m
////  StampMeSDK
////
////  Created by Tender on 2016/12/26.
////  Copyright © 2016年 siyanhui. All rights reserved.
////
//
#import <Foundation/Foundation.h>
#import "BQMMUITextViewPatch.h"
#import <objc/message.h>


@implementation BQMMUITextViewPatch

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = NSClassFromString(@"BQMMTextViewHelp");
        [self class:class exchangeSelector:@selector(checkToUpdate:) withSelector:@selector(checkToUpdate:)];
    });
}

+ (void)class:(Class)class exchangeSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector {
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    
    BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)checkToUpdate:(NSNotification *)notification {
    
}

@end
