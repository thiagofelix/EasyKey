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
//  HAXElement+Utilities.h
//  
//
//  Created by Thiago Felix on 12/2/14.
//

#import "HAXElement.h"

extern NSString *kAXOpen;

@interface HAXElement (Utilities)
@property (nonatomic, readonly) HAXElement* parent;
@property (nonatomic, readonly) CGPoint origin;
@property (nonatomic, readonly) CGPoint center;
@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *role;
@property (nonatomic, readonly) NSString *subrole;
@property (nonatomic, readonly) NSArray *visibleCells;
@property (nonatomic, readonly) NSArray *visibleRows;
@property (nonatomic, readonly) NSArray *visibleChildren;
@property (nonatomic, readonly) NSArray *children;
@property (nonatomic, readonly) NSArray *actions;
@property (nonatomic, readonly) NSArray *attributes;
@property (nonatomic, readonly, getter=isPresseable) BOOL presseable;
@property (nonatomic, readonly, getter=isOpenable) BOOL openable;
@property (nonatomic, readonly, getter=isSelected) BOOL selected;
@property (nonatomic, readonly, getter=isEnabled) BOOL enabled;

-(BOOL)performAction:(NSString *)actionName;
-(BOOL)performOpen;
-(BOOL)performPress;
-(BOOL)canPerformAction:(NSString *)actionName;
-(BOOL)isRoleEqual:(NSString *)role;
-(BOOL)hasAttribute:(NSString *)attribute;

-(HAXElement *)childrenOfRole:(NSString *)role;
@end
