//
//  UIKitRepresentables.swift
//  Preferences
//

import SwiftUI

/// A UIViewControllerRepresentable instance for a given path and class name.
///
/// - Parameters:
///    - path: The path of the framework.
///    - controller: The string name of the class.
struct CustomViewController: UIViewControllerRepresentable {
    let path: String
    let controller: String
    
    init(_ path: String, controller: String) {
        self.path = path
        self.controller = controller
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        SettingsLogger.info("Retrieving preferences plugin with name '\(controller)' at location 'PreferencesPluginLocation: { directoryURL: 'file://\(path)'}'.")
        
        guard dlopen(path, RTLD_NOW) != nil else {
            SettingsLogger.error("Could not load framework: \(path)")
            return UIViewController()
        }
        
        guard let controller = NSClassFromString(controller) as? UIViewControllerType.Type else {
            SettingsLogger.error("Could not load controller: \(controller)")
            return UIViewController()
        }
        
        let bundleSelector = Selector(("pe_emitNavigationEventForApplicationSettingsWithApplicationBundleIdentifier:title:localizedNavigationComponents:deepLink:"))
        if !(controller as AnyObject).responds(to: bundleSelector) {
            let methodImp: @convention(block) (AnyObject, Any?, Any?, Any?, Any?) -> Void = { _, _, _, _, _ in }
            let imp = imp_implementationWithBlock(methodImp)
            _ = class_addMethod(controller, bundleSelector, imp, "v@:@@@@")
        }
        
        let iconSelector = Selector(("pe_emitNavigationEventForSystemSettingsWithGraphicIconIdentifier:title:localizedNavigationComponents:deepLink:"))
        if !(controller as AnyObject).responds(to: iconSelector) {
            let methodImp: @convention(block) (AnyObject, Any?, Any?, Any?, Any?) -> Void = { _, _, _, _, _ in }
            let imp = imp_implementationWithBlock(methodImp)
            _ = class_addMethod(controller, iconSelector, imp, "v@:@@@@")
        }
        
        let actionSelector = Selector(("pe_registerUndoActionName:associatedDeepLink:undoAction:"))
        if !(controller as AnyObject).responds(to: actionSelector) {
            let methodImp: @convention(block) (AnyObject, Any?, Any?, @escaping () -> Void) -> Void = { _, _, _, _ in }
            let imp = imp_implementationWithBlock(methodImp)
            _ = class_addMethod(controller, actionSelector, imp, "v@:@@?")
        }
        
        SettingsLogger.info("Loading plugin with name '\(controller)' at location '{ directoryURL: 'file://\(path)'}'.")
        
        let vc = controller.init()
        
        // If accessing Face ID enrollment controller, disable `Get Started` button for now
        if self.controller == "BKUIPearlEnrollController" {
            if let enrollVC = (vc as NSObject).value(forKey: "enrollViewController") as? NSObject {
                enrollVC.perform(Selector(("cancelEnroll")))
            }
        }
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

/// A UIViewRepresentable instance for a given path and class name.
///
/// - Parameters:
///    - path: The path of the framework.
///    - controller: The string name of the class.
struct CustomView: UIViewRepresentable {
    let path: String
    let controller: String
    
    init(_ path: String, controller: String) {
        self.path = path
        self.controller = controller
    }
    
    func makeUIView(context: Context) -> UIView {
        if path.contains("/") {
            guard dlopen(path, RTLD_NOW) != nil else {
                SettingsLogger.error("Could not load framework: \(path)")
                return UIView()
            }
        } else {
            guard dlopen("/System/Library/PrivateFrameworks/\(path).framework/\(path)", RTLD_NOW) != nil else {
                SettingsLogger.error("Could not load framework: \(path)")
                return UIView()
            }
        }
        
        guard let view = NSClassFromString(controller) as? UIView.Type else {
            SettingsLogger.error("Could not load view: \(controller)")
            return UIView()
        }
        
        return view.init()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

/// A read-only, non-editable text view for diagnostic file contents.
///
/// Settings shows analytics files through a plain `UITextView`, not a label:
/// TextKit lays out only what is on screen, which is what keeps a 100 KB crash
/// report scrolling smoothly, and it gives the same wrapping, selection and
/// insets as the real pane. A SwiftUI `Text` would lay the whole file out at
/// once and stutter on the larger reports.
struct DiagnosticTextView: UIViewRepresentable {
    let text: String
    var fontSize: CGFloat = 11

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = false
        view.isSelectable = true
        view.alwaysBounceVertical = true
        view.backgroundColor = .systemBackground
        view.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 24, right: 4)
        view.textContainer.lineFragmentPadding = 4
        view.contentInsetAdjustmentBehavior = .always
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        let font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        guard view.text != text || view.font != font else { return }
        view.font = font
        view.textColor = .label
        view.text = text
    }
}
