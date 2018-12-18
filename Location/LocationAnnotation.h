//
//  NSObject+LocationAnnotation.h
//  Location
//
//  Created by Daniel Kalam on 2/11/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface LocationAnnotation: NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (nonatomic) double speed;
-(id)initWithTitle:(NSString*) newTitle Location:(CLLocationCoordinate2D)location;
-(MKAnnotationView*)annotationView;

@end
