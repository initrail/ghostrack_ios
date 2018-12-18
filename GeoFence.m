//
//  GeoFence.m
//  Location
//
//  Created by Daniel Kalam on 3/8/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import "GeoFence.h"

@implementation GeoFence
-(instancetype)initWithCenter:(CLLocationCoordinate2D)center radius:(double) radius{
    self = [super init];
    if(self){
        self.center = center;
        self.radius = radius;
        self.enter = 0;
        self.exit = 0;
        self.firstEnter = NO;
        self.enabled=YES;
    }
    return self;
}
@end
