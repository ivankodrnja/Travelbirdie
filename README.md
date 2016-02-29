## Travelbirdie

This is the capstone project towards Udacity's iOS Nanodegree. 

## Overview

Travelbirdie enables you to search for vacation rentals worldwide and choose your next dream vacation. You can enjoy access from over 2,500,000 Vacation Rental and Short term rentals listings across the world in over 200,000 destinations. We return results for short term rentals ranging from apartments, houses, cottages, villas, castles from all over the world. No registration is required, just enter few basic details and you are ready to go. If you can't decide immediately you can save interesting vacation rentals to a Favorites list for later, the list is persisted and will wait for you in the app. 


## Details

Just search for the destination, location search is done using Google Maps API, define number of people, check-in and check-out dates and perform search. Zilyo API, available at http://www.mashape.com, provides data that powers the search. Travelbirdie is aggregator app and thanks to Zilyo supports these 23 suppliers: Airbnb, HomeAway, AlwaysOnVacation, ApartmentsApart, BookingPal, BedyCasa, CitiesReference, Geronimo, Gloveler, HolidayVelvet, HomeStay, HostelWorld, HouseTrip, Interhome, 9Flats, Roomorama, StopSleepGo, TheOtherHome, Travelmob, VacationRentalPeople, VaycayHero, WayToStay, and WebChalet.

## Google Maps Installation
Google Maps API is installed using Cocoa Pods. Detailed installation steps are here https://developers.google.com/maps/documentation/ios-sdk/start. 
#### 1. Get Cocoa Pods by running the following command from the terminal:
``` $ sudo gem install cocoapods ```
###" 2. Install Google Map Pod locally
Podfile is already present in the repository. In the directory contaning the "Podfile" run the command 
``` $ pod install ```
After installation .xcworkspace is created. From this time onwards, you must use the .xcworkspace file to open the project in Xcode.


## Special notes to Udacity reviewers

Search results data is intentinolly not persisted as it can happen that the user makes frequent searchs and this way he gets fresh results. Persistence is enabled in the Favorites section of the app.
Google Maps API is installed using Cocoa Pods. 
Image gallery slider in the apartment detail view is done using Auk image slideshow library from https://github.com/evgenyneu/Auk.
Booking is intended to be done on the web page of the vacation renatal provider, in the app it is done using a webview. As there is no special agreement between me and providers, like Homeaway, I'm not able to share a specific booking link for each property. Once this app goes to its commercial phase, the process of booking will be made with a better user experience.

## License

The MIT License (MIT)

Copyright (c) 2015 Ivan Kodrnja

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.