//
//  GeofenceInteractionView.m
//  Location
//
//  Created by Daniel Kalam on 3/8/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import "GeofenceInteractionView.h"

@interface GeofenceInteractionView ()

@end

@implementation GeofenceInteractionView

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationDB = [[LocationDataBase alloc] initWithDataBaseFilename:@"locationfinal.sqlite"];
    NSString* query = [NSString stringWithFormat:@"SELECT * FROM geofenceInteraction where name = '%@' order by rowid desc", self.userName];
    self.geofenceInteraction = [[NSArray alloc] initWithArray:[self.locationDB loadDataFromDB:query]];
    NSLog(@"Pause");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of items
    return self.geofenceInteraction.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"geofenceInteraction";
    GeofenceInteractionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if(cell == nil)
        NSLog(@"Cell is nil");
    NSInteger rowid = [[NSString stringWithFormat:@"%@", [[self.geofenceInteraction objectAtIndex:indexPath.row] objectAtIndex:1]] integerValue];
    NSString* select = [NSString stringWithFormat:@"select latitude, longitude from geofences where rowid = %ld", rowid];
    NSArray* coord = [[NSArray alloc] initWithArray:[self.locationDB loadDataFromDB:select]];
    NSString* lat = [NSString stringWithFormat:@"%@", [[coord objectAtIndex:0] objectAtIndex:0]];
    NSString* lon = [NSString stringWithFormat:@"%@", [[coord objectAtIndex:0] objectAtIndex:1]];
    cell.geoLat.text = lat;
    cell.geoLong.text = lon;
    cell.geoEnter.text = [NSString stringWithFormat:@"%@", [[self.geofenceInteraction objectAtIndex:indexPath.row] objectAtIndex:2]];
    cell.geoLeave.text = [NSString stringWithFormat:@"%@", [[self.geofenceInteraction objectAtIndex:indexPath.row] objectAtIndex:3]];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
