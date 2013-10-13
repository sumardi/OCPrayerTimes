//
//  PrayTime.m
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

#import "PrayTime.h"

@interface PrayTime () {
    // caculation method
    CalculationMethod calcMethod;
    
    // juristic method
    JuristicMethod asrJuristic;
    
    // minutes after mid-day for Dhuhr
    NSInteger dhuhrMinutes;
    
    // adjusting method for higher latitudes
    AdjustMethodHigherLatitude adjustHighLats;
    
    // time format
    TimeFormat timeFormat;

    double lat;        // latitude
    double lng;        // longitude
    double timeZone;   // time-zone
    double jDate;      // Julian date
}

@end

@implementation PrayTime

@synthesize numIterations;
@synthesize prayerTimesCurrent;
@synthesize offsets;

#pragma mark - Creating, Copying and Deallocating Object 

- (id)init
{
	if(self = [super init]) {
        
        // Default
        calcMethod = CalculationMethodJafari;
        asrJuristic = JuristicMethodShafii;
        dhuhrMinutes = 0;
        adjustHighLats = AdjustMethodHigherLatitudeMidNight;
        timeFormat = TimeFormat24Hour;
		
		// Time Names
		timeNames = [@[@"Fajr", @"Sunrise", @"Dhuhr", @"Asr", @"Sunset", @"Maghrib", @"Isha"] mutableCopy];
		
		InvalidTime = @"-----";	 // The string used for invalid times
		
		//--------------------- Technical Settings --------------------
		
		numIterations = 1;		// number of iterations needed to compute times
		
		//------------------- Calc Method Parameters --------------------
		
		// Tuning offsets
		offsets = [@[@0,
                     @0,
                     @0,
                     @0,
                     @0,
                     @0,
                     @0] mutableCopy];
        
		/*
		 fa : fajr angle
		 ms : maghrib selector (0 = angle; 1 = minutes after sunset)
		 mv : maghrib parameter value (in angle or minutes)
		 is : isha selector (0 = angle; 1 = minutes after maghrib)
		 iv : isha parameter value (in angle or minutes)
		 */
		methodParams = [NSMutableDictionary dictionary];
		
        methodParams[@(CalculationMethodJafari)] = @[@16,
                                  @0,
                                  @4,
                                  @0,
                                  @14];
        
        methodParams[@(CalculationMethodKarachi)] = @[@18,
                                  @1,
                                  @0,
                                  @0,
                                  @18];
        
        methodParams[@(CalculationMethodISNA)] = @[@15,
                                  @1,
                                  @0,
                                  @0,
                                  @15];
        
        methodParams[@(CalculationMethodMWL)] = @[@18,
                                  @1,
                                  @0,
                                  @0,
                                  @17];
        
        methodParams[@(CalculationMethodMakkah)] = @[@18.5,
                                  @1,
                                  @0,
                                  @1,
                                  @90];

        methodParams[@(CalculationMethodEgypt)] = @[@19.5,
                                  @1,
                                  @0,
                                  @0,
                                  @17.5];
		
        methodParams[@(CalculationMethodTehran)] = @[@17.7,
                                  @0,
                                  @4.5,
                                  @0,
                                  @14];
        
        methodParams[@(CalculationMethodCustom)] = @[@18,
                                  @1,
                                  @0,
                                  @0,
                                  @17];
		
	}
    
	return self;
}

- (id)initWithJuristic:(JuristicMethod)juristic andCalculation:(CalculationMethod)calculation
{
    if (self = [self init]) {
        [self setJuristicMethod:juristic];
        [self setCalculationMethod:calculation];
    }
    
    return self;
}

#pragma mark - Trigonometric Methods

// range reduce angle in degrees.
- (double)fixangle:(double)a
{
	a = a - (360 * (floor(a / 360.0)));
	a = a < 0 ? (a + 360) : a;
    
	return a;
}

