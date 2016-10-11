# AFMActionSheet

[![CI Status](http://img.shields.io/travis/ask-fm/AFMActionSheet.svg?style=flat)](https://travis-ci.org/ask-fm/AFMActionSheet)
[![Version](https://img.shields.io/cocoapods/v/AFMActionSheet.svg?style=flat)](http://cocoapods.org/pods/AFMActionSheet)
[![License](https://img.shields.io/cocoapods/l/AFMActionSheet.svg?style=flat)](http://cocoapods.org/pods/AFMActionSheet)
[![Platform](https://img.shields.io/cocoapods/p/AFMActionSheet.svg?style=flat)](http://cocoapods.org/pods/AFMActionSheet)

AFMActionSheet provides a AFMActionSheetController that can be used in places where one would use a UIAlertController, but a customized apperance or custom presentation/dismissal animation is needed. Seeing as how AFMActionSheetController was inspired by UIAlertController, it too supports ActionSheet and Alert styles to make your life even easier.

![Action Sheet Example](https://raw.githubusercontent.com/ask-fm/AFMActionSheet/master/res/action_sheet.gif)
![Alert Example](https://raw.githubusercontent.com/ask-fm/AFMActionSheet/master/res/alert.gif)

## Usage
To create an action sheet with default style and default transition animations:
```swift
let actionSheet = AFMActionSheetController()
let action = AFMAction(title: "Action", enabled: true, handler: { (action: AFMAction) -> Void in
    // Do something in handler
}
actionSheet.add(action)
self.present(actionSheet, animated: true, completion: {
    // Do something after completion
})
```
That's it.

## Detailed look
### Style
AFMActionSheetController supports two styles: the default action sheet style and alert style. These are set via initializers with `ControllertStyle` enum (`ControllertStyle.actionSheet` and `ControllertStyle.alert` accordingly)
```swift
let actionSheet = AFMActionSheetController(style: .actionSheet)
let alert = AFMActionSheetController(style: .alert)
```

### Transitioning animations
To change presentation and dismissal animations, implement a `UIViewControllerTransitioningDelegate` and pass it to AFMActionSheetController
```swift
let actionSheet = AFMActionSheetController(transitioningDelegate: myCustomTransitioningDelegate)
```
or
```swift
actionSheet.setup(myCustomTransitioningDelegate)
```

### Action controls
Action sheet's controls are created by adding `AFMAction` objects to the controller
```swift
actionSheet.add(action)
```
It is also possible to add actions as "Cancel actions". When using `ControllertStyle.ActionSheet` style, controls for these actions will be displayed in the bottom "Cancel section".
```swift
actionSheet.add(cancelling: action)
```
To use custom views as action controls just pass the view with action to `add(_:with:)` or `add(cancelling:with:)` method
```swift
actionSheet.add(action, with: myCustomControl)
actionSheet.add(cancelling: action, with: myCustomControl)
```
Height of the action control is whatever height passed custom view specifies, but it is possible to specify minimal control height with `minControlHeight` property.

### Title view
Title view is a view that is located on top of the action sheet and works similar to action controls.
To set the title view with custom view
```swift
actionSheet.add(title: myCustomTitleView)
```
or to set a default `UILabel` with a text
```swift
actionSheet.add(titleLabelWith: "Title")
```
Like with action control height, it is possible to specify minimal control height with `minTitleHeight` property.

### Other customizations
There is a number of properties to help further modify the look and behavior of action sheet controller:

- `spacing: Int` specifies content's spacing between action controls (default is `4`)
- `horizontalMargin: Int` specifies spacing from content to controller's top and bottom (default is `16`)
- `verticalMargin: Int` specifies spacing from content to controller's  left and right (default is `16`)
- `cornerRadius: Int` specifies corner radius of content (default is `10`)
- `backgroundColor: UIColor` specifies controller's background color (default is `blackColor().colorWithAlphaComponent(0.5)`)
- `spacingColor: UIColor` specifies content's spacing color (default is `.clearColor()`)
- `outsideGestureShouldDismiss: Bool` specifies whether the click on background outside of controls and title dismisses action sheet (default is `true`)


## Example project
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 8 and up.

## Installation

AFMActionSheet is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AFMActionSheet"
```

## Contact person

Ilya Alesker, ilya.alesker@ask.fm

## License

AFMActionSheet is available under the MIT license. See the LICENSE file for more info.
