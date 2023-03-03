# Cover Sheet

Cover sheet is a dynamic, customizable, bottom sheet that supports both UIKit and SwiftUI (starting with SwiftUI 1).  You'll also be able to mix and match SwiftUI and UIKit views as needed to create any view you can imagine.  In addition, CoverSheet also supports dynamic fullscreen animations similar to what you'd see in the `Messages` app on iPhone.

## SwiftUI

Using CoverSheet is easy in SwiftUI, and an example is included in Example_SwiftUI.

## UIKit

CoverSheet accepts any UIViewController as arguments in it's `configure` method.  Simply initialize CoverSheet and configure with the corresponding UIViewControllers

## Install

Simply go to `Add Packages -> URL -> <this git repo url>` to add to your project in XCode.  Latest version is `0.1.0`.

## Delegate and Manager

Right now CoverSheet just supports one delegate method `coverSheet(currentState: SheetState)`.  The method will inform you of whenver the sheet state changes so you can update views as needed.  Also included is a `DefaultManager` for use in SwiftUI.  If you need to create your manager, simply conform to the `Manager` protocol.

## Todos

[] Customize sheet animations and deeper blur effects
[] Customize handle bar to support custom views
[] Expand delegation methods

Thanks for checking out the library!  If have any trouble, feel free to start an issue or open up a PR.
