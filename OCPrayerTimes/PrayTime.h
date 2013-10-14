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

/** 
 * These constants are used to specify the prayer times calculation method. 
 *
 * @since Available in 0.1.0 and later.
 **/
typedef NS_ENUM(NSInteger, CalculationMethod) {
    /** Ithna Ashari.
     * @since Available in 0.1.0 and later.
     */
    CalculationMethodJafari = 0,
    /** University of Islamic Sciences, Karachi.
     * @since Available in 0.1.0 and later.
     */
    CalculationMethodKarachi = 1,
    /** Islamic Society of North America (ISNA).
     * @since Available in 0.1.0 and later.
     */
    CalculationMethodISNA = 2,
    /** Muslim World League (MWL).
     * @since Available in 0.1.0 and later.
     */
    CalculationMethodMWL = 3,
    /** Umm al-Qura, Makkah.
     * @since Available in 0.1.0 and later.
     */
    CalculationMethodMakkah = 4,
    /** Egyptian General Authority of Survey.
     * @since Available in 0.1.0 and later.
     */
    CalculationMethodEgypt = 5,
    /** Institute of Geophysics, University of Tehran.
     * @since Available in 0.1.0 and later.
     */
    CalculationMethodTehran = 6,
    /** Custom Setting.
     * @since Available in 0.1.0 and later.
     */
    CalculationMethodCustom = 7
};

/**
 * These constants are used to specify the juristic method.
 *
 * @since Available in 0.1.0 and later.
 */
typedef NS_ENUM(NSInteger, JuristicMethod) {
    /** 
     * The standard method (which is used by Imamas Shafii, Hanbali, and Maliki) the Asr prayer time starts when the shadow of an object is equivalent to its height.
     *
     * @since Available in 0.1.0 and later.
     */
    JuristicMethodShafii = 0,
    /** 
     * The Hanafi method the Asr prayer time starts when the shadow of an object is twice its height.
     *
     * @since Available in 0.1.0 and later.
     */
    JuristicMethodHanafi = 1      //
};

/** 
 * These constants are used to specify the adjusting methods for higher latitudes. 
 *
 * @since Available in 0.1.0 and later.
 */
typedef NS_ENUM(NSInteger, AdjustMethodHigherLatitude) {
    /** 
     * No adjustment.
     *
     * @since Available in 0.1.0 and later.
     */
    AdjustMethodHigherLatitudeNone = 0,
    /** 
     * Middle of night.
     *
     * @since Available in 0.1.0 and later.
     */
    AdjustMethodHigherLatitudeMidNight = 1,
    /** 
     * 1/7th of night.
     *
     * @since Available in 0.1.0 and later.
     */
    AdjustMethodHigherLatitudeOneSevent = 2,
    /** 
     * Angle/60th of night.
     *
     * @since Available in 0.1.0 and later.
     */
    AdjustMethodHigherLatitudeAngleBased = 3
};

/** 
 * These constants are used to specify the time format. 
 *
 * @since Available in 0.1.0 and later.
 */
typedef NS_ENUM(NSInteger, TimeFormat) {
    /** 
     * Specifies time in the standard 24-hour format.
     *
     * @since Available in 0.1.0 and later.
     */
    TimeFormat24Hour = 0,
    /** 
     * Specifies time in the standard 12-hour format.
     *
     * @since Available in 0.1.0 and later.
     */
    TimeFormat12Hour = 1,
    /** 
     * Specifies time in the standard 12-hour format without suffix.
     *
     * @since Available in 0.1.0 and later.
     */
    TimeFormat12WithNoSuffix = 2,
    /** 
     * Specifies time in floating point number.
     *
     * @since Available in 0.1.0 and later.
     */
    TimeFormatFloat = 3
};


/** 
 The class for calculating Muslim Prayer Times.
 
 Depending on how you configure your project you may need to import "PrayTime.h".
 
 Here is an example for getting prayer times for a given longitude and latitude:
 
    PrayTime *prayerTime = [[PrayTime alloc] initWithJuristic:JuristicMethodShafii
                                               andCalculation:CalculationMethodMWL];
    NSMutableArray *prayerTimes = [prayerTime prayerTimesDate:[NSDate date]
                                                     latitude:3.1667
                                                    longitude:101.7000
                                                  andTimezone:[prayerTime getTimeZone]];
 */
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

/** 
 * Initializes prayer times instance with the provided values.
 *
 * @since Available in 0.1.0 and later.
 * @param juristic Juristic method for prayer times in `JuristicMethod`.
 * @param calculation Prayer calculation method in `CalculationMethod`.
 * @returns Returns the instance of `PrayTime`.
 */
- (id)initWithJuristic:(JuristicMethod)juristic andCalculation:(CalculationMethod)calculation;

#pragma mark - Timezone Methods

/** 
 * Returns hours difference in GMT.
 *
 * @since Available in 0.1.0 and later.
 */
- (double)getTimeZone;

#pragma mark - Interface Methods