// range reduce hours to 0..23
- (double)fixhour:(double)a
{
	a = a - 24.0 * floor(a / 24.0);
	a = a < 0 ? (a + 24) : a;
    
	return a;
}

// radian to degree
- (double)radiansToDegrees:(double)alpha
{
	return ((alpha * 180.0)/M_PI);
}

// degree to radian
- (double)degreesToRadians:(double)alpha
{
	return ((alpha * M_PI)/180.0);
}

// degree sin
- (double)dsin:(double)d
{
	return (sin([self degreesToRadians:d]));
}

// degree cos
- (double)dcos:(double)d
{
	return (cos([self degreesToRadians:d]));
}

// degree tan
- (double)dtan:(double)d
{
	return (tan([self degreesToRadians:d]));
}

// degree arcsin
- (double)darcsin:(double)x
{
	double val = asin(x);
	return [self radiansToDegrees:val];
}

// degree arccos
- (double)darccos:(double)x
{
	double val = acos(x);
	return [self radiansToDegrees:val];
}

// degree arctan
- (double)darctan:(double)x
{
	double val = atan(x);
	return [self radiansToDegrees:val];
}

// degree arctan2
- (double)darctan2:(double)y andX:(double)x
{
	double val = atan2(y, x);
	return [self radiansToDegrees:val];
}

// degree arccot
- (double)darccot:(double)x
{
	double val = atan2(1.0, x);
	return [self radiansToDegrees:val];
}

#pragma mark - Timezone Methods

// compute local time-zone for a specific date
- (double)getTimeZone
{
	NSTimeZone *_timeZone = [NSTimeZone localTimeZone];
	double hoursDiff = [_timeZone secondsFromGMT]/3600.0f;
    
	return hoursDiff;
}

// compute base time-zone of the system
- (double)getBaseTimeZone
{
	NSTimeZone *_timeZone = [NSTimeZone defaultTimeZone];
	double hoursDiff = [_timeZone secondsFromGMT]/3600.0f;
    
	return hoursDiff;
}

// detect daylight saving in a given date
- (double)detectDaylightSaving
{
	NSTimeZone *_timeZone = [NSTimeZone localTimeZone];
	double hoursDiff = [_timeZone daylightSavingTimeOffsetForDate:[NSDate date]];

	return hoursDiff;
}

// get the hours diff from timezone
- (double)getHoursDiffFromTimezone:(NSTimeZone *)timezone
{
    return [timezone secondsFromGMT]/3600.0f;
}

#pragma mark - Julian Date Methods

// calculate julian date from a calendar date
- (double)julianDateForYear:(NSInteger)year month:(NSInteger)month andDay:(NSInteger)day
{
	if (month <= 2) {
		year -= 1;
		month += 12;
	}
    
	double A = floor(year/100.0);
	double B = 2 - A + floor(A/4.0);
	double JD = floor(365.25 * (year+ 4716)) + floor(30.6001 * (month + 1)) + day + B - 1524.5;
		
	return JD;
}

// convert a calendar date to julian date (second method)
- (double)calculateJulianDateForYear:(NSInteger)year month:(NSInteger)month andDay:(NSInteger)day
{
	double J1970 = 2440588;
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setWeekday:day]; // Monday
	//[components setWeekdayOrdinal:1]; // The first day in the month
	[components setMonth:month]; // May
	[components setYear:year];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *date1 = [gregorian dateFromComponents:components];
	
	double ms = [date1 timeIntervalSince1970];// # of milliseconds since midnight Jan 1, 1970
	double days = floor(ms/ (1000.0 * 60.0 * 60.0 * 24.0));
    
	return J1970+ days- 0.5;
}

#pragma mark - Calculation Methods

/*
 References:
 http://www.ummah.net/astronomy/saltime
 http://aa.usno.navy.mil/faq/docs/SunApprox.html
 */

