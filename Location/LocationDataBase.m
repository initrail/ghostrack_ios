//
//  LocationDataBase.m
//  Location
//
//  Created by Daniel Kalam on 2/19/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import "LocationDataBase.h"
#import "sqlite3.h"

@interface LocationDataBase()
@property (nonatomic, strong) NSString* documentsDirectory;
@property (nonatomic, strong) NSString* databaseFilename;
@property (nonatomic, strong) NSMutableArray* arrResults;

-(void)copyDatabaseIntoDocumentsDirectory;
-(void)runQuery:(const char*)query isQueryExecutable:(BOOL)queryExecutable;

@end
@implementation LocationDataBase

-(instancetype)initWithDataBaseFilename:(NSString *)dbFilename{
    self = [super init];
    if(self){
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        self.databaseFilename = dbFilename;
        [self copyDatabaseIntoDocumentsDirectory];
    }
    [self checkOrInitDatabases];
    return self;
}

-(void)copyDatabaseIntoDocumentsDirectory{
    NSString* destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    if([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]){
        NSString* sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError* error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        if(error!=nil){
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

-(void)runQuery:(const char*)query isQueryExecutable:(BOOL)queryExecutable{
    sqlite3* sqlite3Database;
    NSString* databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    if(self.arrResults!=nil){
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    self.arrResults = [[NSMutableArray alloc] init];
    if(self.arrColumnNames!=nil){
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [[NSMutableArray alloc] init];
    if(sqlite3_open([databasePath UTF8String], &sqlite3Database) == SQLITE_OK){
        sqlite3_stmt* compiledStatement;
        if(sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL) == SQLITE_OK){
            if(!queryExecutable){
                NSMutableArray* arrDataRow;
                while(sqlite3_step(compiledStatement)==SQLITE_ROW){
                    arrDataRow = [[NSMutableArray alloc] init];
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    for(int i = 0; i<totalColumns; i++){
                        char* dbDataAsChars = (char*) sqlite3_column_text(compiledStatement, i);
                        if(dbDataAsChars != NULL){
                            [arrDataRow addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                        if(self.arrColumnNames.count != totalColumns){
                            dbDataAsChars = (char*)sqlite3_column_name(compiledStatement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                            
                        }
                    }
                    if(arrDataRow.count>0){
                        [self.arrResults addObject:arrDataRow];
                    }
                }
            } else {
                if(sqlite3_step(compiledStatement)==SQLITE_DONE){
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    self.lastInsertedRowId = sqlite3_last_insert_rowid(sqlite3Database);
                } else {
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
        } else {
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(sqlite3Database);
}

-(NSArray*)loadDataFromDB:(NSString *)query{
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    return (NSArray*)self.arrResults;
}

-(void)executeQuery:(NSString*)query{
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}

-(void)checkOrInitDatabases{
    [self loadDataFromDB:@"SELECT name FROM sqlite_master WHERE type='table' AND name='users'"];
    if([self.arrResults count]==0)
        [self executeQuery:@"create table users(name varchar(50) primary key, phone varchar(15), email varchar(50))"];
    [self loadDataFromDB:@"SELECT name FROM sqlite_master WHERE type='table' AND name='locationHistory'"];
    if([self.arrResults count]==0)
        [self executeQuery:@"CREATE TABLE locationHistory(name varchar(50), trackIteration int secondary key, startTime varchar(30), stopTime varchar(30))"];
    [self loadDataFromDB:@"SELECT name FROM sqlite_master WHERE type='table' AND name='locationHistoryDetail'"];
    if([self.arrResults count]==0)
        [self executeQuery:@"CREATE TABLE locationHistoryDetail(name varchar(50), trackIteration int secondary key, longitude double, latitude double, speed double, time varchar(30))"];
    [self loadDataFromDB:@"SELECT name FROM sqlite_master WHERE type='table' AND name='geofences'"];
    if([self.arrResults count]==0)
        [self executeQuery:@"CREATE TABLE geofences(longitude double, latitude double, radius double)"];
    [self loadDataFromDB:@"SELECT name FROM sqlite_master WHERE type='table' AND name='geofenceInteraction'"];
    if([self.arrResults count]==0)
        [self executeQuery:@"CREATE TABLE geofenceInteraction(name varchar(50), geoId int secondary key, enterTime varchar(30), exitTime varchar(30))"];
}

@end
