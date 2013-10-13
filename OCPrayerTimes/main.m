//
//  main.m
//  OCPrayerTimes
//
//  Created by Sumardi Shukor on 10/13/13.
//  Copyright (c) 2013 Software Machine Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrayTime.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        PrayTime *prayerTime = [[PrayTime alloc] initWithJuristic:JuristicMethodShafii
                                                   andCalculation:CalculationMethodMWL];
        [prayerTime setTimeFormat:TimeFormat12Hour];

        // Example 1
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setDay:13];
        [comps setMonth:10];
        [comps setYear:2013];
        NSMutableArray *times1 = [prayerTime getPrayerTimesForDate:comps
                                                           withLatitude:3.1667
                                                              longitude:101.7000
                                                            andTimeZone:[prayerTime getTimeZone]];
        NSLog(@"%@", times1);
        
        // Example 2
        NSMutableArray *times2 = [prayerTime prayerTimesDate:[NSDate date]
                                                         latitude:3.1667
                                                        longitude:101.7000
                                                      andTimezone:[prayerTime getTimeZone]];
        
        NSLog(@"%@", times2);
    }
    
    return 0;
}

