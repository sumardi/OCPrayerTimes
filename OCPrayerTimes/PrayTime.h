//
//  PrayTime.h
//  OCPrayerTimes
//
//  Created by Sumardi Shukor on 10/13/13.
//  Copyright (c) 2013 Software Machine Development. All rights reserved.
//
//  Modified version of the original source code written by Hussain Ali.
//  Converted to the Modern Objective-C Syntax.
//
//  Objective C Code By: Hussain Ali Khan
//  Original JS Code By: Hamid Zarrabi-Zadeh
//  Original Source from : PrayTimes.org
//
//  OCPrayerTimes podspec created and maintained by:
//  Sumardi Shukor  <me@sumardi.net>
//  https://www.github.com/sumardi/OCPrayerTimes
//

#import <Foundation/Foundation.h>

/** The class for calculating Muslim Prayer Times.
 
 Depending on how you configure your project you may need to import "PrayTime.h".
 
 Here is an example for getting prayer times for a given longitude and latitude:
 
    PrayTime *prayerTime = [[PrayTime alloc] initWithJuristic:JuristicMethodShafii
                                               andCalculation:CalculationMethodMWL];
    NSMutableArray *prayerTimes = [prayerTime prayerTimesDate:[NSDate date]
                                                     latitude:3.1667
                                                    longitude:101.7000
                                                  andTimezone:[prayerTime getTimeZone]];
 */

// Calculation Methods
typedef enum {
    CalculationMethodJafari = 0,    // Ithna Ashari
    CalculationMethodKarachi = 1,   // University of Islamic Sciences, Karachi
    CalculationMethodISNA = 2,      // Islamic Society of North America (ISNA)
    CalculationMethodMWL = 3,       // Muslim World League (MWL)
    CalculationMethodMakkah = 4,    // Umm al-Qura, Makkah
    CalculationMethodEgypt = 5,     // Egyptian General Authority of Survey
    CalculationMethodTehran = 6,    // Institute of Geophysics, University of Tehran
    CalculationMethodCustom = 7     // Custom Setting
} CalculationMethod;

// Juristic Methods
typedef enum {
    JuristicMethodShafii = 0,     // Shafii (standard)
    JuristicMethodHanafi = 1      // Hanafi
} JuristicMethod;

// Adjusting Methods for Higher Latitudes
typedef enum {
    AdjustMethodHigherLatitudeNone = 0,         // No adjustment
    AdjustMethodHigherLatitudeMidNight = 1,     // Middle of night
    AdjustMethodHigherLatitudeOneSevent = 2,    // 1/7th of night
    AdjustMethodHigherLatitudeAngleBased = 3    // Angle/60th of night
} AdjustMethodHigherLatitude;

// Time Formats
typedef enum {
    TimeFormat24Hour = 0,           // 24-hour format
    TimeFormat12Hour = 1,           // 12-hour format
    TimeFormat12WithNoSuffix = 2,   // 12-hour format with no suffix
    TimeFormatFloat = 3             // floating point number
} TimeFormat;

@interface PrayTime : NSObject {
    
	NSMutableArray *timeNames;
	NSString *InvalidTime;	 // The string used for invalid times
	
	
	//--------------------- Technical Settings --------------------

	NSInteger numIterations;		// number of iterations needed to compute times
	
	//------------------- Calc Method Parameters --------------------

	NSMutableDictionary *methodParams;

	/*
	 fa : fajr angle
	 ms : maghrib selector (0 = angle; 1 = minutes after sunset)
	 mv : maghrib parameter value (in angle or minutes)
	 is : isha selector (0 = angle; 1 = minutes after maghrib)
	 iv : isha parameter value (in angle or minutes)
	 */
	NSMutableArray *prayerTimesCurrent;
	NSMutableArray *offsets;
}

#pragma mark - Custom Initializers

/** Initializes prayer times instance with the provided values.
 * @since Available in 0.1.0 and later.
 * @param juristic Juristic method for prayer times.
 * @param calculation Prayer calculation method.
 * @returns Returns the instance of `PrayTime`.
 */
- (id)initWithJuristic:(JuristicMethod)juristic andCalculation:(CalculationMethod)calculation;

#pragma mark - Timezone Methods

/** Returns hours difference in GMT.
 * @since Available in 0.1.0 and later.
 */
- (double)getTimeZone;

#pragma mark - Interface Methods

