//
//  LocationHistoryView.h
//  Location
//
//  Created by Daniel Kalam on 2/23/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LocationHistoryCell.h"

#import "LocationDatabase.h"

#import <UIKit/UIKit.h>

@protocol senddataProtocol <NSObject>

-(void)sendDataToA:(NSInteger *)trackId;

@end

@interface LocationHistoryView : UICollectionViewController
@property (strong, nonatomic) NSArray* locationHistory;
@property (strong, nonatomic) LocationDataBase* locationDB;
@property (strong, nonatomic) NSString* userName;
@property (nonatomic, assign)id delegate;
@property (nonatomic) NSInteger trackId;

@end
