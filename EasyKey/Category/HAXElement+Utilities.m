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
//  HAXElement+Utilities.m
//  
//
//  Created by Thiago Felix on 12/2/14.
//

#import "HAXElement+Utilities.h"
#import "HAXElement+Protected.h"
#import <objc/runtime.h>

NSString *kAXOpen = @"AXOpen";

@implementation HAXElement (Utilities)

#pragma mark - NSAccessibilityActions
-(BOOL)performOpen {
    return [self performAction:kAXOpen error:NULL];
}

-(BOOL)performPress {
    return [self performAction:NSAccessibilityPressAction error:NULL];
}

-(BOOL)performAction:(NSString *)actionName {
    return [self performAction:actionName error:NULL];
}



#pragma mark - NSAccessibilityAttributes
-(HAXElement *)parent {
    return [self elementOfClass:[HAXElement class] forKey:NSAccessibilityParentAttribute error:NULL];
}
-(NSPoint)center {
	return NSMakePoint(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
}

-(CGRect)frame {
	return (CGRect){ .origin = self.origin, .size = self.size };
}

-(NSString *)title {
	return CFBridgingRelease([self copyAttributeValueForKey:NSAccessibilityTitleAttribute error:NULL]);
}

-(NSString *)role {
	return CFBridgingRelease([self copyAttributeValueForKey:NSAccessibilityRoleAttribute error:NULL]);
}

-(NSString *)subrole {
	return CFBridgingRelease([self copyAttributeValueForKey:NSAccessibilitySubroleAttribute error:NULL]);
}

-(CGPoint)origin {
	CGPoint origin = {0};
	CFTypeRef originRef = [self copyAttributeValueForKey:(__bridge NSString *)kAXPositionAttribute error:NULL];
	if(originRef) {
		AXValueGetValue(originRef, kAXValueCGPointType, &origin);
		CFRelease(originRef);
		originRef = NULL;
	}
	return origin;
}

-(CGSize)size {
	CGSize size = {0};
	CFTypeRef sizeRef = [self copyAttributeValueForKey:(__bridge NSString *)kAXSizeAttribute error:NULL];
	if(sizeRef) {
		AXValueGetValue(sizeRef, kAXValueCGSizeType, &size);
		CFRelease(sizeRef);
		sizeRef = NULL;
	}
	return size;
}

-(NSArray *)visibleCells {
    return [self getArrayOfAttribute:NSAccessibilityVisibleCellsAttribute];
}

-(NSArray *)visibleRows {
    return [self getArrayOfAttribute:NSAccessibilityVisibleRowsAttribute];
}

-(NSArray *)visibleChildren {
    return [self getArrayOfAttribute:NSAccessibilityVisibleChildrenAttribute];
}

-(NSArray *)children {
    return [self getArrayOfAttribute:NSAccessibilityChildrenAttribute];
}

-(NSArray *)actions {
    NSArray *result = objc_getAssociatedObject(self, @"actions");
    if (result == nil) {
        CFTypeRef actionsRef = NULL;
        AXUIElementCopyActionNames(self.elementRef, (CFArrayRef *)&actionsRef);
        result = CFBridgingRelease(actionsRef);
        objc_setAssociatedObject(self, @"actions", result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

-(BOOL)isEnabled {
    return [self isAttributeBooleanTrue:NSAccessibilityEnabledAttribute];
}

-(BOOL)isSelected {
    return [self isAttributeBooleanTrue:NSAccessibilitySelectedAttribute];
}


-(NSArray *)attributes {
    NSArray *result = objc_getAssociatedObject(self, @"attributes");
    if (result == nil) {
        CFTypeRef attrsRef = NULL;
        AXUIElementCopyAttributeNames(self.elementRef, (CFArrayRef *)&attrsRef);
        result = CFBridgingRelease(attrsRef);
        objc_setAssociatedObject(self, @"attributes", result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

#pragma mark - Custom Functions
-(HAXElement *)childrenOfRole:(NSString *)role {
    NSArray *children = self.children;
    for (HAXElement *child in children) {
        if ([child isRoleEqual:role]) {
            return child;
        }
    }
    return NULL;
}
-(BOOL)isRoleEqual:(NSString *)role {
    return [self.role isEqualToString:role];
}

-(BOOL)canPerformAction:(NSString *)actionName {
    return [self.actions containsObject:actionName];
}


#pragma mark - Custom Attributes

-(NSString *)description {
    return [NSString stringWithFormat:@"<%@: “%@”> %@", self.role, self.title, self.subrole];
}

-(BOOL)isOpenable {
	return [self canPerformAction:kAXOpen];
}

-(BOOL)isPresseable {
	return [self canPerformAction:NSAccessibilityPressAction];
}


-(BOOL)hasAttribute:(NSString *)attribute {
    return [self.attributes containsObject:attribute];
}

#pragma mark - Private
-(NSArray *)getArrayOfAttribute:(NSString *)attribute {
    NSMutableArray *result = objc_getAssociatedObject(self, (__bridge const void *)(attribute));
    if (result == nil) {
        NSArray *axObjects = CFBridgingRelease([self copyAttributeValueForKey:attribute error:nil]);
        result = [NSMutableArray arrayWithCapacity:[axObjects count]];
        
        for (id axObject in axObjects) {
            [result addObject:[HAXElement elementWithElementRef:(AXUIElementRef)axObject]];
        }
    }
	return result;
}

-(BOOL)isAttributeBooleanTrue:(NSString *)attribute {
    CFBooleanRef val = [self copyAttributeValueForKey:attribute error:nil];
    BOOL result;
    if (val && CFGetTypeID(val) == CFBooleanGetTypeID()){
        result = CFBooleanGetValue(val);
    } else {
        result = NO;
    }
    
    if (val) {
        CFRelease(val);
    }
    return result;
}

@end
