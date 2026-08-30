# Postcard

Postcard is a focused, private visual journal for iPhone: **one place, one photo, one sentence.**

## Run

Open `Postcard.xcodeproj` in Xcode 26 or later and run the `Postcard` scheme on an iPhone simulator or device. The app targets iOS 18 and uses SwiftUI, SwiftData, PhotosUI, MapKit, and Core Location. No third-party packages or network services are used.

The first launch includes three local sample postcards so the collection and map can be evaluated immediately. Delete them from each postcard's menu if you want to start fresh.

## Privacy

Photos are imported only after an explicit picker or camera action. Image and location metadata are processed on-device, and postcards are stored locally with SwiftData. The app has no accounts, analytics, advertising, or social features.
