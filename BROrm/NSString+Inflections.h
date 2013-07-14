//
//  NSString+Inflections.h
//  BROrm
//
//  Created by Cornelius Horstmann on 17.06.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Inflections)
- (NSString *)underscore;
- (NSString *)camelcase;
- (NSString *)classify;
@end
