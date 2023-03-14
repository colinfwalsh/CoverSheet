# Cover Sheet

[![Swift Version][swift version badge]][swift version] [![Platform][platforms badge]][platforms] [![SPM][spm badge]][spm] [![IOS][ios badge]][ios] [![MIT][mit badge]][mit] ![Pod Version][pods_badge]

Cover sheet is a dynamic, customizable, sheet that supports both UIKit and SwiftUI.  You'll also be able to mix and match SwiftUI and UIKit views as needed to create any view you can imagine.  In addition, CoverSheet also supports dynamic fullscreen animations similar to what you'd see in the `Messages` app on iPhone.

[example-gif]
___

## Requirements

| **Platform** | **Minimum Swift Version**  |
|:----------|:----------|
| iOS 13+    | 5.0   |

## Installation

### SPM

If you're using [Swift package manager][spm], simply add CoverSheet as a dependency in your `Package.swift` file.

```Swift
dependencies: [
    .package(url: "https://github.com/colinfwalsh/CoverSheet.git", branch(“main”))
]
```

### Cocoapods

```Pods
pod 'CoverSheet', '~> 0.1.2'
```

### Setup project

Out of the box, you're provided with a `DefaultSheetManager` and `DefaultSheetState` which should serve most of your needs.  `DefaultSheetState` provides you with 5 states:

```Swift

// Sheet is offscreen
// 0% of view height
DefaultSheetState.hidden

// Sheet is in a collapsed state, similar to what you'd see in Google maps on initial load 
// 35% of view height
DefaultSheetState.collapsed

// Sheet is in an expanded state, but you can still see content in the inner view
// 70% of view height
DefaultSheetState.normal

// Sheet is the primary focus but you're still able to see the inner view
// 90% of view height
DefaultSheetState.full

// Sheet takes up the full screen and animates away the corner radius and handle bar
// 100% of view height
DefaultSheetState.cover
```

#### SwiftUI

```Swift
  // Define your State array
  var states: [DefaultSheetState] = [.hidden, .collapsed, .normal]
  // sheetManager conforms to Manager
  CoverSheetView(sheetManager, states: states) {
    // Background View is here
  } sheet: { 
    // Sheet View goes here
  }
```

#### UIKit

If you're initializing CoverSheet programatically, simply use the built in initializer.

```Swift

  // If you're initializing programatically, use the built in initializer
  var states: [DefaultSheetState] = [.hidden, .collapsed, .normal]
  let vc = CoverSheetController(states: states)
  
  // viewDidLoad
  vc.configure(inner: innerVC, sheet: sheetVC)
```

For storyboards, you'll need to set your ViewController class to CoverSheetController in your storyboard and then define your ViewController like so.

```Swift

// Defining your ViewController

class MyViewController: CoverSheetController<DefaultSheetManager, DefaultSheetState> {
  override func viewDidLoad() {
    super.viewDidLoad()

    // Configuration goes here
  }
}

```

Alternatively, if you've declared a custom `Manager` with a custom `SheetState` you can define the ViewController as follows.

```Swift
class MyCustomManager: Manager { ... }
enum MySheetState: CGFloat, RawRepresentable { ... }

class MyViewController: CoverSheetController<MyCustomManager, MySheetState> { ... }
```

#### Configuring

There are many public methods for you to update / override values for `CoverSheet` including setting custom managers, states, animations, and more.  Below are brief summaries of the methods available:

```Swift
    // Sets the Inner and Sheet ViewControllers - used in UIKit
    public func configure(inner: UIViewController, sheet: UIViewController) {}
    
    // Sets the Inner and Sheet Views - only use this if you're creating a custom implementation of CoverSheetView
    public func configure(inner: some View, sheet: some View) {}
    
    // Called on a SwiftUI redraw
    public func updateViews(inner: some View, sheet: some View) {}
    
    // Updates the current value in the manager.  If the value is not present in the state array, it's added and the states are sorted again
    public func updateCurrentState(_ newState: EnumValue) {}

    // Overrides the manager.  Only used if initializing via Storyboard.
    public func overrideManager(_ manager: ViewManager) {}
    
    // Overrides the states.  Only used if initializing via Storyboard.
    public func overrideStates(_ states: [EnumValue]) {}
    
    // Overrides the animation config, which in turn, updates the animations the sheet uses
    public func overrideAnimationConfig(_ config: AnimationConfig) {}
    
    // Overrides the animation values directly which will kick off the creation of a new AnimationConfig
    public func overrideAnimationValues(timing: CGFloat = 0.1,
                                        options: UIView.AnimationOptions = [.curveLinear],
                                        springDamping: CGFloat = 2.0,
                                        springVelocity: CGFloat = 7.0) {}
    
    // Updates the blur effect and background color of the sheet
    public func updateSheet(shouldBlur: Bool, backgroundColor: UIColor) {}
```

### Protocols

To configure `CoverSheet` you have a few options depending on which UI framework you're using

- `CoverSheetDelegate` - conform to the cover sheet delegate, helpful if you're using UIKit or if you're making a custom manager
- `Manager` - protocol for defining your own sheet manager in SwiftUI.  `CoverSheetView` requires an object that conforms to this protocol. Use `DefaultSheetManager` if you do not need any custom functionality.
- `Containable` - a protocol for defining your own `ContainerViewControllers`.  You likely shouldn't need this, but it's exposed in case you need a completely custom solution.

## Project example

[SwiftUI Example][cover-example-swiftUI] - example of using `CoverSheet` in SwiftUI

[UIKit Example][cover-example-uikit] - example of using `CoverSheet` in UIKit

[swift version]: https://swift.org/download/
[swift version badge]: https://img.shields.io/badge/swift-5.0-red
[platforms badge]: https://img.shields.io/badge/platforms-ios-lightgrey
[platforms]: https://swift.org/download/
[mit badge]: https://img.shields.io/badge/license-MIT-lightgrey
[mit]: https://github.com/Mijick/PopupView/blob/main/LICENSE
[spm badge]: https://img.shields.io/badge/spm-compatible-green
[pods_badge]: https://img.shields.io/cocoapods/v/CoverSheet
[spm]: https://www.swift.org/package-manager/
[ios badge]: https://img.shields.io/badge/iOS-13%2B-blue
[ios]: https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-15-release-notes

[cover-example-swiftUI]: https://github.com/colinfwalsh/CoverSheet-SwiftUI-Example
[cover-example-uikit]: https://github.com/colinfwalsh/CoverSheet-UIKit-Example

[example-gif]: hhttps://tenor.com/b2c9m.gif
