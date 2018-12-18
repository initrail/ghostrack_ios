//
//  ViewController.m
//  Location
//
//  Created by Daniel Kalam on 2/11/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import "MapView.h"
#import "LocationAnnotation.h"
#import "math.h"

@implementation MapView {
    CLLocationManager *locationManager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.map.delegate = self;
    locationManager = [[CLLocationManager alloc] init];
    self.locationDB = [[LocationDataBase alloc] initWithDataBaseFilename:@"locationfinal.sqlite"];
    self.usersTable.delegate = self;
    self.usersTable.dataSource = self;
    self.usersTable.hidden = YES;
    _geoFences = [[NSMutableArray alloc] init];
}

-(IBAction)foundTap:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.map];
    point.y+=170;
    CLLocationCoordinate2D tapPoint = [self.map convertPoint:point toCoordinateFromView:self.view];
    GeoFence *location = [[GeoFence alloc] initWithCenter:tapPoint radius:100];
    [_geoFences addObject:location];
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:tapPoint radius:100];
    [self.map addOverlay:circle];
    NSString* insert = [NSString stringWithFormat:@"insert into geofences values (%f, %f, %f)",tapPoint.longitude, tapPoint.latitude, 100.0];
    [self.locationDB executeQuery:insert];
    if (self.locationDB.affectedRows != 0) {
        //NSLog(@"Query was executed successfully. Affected rows = %d", self.locationDB.affectedRows);
    }
    else{
        //NSLog(@"Could not execute the query.");
    }
}


-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
    circleRenderer.fillColor = [UIColor greenColor];
    circleRenderer.alpha = .25f;
    return circleRenderer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil) {
        CLLocationCoordinate2D location;
        location.latitude = currentLocation.coordinate.latitude;
        location.longitude = currentLocation.coordinate.longitude;
        LocationAnnotation *me = [[LocationAnnotation alloc] initWithTitle:@"Me" Location:location];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, 500, 500);
        MKCoordinateRegion adjustedRegion = [_map regionThatFits:viewRegion];
        NSMutableArray *locs = [[NSMutableArray alloc] init];
        for (id <MKAnnotation> annot in [_map annotations])
        {
            [locs addObject:annot];
        }
        [_map removeAnnotations:locs];
        locs = nil;
        [_map addAnnotation:me];
        [self.map setRegion:adjustedRegion animated:YES];
        
        [locationManager stopUpdatingLocation];
        NSString* insertQuery = [NSString stringWithFormat:@"insert into locationHistoryDetail values('%@', %ld, %1f, %1f, %1f, '%@')", self.userName, (long)self.trackId, currentLocation.coordinate.longitude, currentLocation.coordinate.latitude, currentLocation.speed, [NSDate date]];
        [self.locationDB executeQuery:insertQuery];
        if (self.locationDB.affectedRows != 0) {
            NSLog(@"Query was executed successfully. Affected rows = %d", self.locationDB.affectedRows);
        }
        else{
            NSLog(@"Could not execute the query.");
        }
        [self checkForRegion:location];
    }
}

