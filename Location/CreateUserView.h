//
//  CreateUserView.h
//  Location
//
//  Created by Daniel Kalam on 2/21/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "LocationDataBase.h"

@interface CreateUserView : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userPhone;
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (strong, nonatomic) LocationDataBase *locationDB;
- (IBAction)createUser:(id)sender;

@end
