//
//  getWeather.m
//  Spangltk_HW7
//
//  Created by Travis Spangle on 12/12/10.
//  Copyright 2010 Peak Systems. All rights reserved.
//

#import "getWeather.h"


@implementation getWeather

- (void)callSample 
{
	NSString *urlStr = @"http://www.wunderground.com/history/airport/KSEA/2010/12/8/DailyHistory.asp?format=1";
	
	
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url 
                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                            timeoutInterval:30];  
    
    // Fetch the XML response
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    urlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                    returningResponse:&response
                                                error:&error];
    if (!urlData) {
        NSRunAlertPanel(@"Error loading", @"%@", nil, nil, nil, [error localizedDescription]);
        return;
    }
	
	

    // Parse the XML response
	[doc release];
	doc = [[NSXMLDocument alloc] initWithData:urlData
                                      options:0 
                                        error:&error];
	NSLog(@"doc = %@", doc);
    /*    
	
    //ShowTree(doc, 0);
    
    
	if (!doc) {
		NSAlert *alert = [NSAlert alertWithError:error];
		[alert runModal];
		return;
	}
	
	[itemNodes release];
	itemNodes = [[doc nodesForXPath:@"ItemSearchResponse/Items/Item" error:&error] retain];
	if (!itemNodes) {
		NSAlert *alert = [NSAlert alertWithError:error];
		[alert runModal];
		return;
	}
	
    // Update the interface
    [tableView reloadData];
    [progress stopAnimation:nil];
	 */
		
}

@end