/** 
 * Returns prayer times for the provided values.
 *
 * @since Available in 0.1.0 and later.
 * @param year Year.
 * @param month Month.
 * @param day Day.
 * @param latitude The north-south position of a point on the Earth's surface.
 * @param longitude Angle which ranges from 0° at the Equator to 90° (North or South) at the poles.
 * @param tZone Hours difference in GMT.
 * @returns Returns a `NSMutableArray` object of prayer times.
 */
- (NSMutableArray *)getDatePrayerTimesForYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day latitude:(double)latitude longitude:(double)longitude andtimeZone:(double)tZone;

/** 
 * Returns prayer times for the provided values.
 *
 * @since Available in 0.1.0 and later.
 * @param date Components of a date.
 * @param latitude The north-south position of a point on the Earth's surface.
 * @param longitude Angle which ranges from 0° at the Equator to 90° (North or South) at the poles.
 * @param tZone Hours difference in GMT.
 * @returns Returns a `NSMutableArray` object of prayer times.
 */
- (NSMutableArray *)getPrayerTimesForDate:(NSDateComponents *)date withLatitude:(double)latitude longitude:(double)longitude andTimeZone:(double)tZone;

/** 
 * Returns prayer times for the provided values.
 *
 * @since Available in 0.1.0 and later.
 * @param date Date object.
 * @param latitude The north-south position of a point on the Earth's surface.
 * @param longitude Angle which ranges from 0° at the Equator to 90° (North or South) at the poles.
 * @param tZone Hours difference in GMT.
 * @returns Returns a `NSMutableArray` object of prayer times.
 */
- (NSMutableArray *)prayerTimesDate:(NSDate *)date latitude:(double)latitude longitude:(double)longitude andTimezone:(double)timezone;

/** 
 * Returns prayer times for the provided location.
 *
 * @since Available in 0.1.0 and later.
 * @param location Location object.
 * @returns Returns a `NSMutableArray` object of prayer times.
 */
- (NSMutableArray *)prayerTimesFromLocation:(CLLocation *)location;

/** 
 * Returns prayer times for the provided location and date.
 *
 * @since Available in 0.1.0 and later.
 * @param location `CLLocation` object.
 * @param date `NSDate` object.
 * @returns Returns a `NSMutableArray` object of prayer times.
 */
- (NSMutableArray *)prayerTimesFromLocation:(CLLocation *)location forDate:(NSDate *)date;

/** 
 * Returns prayer times for the provided location, date and timezone.
 *
 * @since Available in 0.1.0 and later.
 * @param location Location object.
 * @param date Date object.
 * @param timezone Timezone object.
 * @returns Returns a `NSMutableArray` object of prayer times.
 */
- (NSMutableArray *)prayerTimesFromLocation:(CLLocation *)location forDate:(NSDate *)date timezone:(NSTimeZone *)timezone;

/** 
 * Sets prayer calculation method.
 *
 * @since Available in 0.1.0 and later.
 * @param method Prayer calculation method in `CalculationMethod`.
 * @returns Returns a `NSMutableArray` object of prayer times.
 */
- (void)setCalculationMethod:(CalculationMethod)method;

/** 
 * Sets the juristic method for Asr.
 *
 * @since Available in 0.1.0 and later.
 * @param method Prayer calculation method in `JuristicMethod`.
 */
- (void)setJuristicMethod:(JuristicMethod)method;

/** 
 * Sets custom values for calculation parameters.
 *
 * @since Available in 0.1.0 and later.
 * @param params Parameters in `NSMutableArray`.
 */
- (void)setCustomParams:(NSMutableArray *)params;

/** 
 * Sets the angle for calculating Fajr.
 *
 * @since Available in 0.1.0 and later.
 * @param angle Angle.
 */
- (void)setFajrAngle:(double)angle;

/** 
 * Sets the angle for calculating Maghrib.
 *
 * @since Available in 0.1.0 and later.
 * @param angle Angle.
 */
- (void)setMaghribAngle:(double)angle;

/** 
 * Sets the angle for calculating Isha.
 *
 * @since Available in 0.1.0 and later.
 * @param angle Angle.
 */
- (void)setIshaAngle:(double)angle;

/** 
 * Sets the minutes after mid-day for calculating Dhuhr.
 *
 * @since Available in 0.1.0 and later.
 * @param minutes Minutes after dhuhr.
 */
- (void)setDhuhrMinutes:(double)minutes;

/** 
 * Sets the minutes after Sunset for calculating Maghrib.
 *
 * @since Available in 0.1.0 and later.
 * @param minutes Minutes after maghrib.
 */
- (void)setMaghribMinutes:(double)minutes;

/** 
 * Sets the minutes after Maghrib for calculating Isha.
 *
 * @since Available in 0.1.0 and later.
 * @param minutes Minutes after isha.
 */
- (void)setIshaMinutes:(double)minutes;

/** 
 * Sets adjusting method for higher latitudes.
 *
 * @since Available in 0.1.0 and later.
 * @param method Adjusting method for higher latitude in `AdjustMethodHigherLatitude`.
 */
- (void)setHighLatitudsMethod:(AdjustMethodHigherLatitude)method;

/** 
 * Sets time format.
 *
 * @since Available in 0.1.0 and later.
 * @param format Time format in `TimeFormat`.
 */
- (void)setTimeFormat:(TimeFormat)format;

@end
