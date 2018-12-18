//
//  NSObject+LocationAnnotation.m
//  Location
//
//  Created by Daniel Kalam on 2/11/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import "LocationAnnotation.h"

@implementation LocationAnnotation : NSObject
-(id)initWithTitle:(NSString*)newTitle Location:(CLLocationCoordinate2D)location{
    self = [super init];
    if(self){
        _title = newTitle;
        _coordinate = location;
    }
    return self;
}
-(MKAnnotationView*)annotationView{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"MyCustomAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.image = [UIImage imageNamed:@"red_dot"];
    return annotationView;
}

@end
