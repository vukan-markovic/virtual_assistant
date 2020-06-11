# Virtual assistant

![App icon](https://lh3.googleusercontent.com/lM1HGR_VCgf3FQMiwD66SpyT43lb0SF82sure7hhx0_ASsCdSbSbDqLF3Rp0pGEMtmY=s180-rw)

Virtual Assistant is an application that you can chat with and that can give you advice, jokes, quotes or lyrics.

It can also perform tasks such as setting alarms, setting timers, converting units of measure and currencies, finding the meaning of words in a dictionary, finding a location on a map, finding news, providing weather information, opening a web page, and initiating actions such as adding a new contact, the Internet search, navigate, email or text, or make a phone call.

You can communicate with the assistant via voice or text, and it supports multiple languages.

It can also recognize objects and text in the images you upload.

![Login page](https://lh3.googleusercontent.com/xa3fFsrdPmYV4TOkPa0OJhdOsFiMLyALr9sIqQliUEuoMzZXL_nHlcZDOvuaTCsLF_s=w720-h310-rw) ![Chatbot page 1](https://lh3.googleusercontent.com/XI9RXV_p0E6OmnazI3AoyW82Ybd5xJqeUHJYi05iyZw5-qjIi45NY7DkU_MNAWeKY5Cs=w720-h310-rw) ![Chatbot page 2](https://lh3.googleusercontent.com/-qEQEW2fYumQpOhN7vjdajUM6HHut6OYzwrHDr5mx1qjQSCWHN7THLXfjrC9fN4dqtA=w720-h310-rw) ![Assistant language settings](https://lh3.googleusercontent.com/kNnGG_YBXtxeVyDwZkbS-FwhYfWZlw8-HiALnXO2--BMH4ybk34Ad13Er7s53N6pVSg=w720-h310-rw)

![Chatbot page 3](https://lh3.googleusercontent.com/g9IvUbuyMHlkVP2oKx2D279V1s4ULdC87k3-fFrjVcGNF75AAZw5VfdyFBp2nrVnswe9=w720-h310-rw) ![Speech language settings](https://lh3.googleusercontent.com/Yxx4HJA43a0W5sM__eCUH-u-8YGO2zQ9NCg7XCfruIy7VSLeyDWCMqjoendPsNiBhg=w720-h310-rw) ![Chatbot page 4](https://lh3.googleusercontent.com/Hxau6AMID9Ug4cVF6y9AD5wORCoWz8WQbGwhblrq3TaNVucMpyS-2aKE-awMY2sYaQ=w720-h310-rw) ![Options menu](https://lh3.googleusercontent.com/LT-ntK-QoB76la_SiCVJTMXwecHaqdAI212oMn0knOFGcr5whUX-6z378ytDmhdxgQ=w720-h310-rw)

## Getting Started

This project is built using Flutter, Dialogflow and Firebase.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view [online documentation](https://flutter.dev/docs), which offers tutorials, samples, guidance on mobile development, and a full API reference.

More information about Dialogflow can be found at the following links:
- [Dialogflow website](https://dialogflow.com)
- [Dialogflow documentation](https://cloud.google.com/dialogflow)

Flutter plugin for Dialogflow which was used in this project can be found here: [Dialogflow Flutter plugin](https://github.com/VictorRancesCode/flutter_dialogflow).

For more info on using Firebase with Flutter visit: [Flutter Firebase documentation](https://flutter.dev/docs/development/data-and-backend/firebase). 

## Running project 

To run this project locally you must provide following: 
- Replace Credentials.admob_app_id and Credentials.admob_app_id constants in ad.dart file with your own Admob credentials to show ads. More on Admob on this site: [Admob](https://admob.google.com/home/)
- Replace Credentials.twitter_consumerKey and Credentials.twitter_consumerSecret constants in login.dart file with your own Twitter keys to use Twitter login. Find more about Twitter login here: [Twitter developer site](https://developer.twitter.com/en)
- Add your own service account file to assets folder to communicate with your Dialogflow agent. More on building Dialogflow agents and set up sevice accounts on following links: [Build agent](https://cloud.google.com/dialogflow/docs/quick/build-agent), [Setup service account](https://cloud.google.com/dialogflow/docs/quick/setup)
- Connect app with your own Firebase project. More on that here: [Adding Firebase to Android application](https://firebase.google.com/docs/android/setup)
- Add strings.xml file where you should add facebook_app_id and fb_login_protocol_scheme strings which represents keys used for Facebook login, and the already mentioned admob_app_id string for displaying advertisements
- This is release version of application. To run your own release version you must provide your own files for app signing. To get information on how to build and release an Android app check out the following link: [Building the app for release](https://flutter.dev/docs/deployment/android#building-the-app-for-release)
