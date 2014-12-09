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
//  EKOverlayView.m
//  EasyKey
//
//  Created by Thiago Felix on 12/2/14.
//

#import "EKOverlayView.h"
#import "EKBadgeView.h"
#import "EKScanner.h"
#import "EKSystemEvents.h"
#import "HAXElement+Utilities.h"
#import "EKPreferencesController.h"
#import "EKHints.h"
#import "MASShortcut.h"
#import "EKSettings.h"


@interface EKOverlayView ()
@property (nonatomic, strong) NSEvent *lastEvent;
@property (nonatomic, strong) NSMutableArray *badges;
@property (nonatomic, strong) NSArray *hints;
@property (nonatomic, strong) NSMutableString *criteria;
@property (nonatomic, readonly, getter = isActivated) BOOL activated;
@end

@implementation EKOverlayView

#pragma mark - NSView Overwrites
-(void)awakeFromNib {
    
    [EKSystemEvents tapEvent:CGEventMaskBit(kCGEventKeyDown)
                   handler:^CGEventRef (CGEventRef event) {
                       [self performSelector:@selector(keyDown:) withObject:[NSEvent eventWithCGEvent:event] afterDelay:0];
                       return self.isActivated ? NULL : event;
                   }];
    
    self.badges = [NSMutableArray array];
    self.criteria = [NSMutableString string];
}

- (BOOL)isShortcutEvent:(NSEvent *)event {
    return [EKSettings.instance.globalShortcut.description isEqualToString:[MASShortcut shortcutWithEvent:event].description];
}

- (BOOL)isFlipped{
    return YES;
}


- (void)drawRect:(NSRect)dirtyRect
{
    for (EKBadgeView *badge in self.badges) {
        [badge draw];
        if (badge.match) {
            [self performSelector:@selector(deactivate) withObject:nil afterDelay:0];
            [self performActionOfElement:badge.element];
            break;
        }
    }
}

#pragma mark - NSResponder Overwrites
-(void)cancelOperation:(id)sender {
    [self deactivate];
}

-(void)keyDown:(NSEvent *)theEvent {
    self.lastEvent = theEvent;
    if ([self isShortcutEvent:theEvent]) {
        [self toggle];
    } else if (self.isActivated){
        [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
    }
}

-(void)insertText:(id)insertString {
    [self.criteria appendString:insertString];
    [self.badges makeObjectsPerformSelector:@selector(update:) withObject:self.criteria];
    [self setNeedsDisplay:YES];
}

-(void)deleteBackward:(id)sender {
    [self.criteria deleteCharactersInRange:NSMakeRange(self.criteria.length -1, 1)];
    [self.badges makeObjectsPerformSelector:@selector(update:) withObject:self.criteria];
    [self setNeedsDisplay:YES];
}


#pragma mark - Activation/Badges
-(void)performActionOfElement:(HAXElement *)element {
    if (self.lastEvent.modifierFlags & NSShiftKeyMask) {
        [self performSecondaryAction:element];
    } else {
        [self performPrimaryAction:element];
    }
}

-(void)performSecondaryAction:(HAXElement *)element{
    if ([element canPerformAction:NSAccessibilityShowMenuAction]) {
        [element performAction:NSAccessibilityShowMenuAction];
    } else {
        [self performPrimaryAction:element];
    }
}

-(void)performPrimaryAction:(HAXElement *)element{
    if (element.isOpenable) {
        [element performOpen];
    } else if ([element isRoleEqual:NSAccessibilityMenuButtonRole]) {
        //Althought MenuButton implements press action
        //It somethimes doesn't work as expected
        //Simulate click for that.
        [EKSystemEvents postMouseClickAt:element.center];
    } else if (element.isPresseable) {
        [element performPress];
    } else {
        [EKSystemEvents postMouseClickAt:element.center];
    }
}

-(void)toggle {
    if (self.isActivated) {
        [self deactivate];
    } else {
        [self activate];
    }
}

-(BOOL)isActivated {
    return self.badges.count > 0;
}

-(void)deactivate {
    self.badges = [NSMutableArray array];
    self.criteria = [NSMutableString string];
    [self setNeedsDisplay:YES];
}

-(void)activate {
    NSArray *elements = [EKScanner.instance scanCurrentApplication];
    self.criteria = [NSMutableString string];
    self.hints = [EKHints genHints:elements.count];
    
    for (HAXElement* element in elements) {
        NSString *hint = [self.hints objectAtIndex:self.badges.count];
        [self.badges addObject:[EKBadgeView badgeWithElement:element
                                                   andText:hint]];
    }
    
    [self setNeedsDisplay:YES];
}

@end
