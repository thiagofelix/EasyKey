
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
//  EKSystemEvents.h
//  EasyKey
//
//  Created by Thiago Felix on 12/2/14.
//

#import <Foundation/Foundation.h>
#import "EKSystemEvents.h"

@interface CallBackRefcon : NSObject
@property (nonatomic, copy) EvenHandler handler;
@property (nonatomic, assign) CFMachPortRef tap;
@property (nonatomic, assign) CGEventMask mask;
+(CallBackRefcon*)withHandler:(EvenHandler)handler;
@end

static NSMutableArray *refcons;

@implementation CallBackRefcon
@synthesize handler, tap;
+(CallBackRefcon*)withHandler:(EvenHandler)handler {
    CallBackRefcon* refcon =[[CallBackRefcon alloc]init];
    if (refcon) {
        refcon.handler = handler;
        
        if (!refcons) {
            refcons = [NSMutableArray array];
        }
        [refcons addObject:refcon];
    }
    
    return refcon;
}
@end


@implementation EKSystemEvents

+(void)postMouseClickAt:(NSPoint)point {
    CGEventRef click_down = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown,
                                                    point,
                                                    kCGMouseButtonLeft);
    
    CGEventRef click_up = CGEventCreateMouseEvent(
                                                  NULL, kCGEventLeftMouseUp,
                                                  point,
                                                  kCGMouseButtonLeft
                                                  );
    
    CGEventPost(kCGHIDEventTap, click_down);
    CGEventPost(kCGHIDEventTap, click_up);
    CFRelease(click_down);
    CFRelease(click_up);
}

+(CFMachPortRef)tapEvent:(CGEventMask)mask handler:(EvenHandler)handler {
    CallBackRefcon *refcon = [CallBackRefcon withHandler:handler];
    refcon.mask = mask;
    refcon.tap = CGEventTapCreate(kCGSessionEventTap,
                                  kCGHeadInsertEventTap,
                                  kCGEventTapOptionDefault,
                                  mask,
                                  TapCallback,
                                  (__bridge_retained void *)refcon);
    
    if( refcon.tap ){
        CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, refcon.tap, 0);
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
        CGEventTapEnable(refcon.tap, true);
        CFRelease(runLoopSource);
    }
    return refcon.tap;
}


CGEventRef TapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    CallBackRefcon *ref = (__bridge CallBackRefcon*)refcon;
    if (type == kCGEventTapDisabledByTimeout) {
        CGEventTapEnable(ref.tap, true);
        return event;
    } else if (ref.mask & CGEventMaskBit(type)) {
        return ref.handler(event);
    } else {
        return event;
    }
}

@end