-(void)checkForRegion:(CLLocationCoordinate2D)location{
    for(int i = 0; i<[self.geoFences count]; i++){
        MKMapPoint point1 = MKMapPointForCoordinate(location);
        GeoFence *fence=[self.geoFences objectAtIndex:i];
        MKMapPoint point2 = MKMapPointForCoordinate(fence.center);
        CLLocationDistance distance = MKMetersBetweenMapPoints(point1, point2);
        if(fence.enabled){
            if(distance<fence.radius-5&&!fence.firstEnter){
                fence.enter++;
                if(fence.enter==2){
                    fence.enter = 0;
                    fence.firstEnter = YES;
                    NSString* select = [NSString stringWithFormat:@"SELECT rowid FROM geofences WHERE longitude = %f and latitude = %f", fence.center.longitude, fence.center.latitude];
                    NSArray* rowId = [[NSArray alloc] initWithArray:[self.locationDB loadDataFromDB:select]];
                    NSInteger geoId = 0;
                    if([rowId count]==1)
                        geoId = [[NSString stringWithFormat:@"%@", [[rowId objectAtIndex:0] objectAtIndex:0]] integerValue];
                    NSString* userInteraction = [NSString stringWithFormat:@"SELECT enterTime from geofenceInteraction where name = '%@'and rowid = %li", self.userName, geoId];
                    NSArray* exists = [[NSArray alloc] initWithArray:[self.locationDB loadDataFromDB:userInteraction]];
                    if([exists count]>0){
                        NSLog(@"This user has entered this geofence before, updating the enterTime");
                        NSString* insert = [NSString stringWithFormat:@"update geofenceInteraction set enterTime='%@' where rowid = %li and name = '%@'",[NSDate date], (long)geoId, self.userName];
                        [self.locationDB executeQuery:insert];
                        if (self.locationDB.affectedRows != 0) {
                            //NSLog(@"Query was executed successfully. Affected rows = %d", self.locationDB.affectedRows);
                        }
                        else{
                            //NSLog(@"Could not execute the query.");
                        }
                    } else {
                        NSLog(@"This user has not entered this geofence before, creating new row");
                        NSString* insert = [NSString stringWithFormat:@"INSERT INTO geofenceInteraction values('%@', %li, '%@', '%@')", self.userName, (long)geoId, [NSDate date], @"Never"];
                        [self.locationDB executeQuery:insert];
                        if (self.locationDB.affectedRows != 0) {
                            //NSLog(@"Query was executed successfully. Affected rows = %d", self.locationDB.affectedRows);
                        }
                        else{
                            //NSLog(@"Could not execute the query.");
                        }
                    }
                    NSLog(@"GeoFence was entered!!!");
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:7];
                    notification.alertBody = [NSString stringWithFormat:@"%@ has entered a location on the map.", self.userName];
                    notification.timeZone = [NSTimeZone defaultTimeZone];
                    notification.soundName = UILocalNotificationDefaultSoundName;
                    notification.applicationIconBadgeNumber = 10;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                }
            } else if(distance>fence.radius+5&&fence.firstEnter){
                fence.exit++;
                if(fence.exit==2){
                    fence.exit = 0;
                    fence.firstEnter = NO;
                    NSString* select = [NSString stringWithFormat:@"SELECT rowid FROM geofences WHERE longitude = %f and latitude = %f", fence.center.longitude, fence.center.latitude];
                    NSArray* rowId = [[NSArray alloc] initWithArray:[self.locationDB loadDataFromDB:select]];
                    NSInteger geoId = 0;
                    if([rowId count]==1)
                        geoId = [[NSString stringWithFormat:@"%@", [[rowId objectAtIndex:0] objectAtIndex:0]] integerValue];
                    NSString* insert = [NSString stringWithFormat:@"update geofenceInteraction set exitTime='%@' where rowid = %li and name = '%@'",[NSDate date], (long)geoId, self.userName];
                    [self.locationDB executeQuery:insert];
                    if (self.locationDB.affectedRows != 0) {
                        NSLog(@"Query was executed successfully. Affected rows = %d", self.locationDB.affectedRows);
                    }
                    else{
                        NSLog(@"Could not execute the query.");
                    }
                    NSLog(@"GeoFence was exited!!!");
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:7];
                    notification.alertBody = [NSString stringWithFormat:@"%@ has entered a location on the map.", self.userName];
                    notification.timeZone = [NSTimeZone defaultTimeZone];
                    notification.soundName = UILocalNotificationDefaultSoundName;
                    notification.applicationIconBadgeNumber = 10;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                }
            }
        }
    }
}

