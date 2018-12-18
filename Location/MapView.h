//
//  ViewController.h
//  Location
//
//  Created by Daniel Kalam on 2/11/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

#import <CoreLocation/CoreLocation.h>

#import "LocationHistoryView.h"

#import "LocationDataBase.h"

#import "GeoFence.h"

#import "GeofenceInteractionView.h"

@interface MapView: UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) IBOutlet UITableView *usersTable;
@property (strong, nonatomic) IBOutlet UIButton *userButton;
@property (strong, nonatomic) IBOutlet UIButton *tracking;
@property (strong, nonatomic) IBOutlet UIButton *selectUser;
@property (strong, nonatomic) IBOutlet UIButton *createUser;
@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UILabel *userLabelTracking;
@property (strong, nonatomic) IBOutlet UIButton *plotLocations;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@property (nonatomic, strong) LocationDataBase *locationDB;
@property (nonatomic, strong) NSTimer* timer;

@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *plotPoints;
@property (nonatomic, strong) NSMutableArray *geoFences;

@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* startTime;
@property (nonatomic) NSInteger trackId;

- (IBAction)getCurrentLocation:(id)sender;
- (IBAction)selectUser:(id)sender;
- (IBAction)createGeoFences:(id)sender;

@end

