//
//  GeofenceInteractionView.h
//  Location
//
//  Created by Daniel Kalam on 3/8/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationDataBase.h"
#import "GeofenceInteractionCell.h"
@interface GeofenceInteractionView : UICollectionViewController
@property (strong, nonatomic) NSArray* geofenceInteraction;
@property (strong, nonatomic) LocationDataBase* locationDB;
@property (strong, nonatomic) NSString* userName;
@property (nonatomic, assign)id delegate;
@property (nonatomic) NSInteger trackId;
@end