// compute declination angle of sun and equation of time
- (NSMutableArray *)sunPosition:(double)jd
{
	double D = jd - 2451545;
	double g = [self fixangle: (357.529 + 0.98560028 * D)];
	double q = [self fixangle: (280.459 + 0.98564736 * D)];
	double L = [self fixangle: (q + (1.915 * [self dsin: g]) + (0.020 * [self dsin:(2 * g)]))];
	
	// double R = 1.00014 - 0.01671 * [self dcos:g] - 0.00014 * [self dcos: (2*g)];
	double e = 23.439 - (0.00000036 * D);
	double d = [self darcsin: ([self dsin: e] * [self dsin: L])];
	double RA = ([self darctan2: ([self dcos: e] * [self dsin: L]) andX: [self dcos:L]])/ 15.0;
	RA = [self fixhour:RA];
	
	double EqT = q/15.0 - RA;
	
	NSMutableArray *sPosition = [[NSMutableArray alloc] init];
	[sPosition addObject:@(d)];
	[sPosition addObject:@(EqT)];
	
	return sPosition;
}

// compute equation of time
- (double)equationOfTime:(double)jd
{
	double eq = [[self sunPosition:jd][1] doubleValue];
    
	return eq;
}

// compute declination angle of sun
- (double)sunDeclination:(double)jd
{
	double d = [[self sunPosition:jd][0] doubleValue];
    
	return d;
}

// compute mid-day (Dhuhr, Zawal) time
- (double)computeMidDay:(double)t
{
	double T = [self equationOfTime:(jDate+ t)];
	double Z = [self fixhour: (12 - T)];
    
	return Z;
}

// compute time for a given angle G
- (double)computeTime:(double)t andAngle:(double)g
{
	double D = [self sunDeclination:(jDate+ t)];
	double Z = [self computeMidDay: t];
	double V = ([self darccos: (-[self dsin:g] - ([self dsin:D] * [self dsin:lat]))/ ([self dcos:D] * [self dcos:lat])]) / 15.0f;

	return Z+ (g>90 ? -V : V);
}

// compute the time of Asr
// Shafii: step=1, Hanafi: step=2
- (double)computeAsr:(double)step andTime:(double)t
{
	double D = [self sunDeclination:(jDate+ t)];
	double G = -[self darccot : (step + [self dtan:ABS(lat-D)])];
    
	return [self computeTime:t andAngle:G];
}

#pragma mark - Misc. Methods

// compute the difference between two times 
- (double)timeDiff:(double)time1 andTime2:(double)time2
{
	return [self fixhour:(time2- time1)];
}

#pragma mark - Interface Methods

// return prayer times for a given date
- (NSMutableArray *)getDatePrayerTimesForYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day latitude:(double)latitude longitude:(double)longitude andtimeZone:(double)tZone
{
	lat = latitude;
	lng = longitude; 

	timeZone = tZone;
	jDate = [self julianDateForYear:year month:month andDay:day];
	
	double lonDiff = longitude/(15.0 * 24.0);
	jDate = jDate - lonDiff;
	return [self computeDayTimes];
}

// return prayer times for a given date
- (NSMutableArray *)getPrayerTimesForDate:(NSDateComponents *)date withLatitude:(double)latitude longitude:(double)longitude andTimeZone:(double)tZone
{
	NSInteger year = [date year];
	NSInteger month = [date month];
	NSInteger day = [date day];
    
	return [self getDatePrayerTimesForYear:year month:month day:day latitude:latitude longitude:longitude andtimeZone:tZone];
}

// return prayer times for the given date
- (NSMutableArray *)prayerTimesDate:(NSDate *)date latitude:(double)latitude longitude:(double)longitude andTimezone:(double)timezone
{
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    
    NSInteger year = [components year];
	NSInteger month = [components month];
	NSInteger day = [components day];
    
	return [self getDatePrayerTimesForYear:year month:month day:day latitude:latitude longitude:longitude andtimeZone:timezone];
}

