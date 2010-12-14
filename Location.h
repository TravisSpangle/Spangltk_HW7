//
//  Location.h
//  Spangltk_HW6
//
//  Created by Travis Spangle on 12/6/10.
//  Copyright 2010 Peak Systems. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Location :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSSet* observations;
@property (nonatomic, retain) NSMutableArray * savedLocations;
@end

@interface Location (CoreDataGeneratedAccessors)
- (void)addObservationsObject:(NSManagedObject *)value;
- (void)removeObservationsObject:(NSManagedObject *)value;
- (void)addObservations:(NSSet *)value;
- (void)removeObservations:(NSSet *)value;

@end

