//
//  LocationHistoryView.m
//  Location
//
//  Created by Daniel Kalam on 2/23/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import "LocationHistoryView.h"

@implementation LocationHistoryView
-(void)viewDidLoad{
    [super viewDidLoad];
    self.locationDB = [[LocationDataBase alloc] initWithDataBaseFilename:@"locationfinal.sqlite"];
    NSString* query = [NSString stringWithFormat:@"SELECT * FROM locationHistory where name = '%@' order by trackIteration desc", self.userName];
    self.locationHistory = [[NSArray alloc] initWithArray:[self.locationDB loadDataFromDB:query]];
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString* temp = [NSString stringWithFormat:@"%@", [[self.locationHistory objectAtIndex:indexPath.row] objectAtIndex:1]];
    self.trackId = [temp integerValue];
    [self.navigationController popViewControllerAnimated:YES];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.locationHistory.count;
}
-(UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath{
    static NSString *identifier = @"Cell";
    LocationHistoryCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if(cell == nil)
        NSLog(@"Cell is nil");
    cell.startTime.text = [NSString stringWithFormat:@"%@", [[self.locationHistory objectAtIndex:indexPath.row] objectAtIndex:2]];
    cell.endTime.text = [NSString stringWithFormat:@"%@", [[self.locationHistory objectAtIndex:indexPath.row] objectAtIndex:3]];
    return cell;
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.delegate sendDataToA:_trackId];
}
@end