// return current prayer times from the given location
- (NSMutableArray *)prayerTimesFromLocation:(CLLocation *)location
{
    return [self prayerTimesFromLocation:location forDate:location.timestamp];
}

// return prayer times from the given location
- (NSMutableArray *)prayerTimesFromLocation:(CLLocation *)location forDate:(NSDate *)date
{
    return [self prayerTimesDate:date
                        latitude:location.coordinate.latitude
                       longitude:location.coordinate.longitude
                     andTimezone:[self getTimeZone]];
}

// return prayer times from the given location and timezone
- (NSMutableArray *)prayerTimesFromLocation:(CLLocation *)location forDate:(NSDate *)date timezone:(NSTimeZone *)timezone
{
    return [self prayerTimesDate:date
                        latitude:location.coordinate.latitude
                       longitude:location.coordinate.longitude
                     andTimezone:[self getHoursDiffFromTimezone:timezone]];
}

// set the calculation method 
- (void)setCalculationMethod:(CalculationMethod)method
{
    switch (method) {
        case CalculationMethodJafari:
        case CalculationMethodKarachi:
        case CalculationMethodISNA:
        case CalculationMethodMWL:
        case CalculationMethodMakkah:
        case CalculationMethodEgypt:
        case CalculationMethodTehran:
        case CalculationMethodCustom:
            calcMethod = method;
            break;
            
        default:
            return;
            break;
    }
}

// set the juristic method for Asr
- (void)setJuristicMethod:(JuristicMethod)method
{
    switch (method) {
        case JuristicMethodShafii:
        case JuristicMethodHanafi:
            asrJuristic = method;
            break;
            
        default:
            return;
            break;
    }
}

// set custom values for calculation parameters
- (void)setCustomParams:(NSMutableArray *)params
{
    methodParams[@(CalculationMethodCustom)] = params;
    calcMethod = CalculationMethodCustom;
}

// set the angle for calculating Fajr
- (void)setFajrAngle:(double)angle
{
	[self setCustomParams:[@[@(angle),
                            @-1.0,
                            @-1.0,
                            @-1.0,
                            @-1.0] mutableCopy]];
}

// set the angle for calculating Maghrib
- (void)setMaghribAngle:(double)angle
{
    [self setCustomParams:[@[@-1.0,
                             @0.0,
                             @(angle),
                             @-1.0,
                             @-1.0] mutableCopy]];
}

// set the angle for calculating Isha
- (void)setIshaAngle:(double)angle
{
    [self setCustomParams:[@[@-1.0,
                             @-1.0,
                             @-1.0,
                             @0.0,
                             @(angle)] mutableCopy]];
}

// set the minutes after mid-day for calculating Dhuhr
- (void)setDhuhrMinutes:(double)minutes
{
	dhuhrMinutes = minutes;
}

// set the minutes after Sunset for calculating Maghrib
- (void)setMaghribMinutes:(double)minutes
{
    [self setCustomParams:[@[@-1.0,
                             @1.0,
                             @(minutes),
                             @-1.0,
                             @-1.0] mutableCopy]];
}

// set the minutes after Maghrib for calculating Isha
- (void)setIshaMinutes:(double)minutes
{
    [self setCustomParams:[@[@-1.0,
                             @-1.0,
                             @-1.0,
                             @1.0,
                             @(minutes)] mutableCopy]];
}

// set adjusting method for higher latitudes 
- (void)setHighLatitudsMethod:(AdjustMethodHigherLatitude)method
{
    switch (method) {
        case AdjustMethodHigherLatitudeNone:
        case AdjustMethodHigherLatitudeMidNight:
        case AdjustMethodHigherLatitudeOneSevent:
        case AdjustMethodHigherLatitudeAngleBased:
            adjustHighLats = method;
            break;
            
        default:
            return;
            break;
    }
}

