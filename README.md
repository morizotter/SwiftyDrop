# SwiftyDrop

SwiftyDrop is a lightweight pure Swift simple and beautiful dropdown message.

[![Version](https://img.shields.io/cocoapods/v/SwiftyDrop.svg?style=flat)](http://cocoadocs.org/docsets/SwiftyDrop) [![License](https://img.shields.io/cocoapods/l/SwiftyDrop.svg?style=flat)](http://cocoadocs.org/docsets/SwiftyDrop) [![Platform](https://img.shields.io/cocoapods/p/SwiftyDrop.svg?style=flat)](http://cocoadocs.org/docsets/SwiftyDrop)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Join the chat at https://gitter.im/morizotter/SwiftyDrop](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/morizotter/SwiftyDrop?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

##Features

- Easy to use like: `Drop.down("Message")`
- Expand message field depends on the message.

##How it looks

### States
![Default](misc/Default.png)
![Success](misc/Success.png)
![Warning](misc/Warning.png)
![Error](misc/Error.png)

## Blurs
![Light](misc/Light.png)
![Dark](misc/Dark.png)

## iPad
![iPad](misc/iPadPortlait.png)

##Runtime Requirements

- iOS8.1 or later
- Xcode 6.3

## Installation and Setup

**Note:** Embedded frameworks require a minimum deployment target of iOS 8.1.

**Information:** To use SwiftyDrop with a project targeting iOS 8.0 or lower, you must include the `SwiftyDrop/Drop.swift` source file directly in your project.

###Installing with CocoaPods

[CocoaPods](http://cocoapods.org) is a centralised dependency manager that automates the process of adding libraries to your Cocoa application. You can install it with the following command:

```bash
$ gem update
$ gem install cocoapods
$ pods --version
```

To integrate TouchVisualizer into your Xcode project using CocoaPods, specify it in your `Podfile` and run `pod install`.

```bash
platform :ios, '8.1'
use_frameworks!
pod "SwiftyDrop", '~>1.0'
```

###Installing with Carthage

Just add to your Cartfile:

```ogdl
github "morizotter/SwiftyDrop" >= 1.0.0
```

###Manual Installation

To install SwiftyDrop without a dependency manager, please add all of the files in `/SwiftyDrop` to your Xcode Project.

##Usage

### Basic
To start using SwiftyDrop, write the following line wherever you want to show dropdown message:

```swift
import SwiftyDrop
```

Then invoke SwiftyDrop, by calling:

```swift
Drop.down("Message")
```

It is really simple!

### States and Blurs
SwiftyDrop has 2 types of display. First is **State**. Second is **Blur**. You can customize looks using them. Examples are:

```swift
Drop.down("Message", state: .Success)

Drop.down("Message", blur: .Light)
```

**States** are enum:
- .Default
- .Info
- .Success
- .Warning
- .Error

**Blurs** are also enum:
- .Light
- .ExtraLight
- .Dark

##Contributing

Please file issues or submit pull requests for anything you’d like to see! We're waiting! :)

##Licensing
SwiftyDrop is released under the MIT license. Go read the LICENSE file for more information.
