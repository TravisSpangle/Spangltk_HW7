// 
//  Location.m
//  Spangltk_HW6
//
//  Created by Travis Spangle on 12/6/10.
//  Copyright 2010 Peak Systems. All rights reserved.
//

#import "Location.h"
#import "Observation.h"

static NSUInteger numberOfStations = 0;

@implementation Location 

@dynamic code;
@dynamic Name;
@dynamic latitude;
@dynamic longitude;
@dynamic observations;

- (void)awakeFromInsert
 {
	 self.code = [NSString stringWithFormat:@"KABC%02d", ++numberOfStations];
	 self.Name = [NSString stringWithFormat:@"Station KABC%02d", numberOfStations];
	 self.latitude = [NSNumber numberWithDouble:47.5+(rand()%100) * 0.1];
	 self.longitude = [NSNumber numberWithDouble:-122.5+(rand()%100) * .01];
 }

- (void)createFakeData
{
	NSLog(@"populating data%@", self);
	
	for (int i = 0; i < 10; i++)  {
		Observation *newObservation =
		[NSEntityDescription insertNewObjectForEntityForName:@"Observation" 
									  inManagedObjectContext:self.managedObjectContext];
		newObservation.station = self;
	}
}

@end