// set the time format 
- (void)setTimeFormat:(TimeFormat)format
{
    switch (format) {
        case TimeFormat24Hour:
        case TimeFormat12Hour:
        case TimeFormat12WithNoSuffix:
        case TimeFormatFloat:
            timeFormat = format;
            break;
            
        default:
            return;
            break;
    }
}

// convert double hours to 24h format
- (NSString *)floatToTime24:(double)time
{
	NSString *result = nil;
	
	if (isnan(time))
		return InvalidTime;
	
	time = [self fixhour:(time + 0.5/ 60.0)];  // add 0.5 minutes to round
	int hours = floor(time); 
	double minutes = floor((time - hours) * 60.0);
	
	if((hours >=0 && hours<=9) && (minutes >=0 && minutes <=9)){
		result = [NSString stringWithFormat:@"0%d:0%.0f",hours, minutes];
	}
	else if((hours >=0 && hours<=9)){
		result = [NSString stringWithFormat:@"0%d:%.0f",hours, minutes];
	}
	else if((minutes >=0 && minutes <=9)){
		result = [NSString stringWithFormat:@"%d:0%.0f",hours, minutes];
	}
	else{
		result = [NSString stringWithFormat:@"%d:%.0f",hours, minutes];
	}
    
	return result;
}

// convert double hours to 12h format
- (NSString *)floatToTime12:(double)time suffix:(BOOL)f
{
	if (isnan(time))
		return InvalidTime;
	
	time =[self fixhour:(time+ 0.5/ 60)];  // add 0.5 minutes to round
	double hours = floor(time); 
	double minutes = floor((time- hours)* 60);
	NSString *suffix, *result=nil;
	if(hours >= 12) {
		suffix = @"pm";
	}
	else{
		suffix = @"am";
	}
	//hours = ((((hours+ 12) -1) % (12))+ 1);
	hours = (hours + 12) - 1;
	int hrs = (int)hours % 12;
	hrs += 1;
	if(f == YES){
		if((hrs >=0 && hrs<=9) && (minutes >=0 && minutes <=9)){
			result = [NSString stringWithFormat:@"0%d:0%.0f %@",hrs, minutes, suffix];
		}
		else if((hrs >=0 && hrs<=9)){
			result = [NSString stringWithFormat:@"0%d:%.0f %@",hrs, minutes, suffix];
		}
		else if((minutes >=0 && minutes <=9)){
			result = [NSString stringWithFormat:@"%d:0%.0f %@",hrs, minutes, suffix];
		}
		else{
			result = [NSString stringWithFormat:@"%d:%.0f %@",hrs, minutes, suffix];
		}
		
	}
	else{
		if((hrs >=0 && hrs<=9) && (minutes >=0 && minutes <=9)){
			result = [NSString stringWithFormat:@"0%d:0%.0f",hrs, minutes];
		}
		else if((hrs >=0 && hrs<=9)){
			result = [NSString stringWithFormat:@"0%d:%.0f",hrs, minutes];
		}
		else if((minutes >=0 && minutes <=9)){
			result = [NSString stringWithFormat:@"%d:0%.0f",hrs, minutes];
		}
		else{
			result = [NSString stringWithFormat:@"%d:%.0f",hrs, minutes];
		}
	}
    
	return result;
}

// convert double hours to 12h format with no suffix
- (NSString *)floatToTime12NS:(double)time
{
	return [self floatToTime12:TimeFormatFloat suffix:NO];
}

#pragma mark - Compute Prayer Times