/** Returns prayer times for the provided values.
 * @since Available in 0.1.0 and later.
 * @param year Year.
 * @param month Month.
 * @param day Day.
 * @param latitude The north-south position of a point on the Earth's surface.
 * @param longitude Angle which ranges from 0° at the Equator to 90° (North or South) at the poles.
 * @param tZone Hours difference in GMT.
 */
- (NSMutableArray *)getDatePrayerTimesForYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day latitude:(double)latitude longitude:(double)longitude andtimeZone:(double)tZone;

/** Returns prayer times for the provided values.
 * @since Available in 0.1.0 and later.
 * @param date Components of a date.
 * @param latitude The north-south position of a point on the Earth's surface.
 * @param longitude Angle which ranges from 0° at the Equator to 90° (North or South) at the poles.
 * @param tZone Hours difference in GMT.
 */
- (NSMutableArray *)getPrayerTimesForDate:(NSDateComponents *)date withLatitude:(double)latitude longitude:(double)longitude andTimeZone:(double)tZone;

/** Returns prayer times for the provided values.
 * @since Available in 0.1.0 and later.
 * @param date Date object.
 * @param latitude The north-south position of a point on the Earth's surface.
 * @param longitude Angle which ranges from 0° at the Equator to 90° (North or South) at the poles.
 * @param tZone Hours difference in GMT.
 */
- (NSMutableArray *)prayerTimesDate:(NSDate *)date latitude:(double)latitude longitude:(double)longitude andTimezone:(double)timezone;

/** Returns prayer times for the provided location.
 * @since Available in 0.1.0 and later.
 * @param location Location object.
 */
- (NSMutableArray *)prayerTimesFromLocation:(CLLocation *)location;

/** Returns prayer times for the provided location and date.
 * @since Available in 0.1.0 and later.
 * @param location Location object.
 * @param date Date object.
 */
- (NSMutableArray *)prayerTimesFromLocation:(CLLocation *)location forDate:(NSDate *)date;

/** Returns prayer times for the provided location, date and timezone.
 * @since Available in 0.1.0 and later.
 * @param location Location object.
 * @param date Date object.
 * @param timezone Timezone object.
 */
- (NSMutableArray *)prayerTimesFromLocation:(CLLocation *)location forDate:(NSDate *)date timezone:(NSTimeZone *)timezone;

/** Sets prayer calculation method.
 * @since Available in 0.1.0 and later.
 * @param method Prayer calculation method.
 */
- (void)setCalculationMethod:(CalculationMethod)method;

/** Sets the juristic method for Asr.
 * @since Available in 0.1.0 and later.
 * @param method Prayer calculation method.
 */
- (void)setJuristicMethod:(JuristicMethod)method;

/** Sets custom values for calculation parameters.
 * @since Available in 0.1.0 and later.
 * @param params Parameters in `NSMutableArray`.
 */
- (void)setCustomParams:(NSMutableArray *)params;

/** Sets the angle for calculating Fajr.
 * @since Available in 0.1.0 and later.
 * @param angle Angle.
 */
- (void)setFajrAngle:(double)angle;

/** Sets the angle for calculating Maghrib.
 * @since Available in 0.1.0 and later.
 * @param angle Angle.
 */
- (void)setMaghribAngle:(double)angle;

/** Sets the angle for calculating Isha.
 * @since Available in 0.1.0 and later.
 * @param angle Angle.
 */
- (void)setIshaAngle:(double)angle;

/** Sets the minutes after mid-day for calculating Dhuhr.
 * @since Available in 0.1.0 and later.
 * @param minutes Minutes after dhuhr.
 */
- (void)setDhuhrMinutes:(double)minutes;

/** Sets the minutes after Sunset for calculating Maghrib.
 * @since Available in 0.1.0 and later.
 * @param minutes Minutes after maghrib.
 */
- (void)setMaghribMinutes:(double)minutes;

/** Sets the minutes after Maghrib for calculating Isha.
 * @since Available in 0.1.0 and later.
 * @param minutes Minutes after isha.
 */
- (void)setIshaMinutes:(double)minutes;

/** Sets adjusting method for higher latitudes.
 * @since Available in 0.1.0 and later.
 * @param method Adjusting method for higher latitude in `AdjustMethodHigherLatitude`.
 */
- (void)setHighLatitudsMethod:(AdjustMethodHigherLatitude)method;

/** Sets time format.
 * @since Available in 0.1.0 and later.
 * @param format Time format in `TimeFormat`.
 */
- (void)setTimeFormat:(TimeFormat)format;

@end
