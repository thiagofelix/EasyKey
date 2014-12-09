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
//  EKStatusItemController.m
//  EasyKey
//
//  Created by Thiago Felix on 12/2/14.
//


#import "EKStatusItemController.h"
#import "EKSettings.h"

NSString *const kStatusItemIcon = @"ic_keyboard_24dp";

@interface EKStatusItemController ()
@property (nonatomic, retain) NSStatusItem *statusItem;
@end


@implementation EKStatusItemController

-(void)awakeFromNib {
	self.statusItemEnabled = EKSettings.instance.showInMenuBar;
}

-(BOOL)isStatusItemEnabled {
	return self.statusItem != nil;
}

-(void)setStatusItemEnabled:(BOOL)statusItemEnabled {
	if(statusItemEnabled && (self.statusItem == nil)) {
        [self createStatusItem];
	} else if(!statusItemEnabled && (self.statusItem != nil)) {
		[self deleteStatusItem];
	}
    EKSettings.instance.showInMenuBar = statusItemEnabled;
}

-(void)deleteStatusItem {
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
    self.statusItem = nil;
}

-(void)createStatusItem {
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    NSImage *statusItemImage = [NSImage imageNamed:kStatusItemIcon];
    statusItemImage.template = YES;
    statusItem.image = statusItemImage;
    
    statusItem.menu = self.statusItemMenu;
    statusItem.highlightMode = YES;
    self.statusItem = statusItem;
}

@end