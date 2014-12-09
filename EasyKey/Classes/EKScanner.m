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
//  EKScanner.m
//  EasyKey
//
//  Created by Thiago Felix on 12/2/14.
//

#import "EKScanner.h"
#import "HAXApplication.h"
#import "HAXElement+Utilities.h"
#import "HAXApplication+Utilities.h"

@interface EKScanner ()
@property(nonatomic, readwrite) NSMutableArray *elements;
@end

@implementation EKScanner
@synthesize elements;

# pragma mark - Static Methods
+(EKScanner *)instance
{
    static EKScanner *singleton = nil;
    if (nil == singleton) {
        singleton  = [[[self class] alloc] init];
    }
    return singleton;
}

-(id)init {
    self = [super init];
    if (self) {
        self.elements = [NSMutableArray array];
    }
    return self;
}

# pragma mark - Scan Methods

- (NSArray *) scanCurrentApplication {
    HAXApplication *app = HAXSystem.system.focusedApplication;
    self.elements = [NSMutableArray array];
    [self scanDescendantsOf:app.focusedWindow];
    [self scanDescendantsOf:app.menuBar];
    return self.elements;
}

-(void)scanDescendantsOf:(HAXElement *)element {
    NSArray *children = [self childrenOf:element];
    for (HAXElement *child in children) {
        if ([self isElementActionable:child]){
            [self.elements addObject:child];
        }
        
        [self scanDescendantsOf:child];
    }
}

-(NSArray *)childrenOf:(HAXElement *)element {
    
    //RadioGroup implements VisibleChildren but it doesn't work
    //Return all children instead
    if ([self isElement:element anyOfRoles:NSAccessibilityRadioGroupRole, nil]) {
        return element.children;
    }
    
    //If is menu, return children if it is selected
    if ([self isElement:element anyOfRoles:(NSString *)kAXMenuBarItemRole, NSAccessibilityMenuItemRole, nil]) {
        return element.isSelected ? element.children : @[];
    }
    
    //If element implements visibleChildren return them
    if ([element hasAttribute:NSAccessibilityVisibleChildrenAttribute]){
        return element.visibleChildren;
    }
    
    //If element implements visibleCells return them
    if ([element hasAttribute:NSAccessibilityVisibleCellsAttribute]){
        return element.visibleCells;
    }
    
    //If element implements visibleRows return them
    if ([element hasAttribute:NSAccessibilityVisibleRowsAttribute]){
        return element.visibleRows;
    }
    
    //Lastly return the standard children
    return element.children;
}

-(BOOL)isElementActionable:(HAXElement *)element {
    return (element.isEnabled &&
            [self canElement:element performAnyOfActions:NSAccessibilityPressAction, kAXOpen, nil]) ||
    [self isElement:element anyOfRoles:NSAccessibilityRowRole, nil];
}

-(BOOL)canElement:(HAXElement *)element performAnyOfActions:(NSString *)firstAction, ... {
    BOOL performsAny = NO;
    va_list roles;
    va_start(roles, firstAction);
    for (NSString *action = firstAction; action != nil; action = va_arg(roles, NSString*))
    {
        performsAny = [element canPerformAction:action] || performsAny;
    }
    va_end(roles);
    return performsAny;
}

-(BOOL)isElement:(HAXElement *)element anyOfRoles:(NSString *)firstRole, ... {
    BOOL isAny = NO;
    va_list roles;
    va_start(roles, firstRole);
    for (NSString *role = firstRole; role != nil; role = va_arg(roles, NSString*))
    {
        isAny = [element isRoleEqual:role] || isAny;
    }
    va_end(roles);
    return isAny;
}


@end
