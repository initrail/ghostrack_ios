//
//  LocationHistoryCell.h
//  Location
//
//  Created by Daniel Kalam on 2/23/17.
//  Copyright © 2017 Initrail. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface LocationHistoryCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *endTime;
@property (strong, nonatomic) IBOutlet UILabel *startTime;

@end