-(MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(nonnull id<MKAnnotation>)annotation{
    if([annotation isKindOfClass:[LocationAnnotation class]]){
        LocationAnnotation* myLocation = (LocationAnnotation*)annotation;
        MKAnnotationView* annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MyCustomAnnotation"];
        if(annotationView == nil)
            annotationView = (MKAnnotationView*)myLocation.annotationView;
        else
            annotationView.annotation = annotation;
        UILabel* detail = [[UILabel alloc] init];
        detail.text = [NSString stringWithFormat:@"Speed: %fm/s\nLatitude: %f\nLongitude %f", myLocation.speed, myLocation.coordinate.latitude, myLocation.coordinate.longitude];
        annotationView.detailCalloutAccessoryView = detail;
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:detail attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
        [detail setNumberOfLines:3];
        [detail addConstraint:height];
        return annotationView;
    }
    else
        return nil;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            // do some error handling
        }
            break;
        default:{
            [locationManager startUpdatingLocation];
        }
            break;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.users count];
}
-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSInteger indexOfName = [self.locationDB.arrColumnNames indexOfObject:@"name"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"Cell"];
    }
    // Set the loaded data to the appropriate cell labels.
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.users objectAtIndex:indexPath.row] objectAtIndex:indexOfName]];
    
    return cell;
}
-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    UITableViewCell* cell = [self.usersTable cellForRowAtIndexPath:indexPath];
    [self.selectUser setTitle:cell.textLabel.text forState:UIControlStateNormal];
    [self.userLabel setText:cell.textLabel.text];
    [self.userLabelTracking setText:cell.textLabel.text];
    self.userName = cell.textLabel.text;
    self.usersTable.hidden = YES;
}

- (IBAction)getCurrentLocation:(id)sender {
    if(self.userName!=nil){
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
            if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedAlways){
                if([self.timer isValid]){
                    self.userButton.enabled = YES;
                    self.selectUser.enabled = YES;
                    self.createUser.enabled = YES;
                    [self.tracking setTitle:@"Start Tracking: " forState:UIControlStateNormal];
                    [self.timer invalidate];
                    self.timer = nil;
                    NSString* endTime = [NSString stringWithFormat:@"%@",[NSDate date]];
                    NSString* insertQuery = [NSString stringWithFormat:@"insert into locationHistory values('%@', %ld, '%@', '%@')", self.userName, (long)self.trackId, self.startTime, endTime];
                    [self.locationDB executeQuery:insertQuery];
                    if (self.locationDB.affectedRows != 0) {
                        //NSLog(@"Query was executed successfully. Affected rows = %d", self.locationDB.affectedRows);
                    }
                    else{
                        //NSLog(@"Could not execute the query.");
                    }
                } else {
                    [self initTrackIdAndStartTime];
                    [self.tracking setTitle:@"Stop Tracking: " forState:UIControlStateNormal];
                    [self getLocation];
                    self.userButton.enabled = NO;
                    self.selectUser.enabled = NO;
                    self.createUser.enabled = NO;
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(getLocation) userInfo:nil repeats:YES];
                }
            } else {
                [locationManager requestAlwaysAuthorization];
                [locationManager stopUpdatingLocation];
            }
        }
    }
}
-(void)getLocation{
    [locationManager startUpdatingLocation];
}
-(void)loadData{
    // Form the query.
    NSString *query = @"select name from users";
    
    // Get the results.
    if (self.users != nil) {
        self.users = nil;
    }
    self.users = [[NSArray alloc] initWithArray:[self.locationDB loadDataFromDB:query]];
    
    // Reload the table view.
    [self.usersTable reloadData];
}

- (IBAction)selectUser:(id)sender {
    if(self.usersTable.hidden == YES)
        self.usersTable.hidden = NO;
    else
        self.usersTable.hidden = YES;
    [self loadData];
}

- (IBAction)createGeoFences:(id)sender {
    if(_tapRecognizer==nil){
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foundTap:)];
        
        self.tapRecognizer.numberOfTapsRequired = 1;
        
        self.tapRecognizer.numberOfTouchesRequired = 1;
        
        self.userButton.enabled = NO;
        self.selectUser.enabled = NO;
        self.createUser.enabled = NO;
        self.tracking.enabled = NO;
        if([self.usersTable isHidden]==NO)
            [self.usersTable setHidden:YES];
        [self.map addGestureRecognizer:self.tapRecognizer];
    } else {
        self.userButton.enabled = YES;
        self.selectUser.enabled = YES;
        self.createUser.enabled = YES;
        self.tracking.enabled = YES;
        [self.map removeGestureRecognizer:self.tapRecognizer];
        self.tapRecognizer = nil;
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"LocationHistorySegue"]){
        LocationHistoryView* view;
        view = [segue destinationViewController];
        view.userName = self.userName;
        view.delegate = self;
    } else if([segue.identifier isEqualToString:@"GeofenceInteractionSegue"]){
        GeofenceInteractionView* view;
        view = [segue destinationViewController];
        view.userName = self.userName;
    }
}
-(void)sendDataToA:(NSInteger)trackId
{
    self.trackId = trackId;
    [self plotMap];
}