// compute prayer times at given julian date
- (NSMutableArray *)computeTimes:(NSMutableArray *)times
{
	NSMutableArray *t = [self dayPortion:times];
	
	id obj = methodParams[[NSNumber numberWithInt:calcMethod]];
	double idk = [obj[0] doubleValue];
	double Fajr    = [self computeTime:[t[0] doubleValue] andAngle:(180 - idk)];
	double Sunrise = [self computeTime:[t[1] doubleValue] andAngle:(180 - 0.833)];
	double Dhuhr   = [self computeMidDay: [t[2] doubleValue]];
	double Asr     = [self computeAsr:(1 + asrJuristic) andTime: [t[3] doubleValue]];
	double Sunset  = [self computeTime: [t[4] doubleValue] andAngle:0.833];
	double Maghrib = [self computeTime:[t[5] doubleValue] andAngle:[methodParams[[NSNumber numberWithInt:calcMethod]][2] doubleValue]];
	double Isha    = [self computeTime:[t[6] doubleValue] andAngle:[methodParams[[NSNumber numberWithInt:calcMethod]][4] doubleValue]];
	
	NSMutableArray *Ctimes = [@[@(Fajr),
                                @(Sunrise),
                                @(Dhuhr),
                                @(Asr),
                                @(Sunset),
                                @(Maghrib),
                                @(Isha)] mutableCopy];
	
	return Ctimes;
}

// compute prayer times at given julian date
- (NSMutableArray*)computeDayTimes
{
	//int i = 0;
	NSMutableArray *t1, *t2, *t3;
    
    //default times
	NSMutableArray *times = [@[@5.0,
                               @6.0,
                               @12.0,
                               @13.0,
                               @18.0,
                               @18.0,
                               @18.0] mutableCopy];
	
	for (int i=1; i<= numIterations; i++)  
		t1 = [self computeTimes:times];
	
	t2 = [self adjustTimes:t1];
	
	t2 = [self tuneTimes:t2];
	
	//Set prayerTimesCurrent here!!
	prayerTimesCurrent = [[NSMutableArray alloc] initWithArray:t2];
	
	t3 = [self adjustTimesFormat:t2];
	
	return t3;
}

//Tune timings for adjustments
//Set time offsets
- (void)tune:(NSMutableDictionary*)offsetTimes
{
	offsets[0] = offsetTimes[@"fajr"];
	offsets[1] = offsetTimes[@"sunrise"];
	offsets[2] = offsetTimes[@"dhuhr"];
	offsets[3] = offsetTimes[@"asr"];
	offsets[4] = offsetTimes[@"sunset"];
	offsets[5] = offsetTimes[@"maghrib"];
	offsets[6] = offsetTimes[@"isha"];
}

- (NSMutableArray *)tuneTimes:(NSMutableArray *)times
{
	double off, time;
	for(int i=0; i<[times count]; i++){
		//if(i==5)
		//NSLog(@"Normal: %d - %@", i, [times objectAtIndex:i]);
		off = [offsets[i] doubleValue]/60.0;
		time = [times[i] doubleValue] + off;
		times[i] = @(time);
		//if(i==5)
		//NSLog(@"Modified: %d - %@", i, [times objectAtIndex:i]);
	}
	
	return times;
}

// adjust times in a prayer time array
- (NSMutableArray *)adjustTimes:(NSMutableArray *)times
{
	int i = 0;
	NSMutableArray *a; //test variable
	double time = 0, Dtime, Dtime1, Dtime2;
	
	for (i=0; i<7; i++) {
		time = ([times[i] doubleValue]) + (timeZone- lng/ 15.0);
		
		times[i] = @(time);
		
	}
	
	Dtime = [times[2] doubleValue] + (dhuhrMinutes/ 60.0); //Dhuhr
		
	times[2] = @(Dtime);
	
	a = methodParams[[NSNumber numberWithInt:calcMethod]];
	double val = [a[1] doubleValue];
	
	if (val == 1) { // Maghrib
		Dtime1 = [times[4] doubleValue]+ ([methodParams[[NSNumber numberWithInt:calcMethod]][2] doubleValue]/60.0);
		times[5] = @(Dtime1);
	}
	
	if ([methodParams[[NSNumber numberWithInt:calcMethod]][3] doubleValue]== 1) { // Isha
		Dtime2 = [times[5] doubleValue] + ([methodParams[[NSNumber numberWithInt:calcMethod]][4] doubleValue]/60.0);
		times[6] = @(Dtime2);
	}
	
	if (adjustHighLats != AdjustMethodHigherLatitudeNone){
		times = [self adjustHighLatTimes:times];
	}
    
	return times;
}

