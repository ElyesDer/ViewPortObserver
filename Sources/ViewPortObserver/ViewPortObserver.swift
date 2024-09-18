//
//  ViewPortObserver.swift
//
//
//  Created by Elyes Derouiche on 28/12/2023.
//

import SwiftUI

public struct ViewPortObserver: ViewModifier {

    public enum CoordinateSpaceProvider: Hashable {
        /// Custom coordinateSpace should be defined else the `global` coordinate space will be returned
        case named(String)
        case global

        public var name: String {
            switch self {
            case let .named(name):
                return name
            default:
                return ""
            }
        }

        var coordinateSpace: CoordinateSpace {
            switch self {
            case .global:
                return .global
            case let .named(name):
                return .named(name)
            }
        }
    }

    public enum ViewLifeCycle {
        case appear
        case disappear
    }

    private struct ViewOffsetKey: @preconcurrency PreferenceKey {
        typealias Value = ViewLifeCycle
        @MainActor static let defaultValue = ViewLifeCycle.appear
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = nextValue()
        }
    }

    private var axis: Axis
    private var coordinatedSpace: CoordinateSpaceProvider
    private var onViewPortChange: (ViewLifeCycle) -> Void

    @available(
        iOS,
        introduced: 13.0,
        deprecated: 17.0,
        message: "ViewPortObserver prior iOS17 does not need container's CGSize to perform calculation"
    )
    private var container: CGSize = .zero

    @available(
        iOS,
        introduced: 13.0,
        deprecated: 17.0,
        message: "ViewPortObserver prior iOS17 does not need container's CGSize to perform calculation"
    )
    init(
        axis: Axis,
        container: CGSize = .zero,
        coordinatedSpace: CoordinateSpaceProvider,
        onViewPortChange: @escaping (ViewLifeCycle) -> Void
    ) {
        self.axis = axis
        self.container = container
        self.coordinatedSpace = coordinatedSpace
        self.onViewPortChange = onViewPortChange
    }

    @available(iOS 17.0, *)
    init(
        axis: Axis,
        coordinatedSpace: CoordinateSpaceProvider,
        onViewPortChange: @escaping (ViewLifeCycle) -> Void
    ) {
        self.axis = axis
        self.coordinatedSpace = coordinatedSpace
        self.onViewPortChange = onViewPortChange
    }

    public func body(content: Content) -> some View {
        GeometryReader { reader in
            if #available(iOS 17.0, *) {
                content
                    .preference(
                        key: ViewOffsetKey.self,
                        value: transform(proxy: reader)
                    )
                    .onPreferenceChange(ViewOffsetKey.self) {
                        onViewPortChange($0)
                    }
            } else {
                content
                    .preference(
                        key: ViewOffsetKey.self,
                        value: transform(
                            proxy: reader,
                            container: container
                        )
                    )
                    .onPreferenceChange(ViewOffsetKey.self) {
                        onViewPortChange($0)
                    }
            }
        }
    }

    @available(iOS 17.0, *)
    private func transform(
        proxy: GeometryProxy
    ) -> ViewLifeCycle {
        let frame = proxy.frame(in: coordinatedSpace.coordinateSpace)
        let containerBounds: CGRect? = proxy.bounds(of: .named(coordinatedSpace.name))
        return computeResult(
            frame: frame,
            containerBounds: containerBounds
        )
    }

    private func transform(
        proxy: GeometryProxy,
        container: CGSize
    ) -> ViewLifeCycle {
        let frame = proxy.frame(in: coordinatedSpace.coordinateSpace)

        let containerBounds: CGRect? = if container == .zero {
            nil
        } else {
            CGRect(
                x: 0,
                y: 0,
                width: container.width,
                height: container.height
            )
        }

        return computeResult(
            frame: frame,
            containerBounds: containerBounds
        )
    }

    /// Compute result based on the view's frame
    /// - Parameters:
    ///   - frame: Target View's Frame
    ///   - containerBounds: Specific container for frame calculation
    /// - Returns: `ViewLifeCycle`
    /// Note : while `containerBounds` is Optional, Nil values will fails for detected bottom edge of screen
    private func computeResult(
        frame: CGRect,
        containerBounds: CGRect?
    ) -> ViewLifeCycle {
        switch axis {
        case .horizontal:
            if frame.maxX < 0 {
                return .disappear
            } else if let containerBounds, (containerBounds.width + frame.width) - frame.maxX < 0 {
                return .disappear
            }
        case .vertical:
            if frame.maxY < 0 {
                return .disappear
            } else if let containerBounds, (containerBounds.height + frame.height) - frame.maxY < 0 {
                return .disappear
            }
        }
        return .appear
    }
}

public extension View {
    /// Use this modifier to observe `View` visibility on screen.
    /// By default, it uses screen's global coordinate space to perform calculation
    /// - parameters:
    ///        - axis: On which axis to observe
    ///        - coordinatedSpace: Takes `CoordinateSpaceProvider` with Default Value set to `.global`
    ///        - onViewPortChange: completion with `ViewLifeCycle` to handle the preference changes
    @available(iOS 17.0, *)
    func observerViewPort(
        axis: Axis,
        coordinatedSpace: ViewPortObserver.CoordinateSpaceProvider = .global,
        onViewPortChange: @escaping (ViewPortObserver.ViewLifeCycle) -> Void
    ) -> some View {
        background(
            Color.clear
                .modifier(
                    ViewPortObserver(
                        axis: axis,
                        coordinatedSpace: coordinatedSpace,
                        onViewPortChange: onViewPortChange
                    )
                )
        )
    }

    @available(
        iOS,
        introduced: 13.0,
        deprecated: 17.0,
        message: "Starting from iOS17, use observerViewPort modifier without the container parameter"
    )
    func observerViewPort(
        axis: Axis,
        container: CGSize,
        coordinatedSpace: ViewPortObserver.CoordinateSpaceProvider = .global,
        onViewPortChange: @escaping (ViewPortObserver.ViewLifeCycle) -> Void
    ) -> some View {
        background(
            Color.clear
                .modifier(
                    ViewPortObserver(
                        axis: axis,
                        container: container,
                        coordinatedSpace: coordinatedSpace,
                        onViewPortChange: onViewPortChange
                    )
                )
        )
    }
}
