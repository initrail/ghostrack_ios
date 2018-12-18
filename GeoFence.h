//
//  GeoFence.h
//  Location
//
//  Created by Daniel Kalam on 3/8/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface GeoFence : NSObject
@property (nonatomic) CLLocationCoordinate2D center;
@property int enter;
@property int exit;
@property double radius;
@property bool firstEnter;
@property bool enabled;
-(instancetype)initWithCenter:(CLLocationCoordinate2D)center radius:(double) radius;
@end
