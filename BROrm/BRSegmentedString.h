//
//  BRSegmentedString.h
//  BROrm
//
//  Created by Cornelius Horstmann on 23.06.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BRNodeTypeAnd,
    BRNodeTypeOr,
    BRNodeTypeValue
} BRNodeType;

@interface BRSegmentedString : NSObject

@property (nonatomic,readonly) BRNodeType type;
@property (nonatomic,readonly) BRSegmentedString *left;
@property (nonatomic,readonly) BRSegmentedString *right;
@property (nonatomic,readonly) NSString *value;

- (id)initWithString:(NSString*)string;

+ (NSArray*)splitStringForOr:(NSString*)string;
+ (NSArray*)splitStringForAnd:(NSString*)string;

@end
