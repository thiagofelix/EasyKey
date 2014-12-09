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
//  EKHints.m
//  EasyKey
//
//  Created by Thiago Felix on 12/2/14.
//

#import <Foundation/Foundation.h>
#import "EKHints.h"

@implementation EKHints
+(NSArray *)hintcharacters{
    static NSArray *_hintcharacters;
    if (!_hintcharacters) {
        _hintcharacters = @[@"H",@"J",@"K",@"L",@"A",@"S",@"D",@"F",@"G",
                            @"Q",@"W",@"E",@"R",@"T",@"Y",@"U",@"I",@"O",@"P",
                            @"Z",@"X",@"C",@"V",@"B",@"N",@"M"];
    }
    return _hintcharacters;
}

+ (NSArray *)reverseArray:(NSArray *)array {
    NSMutableArray *reverse = [NSMutableArray arrayWithCapacity:[array count]];
    NSEnumerator *enumerator = [array reverseObjectEnumerator];
    for (id element in enumerator) {
        [reverse addObject:element];
    }
    return array;
}

+ (NSString *)reverseString:(NSString *)string {
    return [[EKHints reverseArray:[string componentsSeparatedByString:@""]] componentsJoinedByString:@""];
}

+(NSString *)genCodeWord:(NSInteger)N length:(NSInteger)length{
    NSArray *hintcharacters = [EKHints hintcharacters];
    
    NSMutableString *word = [NSMutableString string];
    for (int i = 0; i < length; i++) {
        [word appendString:[hintcharacters objectAtIndex:N % hintcharacters.count]];
        N = floor(N / hintcharacters.count);
    }
    return [EKHints reverseString:word];
}

// Golomb
// https://github.com/1995eaton/chromium-vim/blob/master/content_scripts/EKHints.js
+(NSArray *)genHints:(NSUInteger)M {
    NSArray *hintcharacters = [EKHints hintcharacters];
    if (M <= hintcharacters.count) {
        return [hintcharacters subarrayWithRange:NSMakeRange(0, M)];
    }
    
    double b = ceil(log(M) / log(hintcharacters.count));
    double cutoff = pow(hintcharacters.count, b) - M;
    double cutoffR = floor(cutoff / hintcharacters.count);
    
    NSMutableArray *codes = [NSMutableArray array];
    for (int i = 0; i < cutoffR; i++) {
        [codes addObject:[EKHints genCodeWord:i length:b]];
    }
    
    for (int i = cutoffR; i < M; i++) {
        [codes addObject:[EKHints genCodeWord:i + cutoff length:b]];
    }
    
    return codes;
}
@end
