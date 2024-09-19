# ViewPortObserver Modifier for SwiftUI

`ViewPortObserver` is a custom SwiftUI modifier packaged into a Swift Package Manager library that allows developers to observe the visibility of a view component on the screen. By leveraging this modifier, you can track when a view enters or exits the visible screen area, helping to trigger events based on a view's lifecycle.

## Preview

<table class="tg"><thead>
  <tr>
    <td class="tg-0lax"><img src="https://github.com/ElyesDer/ViewPortObserver/blob/main/Screenshots/preview_1.gif" width="500"/></td>
  </tr></thead>
</table>

## Features

- **Track View Visibility:** Detect when a view appears or disappears from the screen viewport.
- **Flexible Axis Control:** You can specify whether you want to observe the view's position along the horizontal or vertical axis.
- **Coordinate Space Customization:** Allows customization of the coordinate space (e.g., `.global` or custom spaces) for finer control over the observation.
- **Lifecycle Callbacks:** Triggers a completion handler when the view's lifecycle state changes, such as entering or exiting the screen.
- **Support for Older iOS Versions:** The modifier works on iOS versions older than iOS 17 by leveraging injected container sizes.

## Installation

To use `ViewPortObserver` in your project, follow these steps:

1. In Xcode, navigate to **File** > **Add Packages**.
2. Search for the repository by its URL.
3. Add the package to your project.
4. Import the package where needed:

```swift
import ViewPortObserver
```

## How to Use

### iOS17 +

You can apply the `observerViewPort` modifier to any `View` in SwiftUI. Below is a typical example of how to use the modifier:

```swift
import SwiftUI
import ViewPortObserver

struct MyView: View {
    @State private var currentViewState: ViewLifeCycle = .disappeared
    @State private var coordinateSpace: CoordinateSpace = .global
    
    var body: some View {
        VStack {
            Text("Track me!")
                .observerViewPort(
                    axis: .vertical, 
                    coordinatedSpace: coordinateSpace
                ) { changes in
                    currentViewState = changes
                    handleVisibilityChanges(changes)
                }
        }
    }

    func handleVisibilityChanges(_ changes: ViewLifeCycle) {
        switch changes {
        case .appear:
            print("The view is visible on screen")
        case .disappear:
            print("The view has disappeared from the screen")
        }
    }
}
```

### Parameters

- **`axis: Axis`**: Defines the axis to observe, either `.vertical` or `.horizontal`.
- **`coordinatedSpace: CoordinateSpaceProvider`**: Sets the coordinate space. By default, this is `.global`, which refers to the entire screen.
- **`onViewPortChange: @escaping (ViewLifeCycle) -> Void`**: A closure that returns a `ViewLifeCycle` enum, allowing you to respond to changes in the view's visibility (appeared, disappeared, etc.).

## Supporting Older iOS Versions (Before iOS 17)

In iOS 17 and later, the `GeometryProxy.bounds(in:)` method is available, allowing easy access to a view's bounds in a given coordinate space. However, for earlier versions of iOS, this functionality is not present. To ensure compatibility, `observerViewPort` uses an alternative approach by injecting the container size explicitly.

### Injecting Container Size for Compatibility

For older versions of iOS, the viewport calculation requires the container size to be injected via a `CGSize` parameter. This is typically done by wrapping your view in a `GeometryReader` to retrieve the view's size.

Example for older iOS versions:

```swift
GeometryReader { geometry in
    MyView()
        .observerViewPort(
            axis: .vertical,
            container: .init(
                width: geometry.size.width, 
                height: geometry.size.height
            ),
            coordinatedSpace: .global
        ) { changes in
            currentViewState = changes
        }
}
```

### Why Injecting Container Size?

Without the `GeometryProxy.bounds(in:)` method, the view's size and position within a specific coordinate space cannot be automatically determined. By explicitly passing the size of the container (i.e., the size of the view's parent or surrounding view), we can perform viewport calculations in earlier iOS versions without needing access to `bounds(in:)`.

This ensures backward compatibility and provides a consistent API regardless of the iOS version being used.

### View Lifecycle Enum

The `ViewLifeCycle` enum captures the state of the view in relation to the viewport:

```swift
public enum ViewLifeCycle {
    case appear
    case disappear
}
```

- **`appear`**: The view is fully or partially visible within the specified coordinate space.
- **`disappear`**: The view is no longer visible.

## Real-World Usage Scenarios

- **Lazy Loading**: Track when a view enters the screen to trigger the loading of remote data (e.g., images or network requests) to optimize performance.
  
  ```swift
  Image("LazyLoadedImage")
      .observerViewPort(axis: .vertical) { changes in
          if changes == .appear {
              loadRemoteImage()
          }
      }
  ```

- **View Analytics**: Monitor how long a view stays on screen to gather analytics on user interaction with certain UI elements.
  
  ```swift
  struct AdView: View {
      @State private var adViewState: ViewLifeCycle = .disappear

      var body: some View {
          AdComponent()
              .observerViewPort(axis: .vertical) { changes in
                  adViewState = changes
                  trackAdImpressions()
              }
      }

      func trackAdImpressions() {
          if adViewState == .appear {
              // Send tracking data to analytics server
          }
      }
  }
  ```

- **Animations on Visibility**: Trigger animations only when a view is visible on screen.
  
  ```swift
  VStack {
      MyAnimatedView()
          .observerViewPort(axis: .vertical) { changes in
              if changes == .appear {
                  withAnimation {
                      // Start animations
                  }
              }
          }
  }
  ```

## How It Works

The `observerViewPort` modifier attaches itself to a view and calculates its position in relation to the screen's coordinate system (or any other coordinate space you provide). It observes the view's position along the specified axis (vertical or horizontal) and triggers the `onViewPortChange` closure whenever the view's lifecycle state changes.

### Key Calculation Points

1. **Global Coordinate Space**: By default, the modifier tracks the view in the `.global` coordinate space, which refers to the device's screen boundaries.
2. **Visibility Checking**: The modifier uses the size and position of the view in the chosen coordinate space to determine when it enters or leaves the visible area.
3. **Axis-Based Control**: The `axis` parameter allows you to fine-tune the modifier to track visibility only along a specific axis. This is useful for cases like horizontally or vertically scrolling views.

### Efficient Observations

The observation process is lightweight and only triggers when necessary, reducing unnecessary overhead. This makes it suitable for use with multiple views or components that may require viewport tracking.

## Summary

`ViewPortObserver` is a powerful and flexible tool for tracking view visibility in SwiftUI. Whether you want to optimize performance, track analytics, or trigger animations, this library provides an easy-to-use solution for view lifecycle observation.

## License

This library is open-source and available under the MIT license.
