//
//  Observation.h
//  Spangltk_HW6
//
//  Created by Travis Spangle on 12/6/10.
//  Copyright 2010 Peak Systems. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Location;

@interface Observation :  NSManagedObject  
{
	NSXMLDocument *doc;
}

@property (nonatomic, retain) NSNumber * Pressure;
@property (nonatomic, retain) NSNumber * Temperature;
@property (nonatomic, retain) NSNumber * MaxTemperature;
@property (nonatomic, retain) NSNumber * MinTemperature;
@property (nonatomic, retain) NSDate * Timestamp;
@property (nonatomic, retain) NSNumber * Windspeed;
@property (nonatomic, retain) Location * station;
@property (nonatomic, retain) NSXMLDocument * doc;

@end



