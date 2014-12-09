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
//  EKSettings.m
//  EasyKey
//
//  Created by Thiago Felix on 12/2/14.
//

#import "EKSettings.h"
#import "EKLoginItem.h"

// Settings Keys
NSString *kSettingsGlobalShortcut = @"GlobalShortcut";
NSString *kSettingsReescan = @"Reescan";
NSString *kSettingsShowInMenuBar = @"ShowInMenuBar";
NSString *kSettingsStartAtLogin = @"StartAtLogin";

@interface EKSettings ()
@property (nonatomic, weak) NSUserDefaults *defaults;
@end

@implementation EKSettings

+(EKSettings *)instance {
    static EKSettings *singleton = nil;
    if (nil == singleton) {
        singleton  = [[[self class] alloc] init];
    }
    return singleton;
}

-(id)init {
    self = [super init];
    if (self) {
        self.defaults = [NSUserDefaults standardUserDefaults];
        [self.defaults registerDefaults:self.defaultOptions];
    }
    return self;
}

-(NSDictionary *)defaultOptions{
    // Define default shortcut as: CMD+SHIFT+RETURN
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_Return
                                               modifierFlags:NSCommandKeyMask|NSShiftKeyMask];
    NSData *shortcutData = [NSKeyedArchiver archivedDataWithRootObject:shortcut];
    
    return @{
             kSettingsShowInMenuBar: @YES,
             kSettingsGlobalShortcut: shortcutData
             };
}

-(BOOL)showInMenuBar {
    return [self.defaults boolForKey:kSettingsShowInMenuBar];
}

-(void)setShowInMenuBar:(BOOL)showInMenuBar {
    [self.defaults setBool:showInMenuBar forKey:kSettingsShowInMenuBar];
}

-(BOOL)startAtLogin {
    return EKLoginItem.instance.startAtLogin;
}

-(void)setStartAtLogin:(BOOL)startAtLogin {
    EKLoginItem.instance.startAtLogin = startAtLogin;
}

-(BOOL)reescan {
    return [self.defaults boolForKey:kSettingsReescan];
}

-(void)setReescan:(BOOL)reescan {
    [self.defaults setBool:reescan forKey:kSettingsReescan];
}

-(MASShortcut *)globalShortcut {
    return [MASShortcut shortcutWithData:[[NSUserDefaults standardUserDefaults] dataForKey:kSettingsGlobalShortcut]];
}

@end
