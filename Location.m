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
@dynamic savedLocations;

- (id)init;
{
	if (![super init])
		return nil;
		
	Location *populate = [[[Location alloc] init] autorelease];
	
	[populate setCode:@"KSEA"];
	[populate setName:@"Seattle-Tacoma International"];
	[self.savedLocations addObject:populate];
	
	[populate setCode:@"KBFI"];
	[populate setName:@"Boeing Field/King County International Airport"];
	[self.savedLocations addObject:populate];
	
	[populate setCode:@"KLKE"];
	[populate setName:@"Kenmore Air Harbor SPB"];
	[self.savedLocations addObject:populate];
	
	NSLog(@"updating saved Locations");
	return self;
}

- (void)awakeFromInsert
 {
	 //arrayVariable = [array objectAtIndex:378]; 
	 self.code = [NSString stringWithFormat:@"KABC%02d", ++numberOfStations];
	 self.Name = [NSString stringWithFormat:@"Station KABC%02d", numberOfStations];
	 self.latitude = [NSNumber numberWithDouble:47.5+(rand()%100) * 0.1];
	 self.longitude = [NSNumber numberWithDouble:-122.5+(rand()%100) * .01];
 }

- (void)fetchDetailsByCode
{
	NSLog(@"Fetching data for %@",self.code);
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=%@", self.code];
	
    NSURL *url = [NSURL URLWithString:urlString];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"Custom" forHTTPHeaderField:@"User-Agent"];
	
    NSURLResponse *response = nil;
    NSError *error = nil;
	
    NSData *responseContent = [NSURLConnection sendSynchronousRequest:request
                                                    returningResponse:&response
                                                                error:&error];
    
    if (!error) {
        NSStringEncoding responseEncoding = NSISOLatin1StringEncoding;
        
        NSString *responseString = [[[NSString alloc] initWithData:responseContent
                                                          encoding:responseEncoding] autorelease];
		
		NSData *data = [responseString dataUsingEncoding:responseEncoding];
		
		NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithData:data 
														  options:0 
															error:&error] autorelease];
		
		NSXMLNode *aNode = [doc rootElement];
		NSUInteger tracker = 0;
		//tracks progress and will break out of the loop when all three elements have been found.
		/*also prevents the second value from 'full' of overwriting the first. I would have prefered to check the level or index of full 
		 instead of assuming.  Potential bug is that if two latitudes are found before the first full, then tracker would
		 already be at 3 and miss the 'full' value.*/
		
		while (aNode = [aNode nextNode]) {
			
			if([[aNode name] isEqualToString:@"latitude"])
			{
				NSLog(@"%@: %@", [aNode name],[aNode stringValue] );
				self.latitude = [NSNumber numberWithDouble:[[aNode stringValue] doubleValue]];
				++tracker;

			}
			
			if([[aNode name] isEqualToString:@"longitude"])
			{
				NSLog(@"%@: %@", [aNode name],[aNode stringValue] );
				self.longitude = [NSNumber numberWithDouble:[[aNode stringValue] doubleValue]];
				++tracker;
			}
			
			if([[aNode name] isEqualToString:@"full"])
			{
				NSLog(@"%@: %@", [aNode name],[aNode stringValue] );
				self.Name = [NSString stringWithFormat:@"%@",[aNode stringValue]];
				++tracker;
			}
			
			if (tracker ==3) {
				break;
			}
		}
		
    } else {
        NSLog(@"Oops, something went wrong: %@", error);
    }
	
    [pool release];	
	
}

