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
	
	/*  this.methodParams[methodNum] = new Array(fa, ms, mv, is, iv);	
	 
	 fa : fajr angle
	 ms : maghrib selector (0 = angle; 1 = minutes after sunset)
	 mv : maghrib parameter value (in angle or minutes)
	 is : isha selector (0 = angle; 1 = minutes after maghrib)
	 iv : isha parameter value (in angle or minutes)
	 */
	NSMutableArray *prayerTimesCurrent;
	NSMutableArray *offsets;
}

@property (assign) NSInteger numIterations;
@property (nonatomic, strong) NSMutableArray *prayerTimesCurrent;
@property (nonatomic, strong) NSMutableArray *offsets;

#pragma mark - Custom Initializers

- (id)initWithJuristic:(JuristicMethod)juristic andCalculation:(CalculationMethod)calculation;

#pragma mark - Trigonometric Methods

- (double)radiansToDegrees:(double)alpha;
- (double)degreesToRadians:(double)alpha;
- (double)fixangle:(double)a;
- (double)fixhour:(double)a;
- (double)dsin:(double)d;
- (double)dcos:(double)d;
- (double)dtan:(double)d;
- (double)darcsin:(double)x;
- (double)darccos:(double)x;
- (double)darctan:(double)x;
- (double)darccot:(double)x;
- (double)darctan2:(double)y andX:(double)x;

#pragma mark - Timezone Methods

- (double)getTimeZone;
- (double)getBaseTimeZone;
- (double)detectDaylightSaving;

#pragma mark - Julian Date Methods

- (double)julianDateForYear:(NSInteger)year month:(NSInteger)month andDay:(NSInteger)day;
- (double)calculateJulianDateForYear:(NSInteger)year month:(NSInteger)month andDay:(NSInteger)day;

#pragma mark - Calculation Methods

- (NSMutableArray *)sunPosition:(double)jd;
- (double)equationOfTime:(double)jd;
- (double)sunDeclination:(double)jd;
- (double)computeMidDay:(double)t;
- (double)computeTime:(double)t andAngle:(double)g;
- (double)computeAsr:(double)step andTime:(double)t;

#pragma mark - Misc. Methods

- (double)timeDiff:(double)time1 andTime2:(double)time2;

#pragma mark - Interface Methods

- (NSMutableArray *)getDatePrayerTimesForYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day latitude:(double)latitude longitude:(double)longitude andtimeZone:(double)tZone;
- (NSMutableArray *)getPrayerTimesForDate:(NSDateComponents *)date withLatitude:(double)latitude longitude:(double)longitude andTimeZone:(double)tZone;
- (NSMutableArray *)prayerTimesDate:(NSDate *)date latitude:(double)latitude longitude:(double)longitude andTimezone:(double)timezone;
- (NSMutableArray *)prayerTimesFromLocation:(CLLocation *)location;
- (NSMutableArray *)prayerTimesFromLocation:(CLLocation *)location forDate:(NSDate *)date;
- (NSMutableArray *)prayerTimesFromLocation:(CLLocation *)location forDate:(NSDate *)date timezone:(NSTimeZone *)timezone;
- (void)setCalculationMethod:(CalculationMethod)method;
- (void)setJuristicMethod:(JuristicMethod)method;
- (void)setCustomParams:(NSMutableArray *)params;
- (void)setFajrAngle:(double)angle;
- (void)setMaghribAngle:(double)angle;
- (void)setIshaAngle:(double)angle;
- (void)setDhuhrMinutes:(double)minutes;
- (void)setMaghribMinutes:(double)minutes;
- (void)setIshaMinutes:(double)minutes;
- (void)setHighLatitudsMethod:(AdjustMethodHigherLatitude)method;
- (void)setTimeFormat:(TimeFormat)format;
- (NSString *)floatToTime24:(double)time;
- (NSString *)floatToTime12:(double)time suffix:(BOOL)f;
- (NSString *)floatToTime12NS:(double)time;

#pragma mark - Compute Prayer Times

- (NSMutableArray *)computeTimes:(NSMutableArray *)times;
- (NSMutableArray *)computeDayTimes;
- (NSMutableArray *)adjustTimes:(NSMutableArray *)times;
- (NSMutableArray *)adjustTimesFormat:(NSMutableArray *)times;
- (NSMutableArray *)adjustHighLatTimes:(NSMutableArray *)times;
- (double)nightPortion:(double)angle;
- (NSMutableArray *)dayPortion:(NSMutableArray*)times;
- (void)tune:(NSMutableDictionary*)offsetTimes;
- (NSMutableArray *)tuneTimes:(NSMutableArray *)times;

@end
