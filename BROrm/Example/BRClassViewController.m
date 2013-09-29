//
//  BRClassViewController.m
//  BROrm
//
//  Created by Cornelius Horstmann on 14.09.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import "BRClassViewController.h"
#import "BRClass.h"

@interface BRClassViewController (){
    BRClass *_class;
}

@end

@implementation BRClassViewController

- (id)initWithClass:(BRClass*)class{
    self = [self initWithNibName:@"BRClassViewController" bundle:NULL];
    if(self){
        _class = class;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _nameTextField.text = _class[@"name"];
}

- (IBAction)nameDidChange:(id)sender {
    _class[@"name"] = _nameTextField.text;
    [_class save];
}
@end