-(void)plotMap{
    if(self.trackId>0){
        NSMutableArray *locs = [[NSMutableArray alloc] init];
        for (id <MKAnnotation> annot in [_map annotations])
        {
            [locs addObject:annot];
        }
        [_map removeAnnotations:locs];
        locs = nil;
        NSString* query = [NSString stringWithFormat:@"SELECT longitude, latitude, speed, time from locationHistoryDetail where trackIteration = %ld and name = '%@'", _trackId, self.userName];
        self.plotPoints = [[NSArray alloc] initWithArray:[self.locationDB loadDataFromDB:query]];
        double lowestLat = [[NSString stringWithFormat:@"%@", [[self.plotPoints objectAtIndex:0] objectAtIndex:1]] doubleValue];
        double highestLat = lowestLat;
        double lowestLong = [[NSString stringWithFormat:@"%@", [[self.plotPoints objectAtIndex:0] objectAtIndex:0]] doubleValue];
        double highestLong = lowestLong;
        for(int i = 0; i<self.plotPoints.count; i++){
            CLLocationCoordinate2D location;
            NSString* time = [NSString stringWithFormat:@"%@", [[self.plotPoints objectAtIndex:i] objectAtIndex:3]];
            location.longitude = [[NSString stringWithFormat:@"%@", [[self.plotPoints objectAtIndex:i] objectAtIndex:0]] doubleValue];
            location.latitude = [[NSString stringWithFormat:@"%@", [[self.plotPoints objectAtIndex:i] objectAtIndex:1]] doubleValue];
            LocationAnnotation *plot = [[LocationAnnotation alloc] initWithTitle:time Location:location];
            plot.speed = [[NSString stringWithFormat:@"%@", [[self.plotPoints objectAtIndex:i]objectAtIndex:2]] doubleValue];
            [self.map addAnnotation:plot];
            if(location.latitude>highestLat){
                highestLat = location.latitude;
            }
            if(location.latitude<lowestLat){
                lowestLat = location.latitude;
            }
            if(location.longitude>highestLong){
                highestLong = location.longitude;
            }
            if(location.longitude<lowestLong){
                lowestLong = location.longitude;
            }
        }
        CLLocationCoordinate2D location;
        location.latitude = lowestLat+(highestLat-lowestLat)/2;
        location.longitude = lowestLong+(highestLong-lowestLong)/2;
        CLLocationCoordinate2D lowLat = CLLocationCoordinate2DMake(lowestLat, 0);
        CLLocationCoordinate2D highLat = CLLocationCoordinate2DMake(highestLat, 0);
        CLLocationCoordinate2D lowLong = CLLocationCoordinate2DMake(0, lowestLong);
        CLLocationCoordinate2D highLong = CLLocationCoordinate2DMake(0, highestLong);
        MKMapPoint point1 = MKMapPointForCoordinate(lowLat);
        MKMapPoint point2 = MKMapPointForCoordinate(highLat);
        MKMapPoint point3 = MKMapPointForCoordinate(lowLong);
        MKMapPoint point4 = MKMapPointForCoordinate(highLong);
        CLLocationDistance ydistance = MKMetersBetweenMapPoints(point1, point2);
        CLLocationDistance xdistance = MKMetersBetweenMapPoints(point3, point4);
        if(ydistance>xdistance)
            xdistance = ydistance;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, xdistance+100, xdistance+100);
        MKCoordinateRegion adjustedRegion = [_map regionThatFits:viewRegion];
        [self.map setRegion:adjustedRegion animated:YES];
    }
}

-(void)initTrackIdAndStartTime{
    self.startTime = [NSString stringWithFormat:@"%@", [NSDate date]];
    self.trackId = 0;
    NSString* selectTrackId = [NSString stringWithFormat:@"SELECT max(trackIteration) from locationHistory where name='%@'", self.userName];
    NSArray* id = [[NSArray alloc] initWithArray:[self.locationDB loadDataFromDB:selectTrackId]];
    if([id count]==1){
        self.trackId = [[NSString stringWithFormat:@"%@", [[id objectAtIndex:0] objectAtIndex:0]] integerValue];
    }
    self.trackId++;
}
@end

