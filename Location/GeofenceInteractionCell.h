//
//  GeofenceInteractionCell.h
//  Location
//
//  Created by Daniel Kalam on 3/8/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeofenceInteractionCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *geoEnter;
@property (strong, nonatomic) IBOutlet UILabel *geoLeave;
@property (strong, nonatomic) IBOutlet UILabel *geoLat;
@property (strong, nonatomic) IBOutlet UILabel *geoLong;

@end
