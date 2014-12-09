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
//  EKPreferencesController.m
//  EasyKey
//
//  Created by Thiago Felix on 12/2/14.
//

#import "EKPreferencesController.h"
#import "MASShortcutView+UserDefaults.h"
#import "MASShortcut+UserDefaults.h"

NSString *const ShortcutWasPressedNotification = @"ShortcutWasPressedNotification";

@implementation EKPreferencesController

-(void)awakeFromNib {
    // Assign the preference key and the shortcut view will take care of persistence
    self.shortcutView.associatedUserDefaultsKey = kSettingsGlobalShortcut;
    
    // Execute your block of code automatically when user triggers a shortcut from preferences
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:kSettingsGlobalShortcut handler:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ShortcutWasPressedNotification object:nil];
    }];
    
    self.settings = EKSettings.instance;
}

-(void)showWindow:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [super showWindow:sender];
}

-(BOOL)isStatusItemEnabled {
	return self.settings.startAtLogin;
}

-(void)setStatusItemEnabled:(BOOL)statusItemEnabled {
    self.settings.showInMenuBar = statusItemEnabled;
}


@end