- (void)populateTodaysObservations
{
	NSLog(@"populating data%@", self);
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSDateFormatter *urlFormat = [[[NSDateFormatter alloc]
								   initWithDateFormat:@"%Y/%m/%d" allowNaturalLanguage:NO] autorelease];
	NSDate *todaysDate = [NSDate date];
	NSString *urlDateString = [urlFormat stringFromDate:todaysDate];
	
	NSDateFormatter * fullDate = [[[NSDateFormatter alloc] init] autorelease];
	[fullDate setDateFormat:@"EEE, dd MMM yyyy"];
	
	NSString *urlString = [NSString stringWithFormat:@"http://www.wunderground.com/history/airport/%@/%@/DailyHistory.asp?format=1", self.code,urlDateString];
	
	NSLog(@"Checking:%@",urlString);
	
    NSURL *url = [NSURL URLWithString:urlString];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"Custom" forHTTPHeaderField:@"User-Agent"];
	
    NSURLResponse *response = nil;
    NSError *error = nil;
	
    NSData *responseContent = [NSURLConnection sendSynchronousRequest:request
                                                    returningResponse:&response
                                                                error:&error];
    
    if (!error) {
		NSStringEncoding responseEncoding = NSISOLatin1StringEncoding;
        
        NSString *responseString = [[[NSString alloc] initWithData:responseContent
                                                          encoding:responseEncoding] autorelease];
				
		NSEnumerator *e = [[responseString componentsSeparatedByString:@"\n"] objectEnumerator];
		id object;
		while (object = [e nextObject]) {		
			
			NSArray *weatherData = [object componentsSeparatedByString: @","];
			
			if ([weatherData count]==12 && (![[NSString stringWithString:[weatherData objectAtIndex:0]] isEqualToString:@"TimePST"]) ) {
			/*This is beast of comparison.  Essentiall I want to skip the row that contains the csv headers.  Id like to know if you have
			 a suggestion for a better comparision / place to compare. - thanks */
								
				Observation *newObservation =
				[NSEntityDescription insertNewObjectForEntityForName:@"Observation" 
											  inManagedObjectContext:self.managedObjectContext];
				
				NSLog(@"Time: %@", [weatherData objectAtIndex:0]);
				newObservation.Timestamp = [NSCalendarDate dateWithNaturalLanguageString:
											[NSString stringWithFormat:@"%@ %@ PST",[fullDate stringFromDate:[NSDate date]], [weatherData objectAtIndex:0]]];

				NSLog(@"calculated Time: %@",[NSString stringWithFormat:@"%@ %@ PST",
										   [fullDate stringFromDate:[NSDate date]], [weatherData objectAtIndex:0]]);
				
				NSLog(@"Temp: %@", [weatherData objectAtIndex:1]);
				newObservation.Temperature = [NSNumber numberWithInt:[[weatherData objectAtIndex:1] intValue]];
				
				NSLog(@"Pressure: %@", [weatherData objectAtIndex:4]);
				newObservation.Pressure = [NSNumber numberWithInt:[[weatherData objectAtIndex:4] intValue]];
				
				NSLog(@"Windspeed: %@", [weatherData objectAtIndex:7]);
				newObservation.Windspeed = [NSNumber numberWithInt:[[weatherData objectAtIndex:7] intValue]];
				
				newObservation.station = self;
			}
		}
		
    } else {
        NSLog(@"Oops, something went wrong: %@", error);
    }
	
    [pool release];	
}

-(void)getFreshData
{
	Observation *newObservation =
	[NSEntityDescription insertNewObjectForEntityForName:@"Observation" 
								  inManagedObjectContext:self.managedObjectContext];

	NSLog(@"Revewing current station: %@",self.code);
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSString *urlString = [NSString stringWithFormat:@"http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=%@", self.code];
	
    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"Custom" forHTTPHeaderField:@"User-Agent"];
	
    NSURLResponse *response = nil;
    NSError *error = nil;
	
    NSData *responseContent = [NSURLConnection sendSynchronousRequest:request
                                                    returningResponse:&response
                                                                error:&error];
    
    if (!error) {
        NSStringEncoding responseEncoding = NSISOLatin1StringEncoding;
        
        NSString *responseString = [[[NSString alloc] initWithData:responseContent
                                                          encoding:responseEncoding] autorelease];
		
		NSData *data = [responseString dataUsingEncoding:responseEncoding];

		NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithData:data 
														 options:0 
														   error:&error] autorelease];
		
		NSXMLNode *aNode = [doc rootElement];
		
		while (aNode = [aNode nextNode]) {
			
			if([[aNode name] isEqualToString:@"temp_f"])
			{
				NSLog(@"%@: %@", [aNode name],[aNode stringValue] );
				newObservation.Temperature = [NSNumber numberWithInt:[[aNode stringValue] intValue]];
			}
			
			if([[aNode name] isEqualToString:@"wind_mph"])
			{
				NSLog(@"%@: %@", [aNode name],[aNode stringValue] );
				newObservation.Windspeed = [NSNumber numberWithInt:[[aNode stringValue] intValue]];
			}
			
			if([[aNode name] isEqualToString:@"observation_time_rfc822"])
			{
				NSLog(@"%@: %@", [aNode name],[aNode stringValue] );
				newObservation.Timestamp = [NSCalendarDate dateWithNaturalLanguageString:[aNode stringValue]];
			}
			
			if([[aNode name] isEqualToString:@"pressure_in"])
			{
				NSLog(@"%@: %@", [aNode name],[aNode stringValue] );
				newObservation.Pressure = [NSNumber numberWithInt:[[aNode stringValue] intValue]];
			}
		}
		
    } else {
        NSLog(@"Oops, something went wrong: %@", error);
    }
    
	newObservation.station = self;
	
    [pool release];	
}

@end
