// 
//  Observation.m
//  Spangltk_HW6
//
//  Created by Travis Spangle on 12/6/10.
//  Copyright 2010 Peak Systems. All rights reserved.
//

#import "Observation.h"

#import "Location.h"

@implementation Observation 

@dynamic Pressure;
@dynamic Temperature;
@dynamic Timestamp;
@dynamic Windspeed;
@dynamic station;
@dynamic MaxTemperature;
@dynamic MinTemperature;

- (void)awakeFromInsert
{
	if(!self.Timestamp) 
		self.Timestamp = [NSDate date];
	
	if(!self.Temperature)
		self.Temperature = [NSNumber numberWithInt:rand()%95];
	
	if(!self.Windspeed)
		self.Windspeed =  [NSNumber numberWithInt:rand()%45];
}

@end
