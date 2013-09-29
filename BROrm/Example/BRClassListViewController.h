//
//  BRClassListViewController.h
//  BROrm
//
//  Created by Cornelius Horstmann on 13.09.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BRSchool;

@interface BRClassListViewController : UITableViewController

- (id)initWithSchool:(BRSchool*)school;

@end
