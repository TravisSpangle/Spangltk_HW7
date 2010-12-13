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
@dynamic doc;

- (void)awakeFromInsert
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //NSString *urlString = @"http://www.wunderground.com/history/airport/KSEA/2010/12/8/DailyHistory.asp?format=1";
	NSString *urlString = @"http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=KSEA";
    NSURL *url = [NSURL URLWithString:urlString];
	
    // For some odd, and unknown reason, Weather Underground seems to suffer an
    // "Internal Server Error" (HTTP 500) when using the default user-agent
    // sent by NSURLRequest. As a workaround, I set a different user-agent.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"Custom" forHTTPHeaderField:@"User-Agent"];
	
    NSURLResponse *response = nil;
    NSError *error = nil;
	
    // You should rarely (if ever) do synchronouse networking (since the main
    // thread could block long enough for the user to notice unresponsive UI,
    // or even worse, block indefinitely, effectively freezing your program).
    NSData *responseContent = [NSURLConnection sendSynchronousRequest:request
                                                    returningResponse:&response
                                                                error:&error];
    
    if (!error) {
        NSStringEncoding responseEncoding = NSISOLatin1StringEncoding;
        
        NSString *responseString = [[[NSString alloc] initWithData:responseContent
                                                          encoding:responseEncoding] autorelease];
		
        //NSLog(@"Response:\n%@", responseString);

		NSData *data = [responseString dataUsingEncoding:responseEncoding];
		NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data 
														 options:0 
														   error:&error];

		NSXMLNode *aNode = [doc rootElement];

		while (aNode = [aNode nextNode]) {

			if([[aNode name] isEqualToString:@"temp_f"])
			{
				NSLog(@"%@: %@", [aNode name],[aNode stringValue] );
				self.Temperature = [NSNumber numberWithInt:[[aNode stringValue] intValue]];
			}
			
			if([[aNode name] isEqualToString:@"wind_mph"])
			{
				NSLog(@"%@: %@", [aNode name],[aNode stringValue] );
				self.Windspeed = [NSNumber numberWithInt:[[aNode stringValue] intValue]];
			}
 
			if([[aNode name] isEqualToString:@"observation_time_rfc822"])
			{
				NSLog(@"%@: %@", [aNode name],[aNode stringValue] );
				self.Timestamp = [NSCalendarDate dateWithNaturalLanguageString:[aNode stringValue]];
			}
			
			if([[aNode name] isEqualToString:@"pressure_in"])
			{
				NSLog(@"%@: %@", [aNode name],[aNode stringValue] );
				self.Pressure = [NSNumber numberWithInt:[[aNode stringValue] intValue]];
			}
		}
			
    } else {
        NSLog(@"Oops, something went wrong: %@", error);
    }
    
    [pool release];
	
	//self.Timestamp = [NSDate date];
	//self.Temperature = [NSNumber numberWithInt:rand()%95];
	//self.Windspeed =  [NSNumber numberWithInt:rand()%45];
	
}

@end
