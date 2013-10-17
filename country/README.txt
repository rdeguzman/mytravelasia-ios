+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CLONING TARGETS
1. Clone Target from Targets List. Right click on target and "Duplicate".
2. Change the country name to "Thailand"
3. Product > Manage Schemes
4. Click on "Autocreate Schemes Now". This will add "Thailand". Ok
5. Thailand > Build Phases > Copy Bundle Resources. Delete images and Map.plist
6. Add folder "TH" to ResourceByCountry. Make sure you choose target "Thailand"
7. Change getName to "Thailand" for Country.m
8. Change "Product Name" in Build Settings to "Thailand"

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REMINDERS:
Checklist for production building
1. MapListViewController.newLocationUpdate should not contain:
//  if( TARGET_IPHONE_SIMULATOR ){
//    NSLog(@"MainListViewController.newLocationUpdate. Testing from the IPHONE SIMULATOR");
//    _coordinate.latitude = kCoordinateDefaultCenterLatitude;
//    _coordinate.longitude = kCoordinateDefaultCenterLongitude;
//  }

OR build an archive for adhoc and upload it in testflight. XCode > Product > Archive > Testflight.

2. Modify Country.h

3. Build/Products should be country_name

For Duplicating with Other Countries. We need to prepare the ff:
1. city_bg.png
2. country_bg.png
3. header.png

BOOKING URL HOTELSCOMBINED
http://www.hotelscombined.com/Mobile/Hotel/Hotel_H2O_Manila.htm?languageCode=EN&a_aid=xxxx&brandid=xxxx

Dependencies for Testing
- Frank https://github.com/moredip/Frank
- GHUnit

