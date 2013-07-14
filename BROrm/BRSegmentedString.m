//
//  BRSegmentedString.m
//  BROrm
//
//  Created by Cornelius Horstmann on 23.06.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import "BRSegmentedString.h"

@implementation BRSegmentedString

- (id)initWithString:(NSString*)string{
    self = [super init];
    if(self){
        NSArray *ors = [BRSegmentedString splitStringForOr:string];
        if([ors count]==2){
            _type = BRNodeTypeOr;
            _left = [[BRSegmentedString alloc] initWithString:ors[0]];
            _right = [[BRSegmentedString alloc] initWithString:ors[1]];
            return self;
        }
        
        NSArray *ands = [BRSegmentedString splitStringForAnd:string];
        if([ands count]==2){
            _type = BRNodeTypeAnd;
            _left = [[BRSegmentedString alloc] initWithString:ands[0]];
            _right = [[BRSegmentedString alloc] initWithString:ands[1]];
            return self;
        }
        
        _type = BRNodeTypeValue;
        _value = string;
    }
    return self;
}


+ (NSArray*)splitStringForOr:(NSString*)string{
    if([string characterAtIndex:0] == '(' && [string characterAtIndex:[string length]-1] == ')'){
        string = [[string substringFromIndex:1] substringToIndex:[string length]-2];
    }
    NSMutableArray *returnIt = [NSMutableArray array];
    int d = 0;
    NSMutableString *buffer = [NSMutableString string];
    for(int i = 0;i<[string length];i++){
        unichar c = [string characterAtIndex:i];
        switch (c) {
            case '(':
                d++;
                break;
            case ')':{
                if(d){
                    d--;
                } else{
                    [buffer appendString:@")"];
                    [returnIt addObject:[buffer copy]];
		            buffer = [NSMutableString string];
                    i++;
		            continue;
                }
            }
                break;
            case '|':{
                if(!d && [returnIt count]==0){
                    [returnIt addObject:[buffer copy]];
		            buffer = [NSMutableString string];
		            continue;
                }
            }
                break;
            case ' ':
                if(d==0
                   && [string characterAtIndex:i+1] == 'o'
                   && [string characterAtIndex:i+2] == 'r'
                   && [string characterAtIndex:i+3] == ' '
                   && [returnIt count]==0){
                    [returnIt addObject:[buffer copy]];
		            buffer = [NSMutableString string];
                    i = i+3;
		            continue;
                }
                break;
                
            default:
                break;
        }
        [buffer appendFormat:@"%c",c];
    }
    if([buffer length]>0){
        [returnIt addObject:[buffer copy]];
        buffer = [NSMutableString string];
    }
    return returnIt;
}

+ (NSArray*)splitStringForAnd:(NSString*)string{
    if([string characterAtIndex:0] == '(' && [string characterAtIndex:[string length]-1] == ')'){
        string = [[string substringFromIndex:1] substringToIndex:[string length]-2];
    }
    NSMutableArray *returnIt = [NSMutableArray array];
    int d = 0;
    NSMutableString *buffer = [NSMutableString string];
    for(int i = 0;i<[string length];i++){
        unichar c = [string characterAtIndex:i];
        switch (c) {
            case '(':
                d++;
                break;
            case ')':{
                if(d>1){
                    d--;
                } else{
                    [buffer appendString:@")"];
                    [returnIt addObject:[buffer copy]];
		            buffer = [NSMutableString string];
		            continue;
                }
            }
            case ',':{
                if(!d && [returnIt count]==0){
                    [returnIt addObject:[buffer copy]];
		            buffer = [NSMutableString string];
		            continue;
                }
            }
                break;
            case ' ':
                if(d==0
                   && [string characterAtIndex:i+1] == 'a'
                   && [string characterAtIndex:i+2] == 'n'
                   && [string characterAtIndex:i+3] == 'd'
                   && [string characterAtIndex:i+4] == ' '
                   && [returnIt count]==0){
                    [returnIt addObject:[buffer copy]];
		            buffer = [NSMutableString string];
                    i = i+4;
		            continue;
                }
                break;
                
            default:
                break;
        }
        [buffer appendFormat:@"%c",c];
    }
    if([buffer length]>0){
        [returnIt addObject:[buffer copy]];
        buffer = [NSMutableString string];
    }
    return returnIt;
}

@end
