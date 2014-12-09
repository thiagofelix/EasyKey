//
//  Copyright (C) 2014 Thiago Felix.
//
//  Permission is hereby granted, free of charge, to any person obtaining a 
//  copy of this software and associated documentation files (the "Software"), 
//  to deal in the Software without restriction, including without limitation 
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//  DEALINGS IN THE SOFTWARE.
//
//
//  EKLoginItem.m
//  EasyKey
//
//  Created by Thiago Felix on 12/2/14.
//

#import "EKLoginItem.h"

@implementation EKLoginItem
+ (EKLoginItem *) instance {
    static EKLoginItem *singleton = nil;
    if (nil == singleton) {
        singleton  = [[[self class] alloc] init];
    }
    return singleton;
}

- (BOOL)startAtLogin
{
    LSSharedFileListItemRef loginItem = [self loginItem];
    BOOL result = loginItem ? YES : NO;
    
    if (loginItem) {
        CFRelease(loginItem);
    }
    
    return result;
}

- (void)setStartAtLogin:(BOOL)startAtLogin
{
    if (startAtLogin == self.startAtLogin) {
        return;
    }
    
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (startAtLogin) {
        CFURLRef appUrl = (__bridge CFURLRef)[[NSBundle mainBundle] bundleURL];
        LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsRef,kLSSharedFileListItemLast, NULL,NULL, appUrl, NULL, NULL);
        if (itemRef) CFRelease(itemRef);
    } else {
        LSSharedFileListItemRef loginItem = [self loginItem];
        
        LSSharedFileListItemRemove(loginItemsRef, loginItem);
        if (loginItem != nil) CFRelease(loginItem);
    }
    
    if (loginItemsRef) CFRelease(loginItemsRef);
}

#pragma mark Private

- (LSSharedFileListItemRef)loginItem
{
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (!loginItemsRef) {
        return NULL;
    }
    
    NSArray *loginItems = CFBridgingRelease(LSSharedFileListCopySnapshot(loginItemsRef, nil));
    
    LSSharedFileListItemRef result = NULL;
    
    for (id item in loginItems) {
        LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
        CFURLRef itemURLRef;
        
        if (LSSharedFileListItemResolve(itemRef, 0, &itemURLRef, NULL) == noErr) {
            NSURL *itemURL = (__bridge NSURL *)itemURLRef;
            
            if ([itemURL isEqual:bundleURL]) {
                result = itemRef;
                break;
            }
        }
    }
    
    if (result != nil) {
        CFRetain(result);
    }
    
    CFRelease(loginItemsRef);
    
    return result;
}


@end
