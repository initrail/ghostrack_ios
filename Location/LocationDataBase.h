//
//  LocationDataBase.h
//  Location
//
//  Created by Daniel Kalam on 2/19/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationDataBase : NSObject

@property (nonatomic, strong) NSMutableArray* arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowId;

-(instancetype)initWithDataBaseFilename:(NSString*) dbFilename;

-(NSArray*)loadDataFromDB:(NSString *) query;
-(void)executeQuery:(NSString*) query;

@end
