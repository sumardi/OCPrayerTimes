# Objective-C Library for Muslim Prayer Times

[![Build Status](https://travis-ci.org/sumardi/OCPrayerTimes.png)](https://travis-ci.org/sumardi/OCPrayerTimes)

OCPrayerTimes is an Objective-C library for calculating Muslim Prayer Times. 
Modified version of the original source code written by Hamid Zarrabi-Zadeh and 
Hussain Ali from [PrayTimes.org][1]. The source code was modified by [Sumardi Shukor][2] 
for taking advantage of modern Objective-C language such as [ARC][3], [object literals][4], etc. 

[1]: http://www.praytimes.org
[2]: https://www.twitter.com/sumardi
[3]: http://clang.llvm.org/docs/AutomaticReferenceCounting.html
[4]: http://clang.llvm.org/docs/ObjectiveCLiterals.html

## License 

OCPrayerTimes is available under the MIT license (see LICENSE file).

PrayTimes is free software;  it is released under a GNU LGPL v3.0 license
that allows you to do as you wish with it as long as you don't attempt
to claim it as your own work. 

## Requirements

OCPrayerTimes 0.1.0 and higher requires Xcode 5, targeting either iOS 6.0 and above, 
or Mac OS 10.8 Mountain Lion (64-bit with modern Cocoa runtime) and above.  

The following Cocoa frameworks must be linked into the application target for proper compilation:

* **CoreLocation.framework**

## Installation

### CocoaPods (Recommended)

[CocoaPods][5] is the recommended way to add OCPrayerTimes to your Xcode project.  

Here's an example `Podfile` that installs OCPrayerTimes. 

[5]: http://www.cocoapods.org

#### Podfile

```ruby
platform :osx, '10.8'
pod 'OCPrayerTimes', '~> 0.1.0'
```

Then run `pod install`.

### Manual

Just add `PrayTime.h` and `PrayTime.m` to your Xcode project.

## Examples

Depending on how you configure your project you may need to `#import` either `<OCPrayerTimes/PrayTime.h>` or `"PrayTime.h"`.

### Getting prayer times for a given longitude and latitude

```objective-c
PrayTime *prayerTime = [[PrayTime alloc] initWithJuristic:JuristicMethodShafii
                                           andCalculation:CalculationMethodMWL];
NSMutableArray *prayerTimes = [prayerTime prayerTimesDate:[NSDate date]
                                                 latitude:3.1667
                                                longitude:101.7000
                                              andTimezone:[prayerTime getTimeZone]];
NSLog(@"%@", prayerTimes);

```

### Getting prayer times from current user location

```objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    
    [self.locationManager startUpdatingLocation];

    prayTime = [[PrayTime alloc] initWithJuristic:JuristicMethodShafii
                                   andCalculation:CalculationMethodMWL];
    [prayTime setTimeFormat:TimeFormat12Hour];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    praytime = [prayTime prayerTimesFromLocation:location
                                         forDate:[NSDate date]];
}
```

## Reference

- [http://www.praytimes.org](http://www.praytimes.org)
- [Prayer Times Calculation](http://www.praytimes.org/wiki/Prayer_Times_Calculation)

## Support

Bugs and feature request are tracked on [Github](https://github.com/sumardi/OCPrayerTimes/issues)

## Credit

The code on which this package is [based][1], is principally developed and maintained by [Sumardi Shukor][2].
