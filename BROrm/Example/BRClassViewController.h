//
//  BRClassViewController.h
//  BROrm
//
//  Created by Cornelius Horstmann on 14.09.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BRClass;

@interface BRClassViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

- (IBAction)nameDidChange:(id)sender;
- (id)initWithClass:(BRClass*)class;

@end