// convert times array to given time format
- (NSMutableArray *)adjustTimesFormat:(NSMutableArray *)times
{
	int i = 0;
	
	if (timeFormat == TimeFormatFloat){
		return times;
	}
    
	for (i=0; i<7; i++) {
		if (timeFormat == TimeFormat12Hour){
			times[i] = [self floatToTime12:[times[i] doubleValue] suffix:YES];
		}
		else if (timeFormat == TimeFormat12WithNoSuffix){
			times[i] = [self floatToTime12:[times[i] doubleValue] suffix:NO];
		}
		else{
			
			times[i] = [self floatToTime24:[times[i] doubleValue]];
		}
	}
    
	return times;
}

// adjust Fajr, Isha and Maghrib for locations in higher latitudes
- (NSMutableArray*)adjustHighLatTimes:(NSMutableArray *)times
{
	double time0 = [times[0] doubleValue];
	double time1 = [times[1] doubleValue];
	//double time2 = [[times objectAtIndex:2] doubleValue];
	//double time3 = [[times objectAtIndex:3] doubleValue];
	double time4 = [times[4] doubleValue];
	double time5 = [times[5] doubleValue];
	double time6 = [times[6] doubleValue];
	
	double nightTime = [self timeDiff:time4 andTime2:time1]; // sunset to sunrise
	
	// Adjust Fajr
	double obj0 =[methodParams[[NSNumber numberWithInt:calcMethod]][0] doubleValue];
	double obj1 =[methodParams[[NSNumber numberWithInt:calcMethod]][1] doubleValue];
	double obj2 =[methodParams[[NSNumber numberWithInt:calcMethod]][2] doubleValue];
	double obj3 =[methodParams[[NSNumber numberWithInt:calcMethod]][3] doubleValue];
	double obj4 =[methodParams[[NSNumber numberWithInt:calcMethod]][4] doubleValue];
	
	double FajrDiff = [self nightPortion:obj0] * nightTime;
	
	if ((isnan(time0)) || ([self timeDiff:time0 andTime2:time1] > FajrDiff)) 
		times[0] = @(time1 - FajrDiff);
	
	// Adjust Isha
	double IshaAngle = (obj3 == 0) ? obj4: 18;
	double IshaDiff = [self nightPortion: IshaAngle] * nightTime;
	if (isnan(time6) ||[self timeDiff:time4 andTime2:time6] > IshaDiff) 
		times[6] = @(time4 + IshaDiff);
	
	
	// Adjust Maghrib
	double MaghribAngle = (obj1 == 0) ? obj2 : 4;
	double MaghribDiff = [self nightPortion: MaghribAngle] * nightTime;
	if (isnan(time5) || [self timeDiff:time4 andTime2:time5] > MaghribDiff) 
		times[5] = @(time4 + MaghribDiff);
	
	return times;
}

// the night portion used for adjusting times in higher latitudes
- (double)nightPortion:(double)angle
{
    double calc = 0;
    
    switch (adjustHighLats) {
        case AdjustMethodHigherLatitudeAngleBased:
            calc = (angle)/60.0f;
            break;

        case AdjustMethodHigherLatitudeMidNight:
            calc = 0.5f;
            break;
            
        case AdjustMethodHigherLatitudeOneSevent:
            calc = 0.14286f;
            break;
            
        case AdjustMethodHigherLatitudeNone:
        default:
            break;
    }
	
	return calc;
}

// convert hours to day portions 
- (NSMutableArray *)dayPortion:(NSMutableArray *)times
{
	int i = 0;
	double time = 0;
	for (i=0; i<7; i++){
		time = [times[i] doubleValue];
		time = time/24.0;
		
		times[i] = @(time);
		
	}
    
	return times;
}

@end