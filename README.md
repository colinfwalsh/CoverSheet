# Cover Sheet

[![Swift Version][swift version badge]][swift version] [![Platform][platforms badge]][platforms] [![SPM][spm badge]][spm] [![IOS][ios badge]][ios] [![MIT][mit badge]][mit]

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
pod 'CoverSheet', '~> 0.1.0'
```

### Setup project

#### SwiftUI

```Swift
  // sheetManager conforms to Manager
  CoverSheetView(sheetManager) {
    // Background View is here
  } sheet: { 
    // Sheet View goes here
  }
```

#### UIKit

```Swift
  let vc = CoverSheetController()
  
  // viewDidLoad
  vc.configure(inner: innerVC, sheet: sheetVC)
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
[spm]: https://www.swift.org/package-manager/
[ios badge]: https://img.shields.io/badge/iOS-13%2B-blue
[ios]: https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-15-release-notes

[cover-example-swiftUI]: https://github.com/colinfwalsh/CoverSheet-SwiftUI-Example
[cover-example-uikit]: https://github.com/colinfwalsh/CoverSheet-UIKit-Example

[example-gif]: hhttps://tenor.com/b2c9m.gif
