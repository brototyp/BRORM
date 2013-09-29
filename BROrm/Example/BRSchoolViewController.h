//
//  BRSchoolViewController.h
//  BROrm
//
//  Created by Cornelius Horstmann on 13.09.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BRSchool;

@interface BRSchoolViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *classesButton;
@property (weak, nonatomic) IBOutlet UIButton *studentsButton;

- (IBAction)nameDidChange:(id)sender;
- (IBAction)showClasses:(id)sender;
- (IBAction)showStudents:(id)sender;

- (IBAction)delete:(id)sender;


- (id)initWithSchool:(BRSchool*)school;

@end
