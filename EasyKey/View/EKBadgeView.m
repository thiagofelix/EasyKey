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
//  EKBadgeView.m
//  EasyKey
//
//  Created by Thiago Felix on 12/2/14.
//

#import "EKBadgeView.h"
#import "HAXElement+Utilities.h"

@interface EKBadgeView ()
@property (nonatomic, readwrite) BOOL match;
@property (nonatomic, assign) NSRange range;
@property (nonatomic, assign) NSRect textRect;
@property (nonatomic, assign) NSRect bounds;
@property (nonatomic, assign) NSSize textSize;
@property (nonatomic, assign) NSPoint centerPoint;
@end

@implementation EKBadgeView
@synthesize element;

+(EKBadgeView *)badgeWithElement:(HAXElement *)element andText:(NSString *)text {
    return [[EKBadgeView alloc] initWithElement:element andText:text];
}

+(NSDictionary *) fontAttrs {
    static NSDictionary* fontAttrsDict = nil;
    
    if (fontAttrsDict == nil){
        NSMutableParagraphStyle *paragraphyStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphyStyle setAlignment:NSCenterTextAlignment];
        
        NSColor* fgColor = [NSColor blackColor];
        NSFont* font = [NSFont boldSystemFontOfSize:10];
        
        
        fontAttrsDict = @{
                          NSParagraphStyleAttributeName  : paragraphyStyle,
                          NSForegroundColorAttributeName : fgColor,
                          NSFontAttributeName            : font
                          };
    }
    
    return fontAttrsDict;
}

-(id)initWithElement:(HAXElement *)e andText:(NSString *)text {
    self = [super init];
    if (self) {
        self.text = text;
        self.element = e;
    }
    return self;
}

-(void)drawBg {
    
    [NSGraphicsContext saveGraphicsState];
    
    NSShadow* theShadow = [[NSShadow alloc] init];
    [theShadow setShadowOffset:NSMakeSize(3.0, -3.0)];
    [theShadow setShadowBlurRadius:8.0];
    
    [theShadow setShadowColor:[[NSColor blackColor]
                               colorWithAlphaComponent:0.3]];
    
    [theShadow set];
    
    [[NSColor colorWithCalibratedRed:0.890 green:0.745 blue:0.137 alpha:1] set];
    [NSBezierPath fillRect:CGRectInset(self.bounds, -2, -2)];
    
    [NSGraphicsContext restoreGraphicsState];
    
    
    NSColor *startingColor = [NSColor colorWithCalibratedRed:1.000 green:0.886 blue:0.412 alpha:1];
    NSColor *endingColor = [NSColor colorWithCalibratedRed:0.992 green:0.780 blue:0.263 alpha:1];
    NSGradient* aGradient = [[NSGradient alloc]
                             initWithStartingColor:startingColor
                             endingColor:endingColor];
    [aGradient drawInRect:self.bounds angle:90];
    
}

-(NSRect)bounds {
    return CGRectInset(self.textRect, -1, -1);
}

-(NSSize)textSize {
    NSSize min = CGSizeMake(20, 10);
    NSSize size = [self.text sizeWithAttributes:[EKBadgeView fontAttrs]];
    return CGSizeMake(MAX(min.width, size.width), MAX(min.height, size.height));
}

-(NSRect)textRect {
    NSPoint point = self.centerPoint;
    NSSize size = self.textSize;
    return CGRectMake(point.x, point.y, size.width, size.height);
}

-(void)drawText {
    
    [NSGraphicsContext saveGraphicsState];
    
    [self.text drawInRect:self.textRect
           withAttributes:[EKBadgeView fontAttrs]];
    
    [NSGraphicsContext restoreGraphicsState];
    
}

-(NSPoint)centerPoint{
    NSRect frame = element.frame;
    NSSize size = self.textSize;
    return NSMakePoint(CGRectGetMidX(frame) - size.width/2, CGRectGetMidY(frame) - size.height/2);
}

-(void)draw {
    if (self.range.location == 0) {
        [self drawBg];
        [self drawText];
    }
}

-(void)update:(NSString *)query {
    if (query.length == 0) {
        self.range = NSMakeRange(0, 0);
        self.match = NO;
    } else {
        self.range = [self.text rangeOfString:[query uppercaseString]];
        self.match = self.range.location == 0 && self.range.length == self.text.length;
    }
}

@end
