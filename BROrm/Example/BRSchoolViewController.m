//
//  BRSchoolViewController.m
//  BROrm
//
//  Created by Cornelius Horstmann on 13.09.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import "BRSchoolViewController.h"
#import "BRSchool.h"
#import "BRClassListViewController.h"

@interface BRSchoolViewController (){
    BRSchool *_school;
}

@end

@implementation BRSchoolViewController


- (id)initWithSchool:(BRSchool*)school{
    self = [self initWithNibName:@"BRSchoolViewController" bundle:NULL];
    if(self){
        _school = school;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _nameTextField.text = _school[@"name"];
    [_classesButton setTitle:[NSString stringWithFormat:@"%i Classes",_school.numberOfClasses] forState:UIControlStateNormal];
}

- (IBAction)nameDidChange:(id)sender {
    _school[@"name"] = _nameTextField.text;
    [_school save];
}

- (IBAction)showClasses:(id)sender {
    
    BRClassListViewController *classListViewController = [[BRClassListViewController alloc] initWithSchool:_school];
    [self.navigationController pushViewController:classListViewController animated:YES];
    
}

- (IBAction)showStudents:(id)sender {
}

- (IBAction)delete:(id)sender {
    [_school destroy];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
