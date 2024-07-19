# projectcar

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Overview

PREBET UTM mobile application aims to move the users of the current PREBET UTM services from the telegram group chat to this mobile application. This app provides services that allows the user to create ride requests, cancel ride requests and rate the drivers. The drivers can accept a ride request made by the user and manage the active rides and cancel the ride request if needed. The driver can also vote for fare adjustment. The admin includes CRUD functions to manage user and driver also to initiate voting session for fare adjustment. 

## Key Features
- **Firebase Cloud Messaging**: User and drivers can send push notifcations to each other using FCM as a way to notify the other party.
- **Location Tracking**: The user can track the position of the driver on their device the drivers location will update every 2 minutes 30 seconds. 

## Important

When cloning this repository please reconfigure the firebase connection to a new account. Using FlutterFire CLI can ease the process as it will automate the process. Please also get a new google service account .json folder in the google cloud console as it contains personal information. This repository does not include the current service account folder. Remember to also allow your firebase permission and rules to read and write.

## Installation Setup and Guide

Follow these steps to run projectcar in your IDE:

1. **Clone the Repository**
    Visit the Repository at https://github.com/Gazjibby/ProjectCAR

2. **Get Flutter Packages**
    Run the command
    ```bash
    flutter pub get
    ```
3. **Install FlutterFire CLI**
    Run the command
    ```bash
    dart pub global activate flutterfire_cli
    flutterfire configure
    ```
    Watch any youtube tutorial for better understanding

4. **Add google service account** 
    Insert the service account at lib/Asset/

5. **Run the app**
    Run the command 

    ```bash
    flutter run
    ```
## Contact

Contact the previous owner via najib01jamaludin@gmail.com for more information and guidance
