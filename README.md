**SST Announcer**
==========================


Made by StatiX Industries  

##Name:
* SST Announcer

##Synopsis:
###This application is still WORK IN PROGRESS! Some of the features may not be reflected in the actual build!  
The Application is used for fetching RSS feeds over the Internet with HTTPS with a proxy server hosted by SST INC  
Also, the app can push notifications to the user's iDevice (automatically registers with OneSignal servers)  
Feed source: http://studentsblog.sst.edu.sg/feeds/posts/default?alt=rss

1. Has inbuilt table that displays RSS feeds from the Student's Blog
2. Feeds are displayed in a beautiful rich text view, courtesy of DTCoreText, and falls back to a web view if there are special elements that cannot be displayed
3. Has loading indicators for web loading, feed loading and others
4. Is able to display multiple categories of the blog (fetches data)
5. Pushes notifications to the user when the feed is updated (via OpenSignal + APNS)
6. Has inbuilt web browser to open links
7. Almost entirely written in Apple's new programming language Swift, with exception of certain third party APIs


##Availability:
The App is only usable on the iOS 8.0+ platform
Compiles on iOS SDK 10.1, downwards compatible to iOS 8.0


##Description:
The Application is made for fetching RSS feeds from the abovementioned URL. Other than that, it also pushes notifications to the user's iDevice via OpenSignal over APNS.


##Author(s):
FourierIndustries:
* Lead Developer and Debugger: Pan Ziyue
* Graphics Designer: Christopher Kok and Dalton Ng
* Beta Tester: Liaw Xiao Tao


##Caveats:
* The Xcode Project file must be opened in Xcode 8.1 for iOS 10.1 SDK
* SwiftLint is required. If you do not need SwiftLint, you have to remove the final build phrase
* All the external dependencies MUST be met in order to compile the project (including account-specific dependencies such as Fabric). If you choose not to, you have to delete the run scripts phrase and delete the dependency entirely from the project.


##Dependencies:
* Fabric/Crashlytics
* SnapKit (http://snapkit.io)
* OneSignal (https://onesignal.com)
* JGProgressHUD (https://github.com/JonasGessner/JGProgressHUD)
* DTCoreText (https://github.com/Cocoanetics/DTCoreText)
* TUSafariActivity (https://github.com/davbeck/TUSafariActivity)
* JDFNavigationBarActivityIndicator (https://github.com/JoeFryer/JDFNavigationBarActivityIndicator)
* SGNavigationProgress (https://github.com/sgryschuk/SGNavigationProgress)


##License:
* GNU Public License v2


##Final Note:
Yes I wrote it in the format of a UNIX command manual page

Copyright (C) FourierIndustries (formerly StatiX Industries) 2013-2016
