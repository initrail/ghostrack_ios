//
//  CreateUserView.m
//  Location
//
//  Created by Daniel Kalam on 2/21/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import "CreateUserView.h"

@implementation CreateUserView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationDB = [[LocationDataBase alloc] initWithDataBaseFilename:@"locationfinal.sqlite"];
}

- (IBAction)createUser:(id)sender {
    NSString* insertQuery = [NSString stringWithFormat:@"insert into users values('%@', '%@', '%@')", self.userName.text, self.userPhone.text, self.userEmail.text];
    [self.locationDB executeQuery:insertQuery];
    if (self.locationDB.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.locationDB.affectedRows);
        
        // Pop the view controller.
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSLog(@"Could not execute the query.");
        [self.locationDB executeQuery:@"create table users(name varchar(50) primary key, phone varchar(15), email varchar(50))"];
        [self.locationDB executeQuery:insertQuery];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
