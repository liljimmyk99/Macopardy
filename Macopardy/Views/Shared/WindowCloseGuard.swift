//
//  WindowCloseGuard.swift
//  Macopardy
//

import AppKit
import SwiftUI

/// Lets a SwiftUI window refuse to close (red button, ⌘W, File ▸ Close).
///
/// SwiftUI has no hook for this outside document apps, so this sits in the
/// window's delegate slot, answers `windowShouldClose`, and forwards every
/// other delegate call to the delegate SwiftUI installed.
struct WindowCloseGuard: NSViewRepresentable {

    /// Called when the user tries to close. Return `false` to keep it open.
    let shouldClose: () -> Bool

    /// Called with the window once the view is in one.
    var onWindow: (NSWindow) -> Void = { _ in }

    func makeCoordinator() -> Coordinator {
        Coordinator(shouldClose: shouldClose)
    }

    func makeNSView(context: Context) -> NSView {
        let view = WindowReportingView()
        view.onWindow = { [coordinator = context.coordinator, onWindow] window in
            coordinator.attach(to: window)
            onWindow(window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.shouldClose = shouldClose
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.detach()
    }

    final class Coordinator: NSObject, NSWindowDelegate {

        var shouldClose: () -> Bool
        private weak var window: NSWindow?
        private weak var originalDelegate: NSWindowDelegate?

        init(shouldClose: @escaping () -> Bool) {
            self.shouldClose = shouldClose
        }

        func attach(to window: NSWindow) {
            guard self.window !== window else { return }
            detach()
            self.window = window
            originalDelegate = window.delegate
            window.delegate = self
        }

        func detach() {
            if let window, window.delegate === self {
                window.delegate = originalDelegate
            }
            window = nil
            originalDelegate = nil
        }

        func windowShouldClose(_ sender: NSWindow) -> Bool {
            guard shouldClose() else { return false }
            return originalDelegate?.windowShouldClose?(sender) ?? true
        }

        // Forward everything else to SwiftUI's delegate.

        override func responds(to aSelector: Selector!) -> Bool {
            super.responds(to: aSelector) || (originalDelegate?.responds(to: aSelector) ?? false)
        }

        override func forwardingTarget(for aSelector: Selector!) -> Any? {
            if let originalDelegate, originalDelegate.responds(to: aSelector) {
                return originalDelegate
            }
            return super.forwardingTarget(for: aSelector)
        }
    }
}

/// Reports the window it's added to.
private final class WindowReportingView: NSView {

    var onWindow: ((NSWindow) -> Void)?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let window {
            onWindow?(window)
        }
    }
}
