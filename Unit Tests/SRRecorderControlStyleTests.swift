//
//  SRRecorderControlStyleTests.swift
//  Unit Tests
//
//  Created by Ilya Kulakov on 5/21/19.
//

import XCTest

import ShortcutRecorder


extension RecorderControlStyle.Components.Appearance: CaseIterable {
    public typealias AllCases = [RecorderControlStyle.Components.Appearance]

    public static var allCases: [RecorderControlStyle.Components.Appearance] {
        return [
            .unspecified,
            .aqua,
            .darkAqua,
            .vibrantDark,
            .vibrantLight
        ]
    }

    func stringRepresentation() -> String {
        switch self {
        case .unspecified:
            return ""
        case .aqua:
            return "-aqua"
        case .darkAqua:
            return "-darkaqua"
        case .vibrantLight:
            return "-vibrantlight"
        case .vibrantDark:
            return "-vibrantdark"
        @unknown default:
            fatalError("Missing case for \(self.rawValue)")
        }
    }
}

extension RecorderControlStyle.Components.Accessibility: Hashable, CaseIterable {
    public typealias AllCases = [RecorderControlStyle.Components.Accessibility]

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    public static var allCases: RecorderControlStyle.Components.Accessibility.AllCases {
        return [
            [],
            [.none],
            [.highContrast]
        ]
    }

    func stringRepresentation() -> String {
        switch self {
        case []:
            fallthrough
        case [.none]:
            return ""
        case [.highContrast]:
            return "-acc"
        default:
            fatalError("Missing case for \(self.rawValue)")
        }
    }
}

extension RecorderControlStyle.Components.LayoutDirection: CaseIterable {
    public typealias AllCases = [RecorderControlStyle.Components.LayoutDirection]

    public static var allCases: [RecorderControlStyle.Components.LayoutDirection] {
        return [
            .unspecified,
            .leftToRight,
            .rightToLeft,
        ]
    }

    func stringRepresentation() -> String {
        switch self {
        case .unspecified:
            return ""
        case .leftToRight:
            return "-ltr"
        case .rightToLeft:
            return "-rtl"
        @unknown default:
            fatalError("Missing case for \(self.rawValue)")
        }
    }
}

extension RecorderControlStyle.Components.Tint: CaseIterable {
    public typealias AllCases = [RecorderControlStyle.Components.Tint]

    public static var allCases: [RecorderControlStyle.Components.Tint] {
        return [
            .unspecified,
            .blue,
            .graphite
        ]
    }

    func stringRepresentation() -> String {
        switch self {
        case .unspecified:
            return ""
        case .blue:
            return "-blue"
        case .graphite:
            return "-graphite"
        @unknown default:
            fatalError("Missing case for \(self.rawValue)")
        }
    }
}


class SRRecorderControlStyleTests: XCTestCase {
    func testEffectiveComponentsAlwaysSpecified() {
        let style = RecorderControlStyle(identifier: "sr-test-", components: nil)
        let currentComponents = RecorderControlStyle.Components.current

        XCTAssertEqual(style.effectiveComponents.appearance, currentComponents.appearance)
        XCTAssertEqual(style.effectiveComponents.tint, currentComponents.tint)
        XCTAssertEqual(style.effectiveComponents.accessibility, currentComponents.accessibility)
    }

    func testEffectiveComponentsAppearance() {
        let superview = NSView(frame: NSRect.zero)
        let control = RecorderControl(frame: NSRect.zero)
        superview.addSubview(control)

        superview.appearance = NSAppearance(named: .aqua)
        XCTAssertEqual(control.style.effectiveComponents.appearance, .aqua)

        superview.appearance = NSAppearance(named: .vibrantDark)
        XCTAssertEqual(control.style.effectiveComponents.appearance, .vibrantDark)
    }

    func testEffectiveComponentsLayoutDirection() {
        let view = NSView(frame: .zero)
        let control = RecorderControl(frame: .zero)
        XCTAssertEqual(control.userInterfaceLayoutDirection, view.userInterfaceLayoutDirection)

        control.style = RecorderControlStyle(identifier: nil,
                                             components: RecorderControlStyle.Components(appearance: .unspecified,
                                                                                         accessibility: [],
                                                                                         layoutDirection: .rightToLeft,
                                                                                         tint: .unspecified))
        XCTAssertEqual(control.userInterfaceLayoutDirection, NSUserInterfaceLayoutDirection.rightToLeft)

        control.style = RecorderControlStyle(identifier: nil,
                                             components: RecorderControlStyle.Components(appearance: .unspecified,
                                                                                         accessibility: [],
                                                                                         layoutDirection: .leftToRight,
                                                                                         tint: .unspecified))
        XCTAssertEqual(control.userInterfaceLayoutDirection, NSUserInterfaceLayoutDirection.leftToRight)

        control.style = RecorderControlStyle(identifier: nil, components: RecorderControlStyle.Components())
        XCTAssertEqual(control.userInterfaceLayoutDirection, view.userInterfaceLayoutDirection)
    }
}


class SRRecorderControlStyleComponentsTests: XCTestCase {
    func testEquality() {
        let o1 = RecorderControlStyle.Components()
        let o2 = o1.copy() as! RecorderControlStyle.Components
        XCTAssertEqual(o1, o2)
    }

    func testAppearanceFromSystem() {
        XCTAssertEqual(RecorderControlStyle.Components.Appearance(fromSystem: .aqua),
                       RecorderControlStyle.Components.Appearance.aqua)
        XCTAssertEqual(RecorderControlStyle.Components.Appearance(fromSystem: .vibrantLight),
                       RecorderControlStyle.Components.Appearance.vibrantLight)
        XCTAssertEqual(RecorderControlStyle.Components.Appearance(fromSystem: .vibrantDark),
                       RecorderControlStyle.Components.Appearance.vibrantDark)

        if #available(OSX 10.14, *) {
            XCTAssertEqual(RecorderControlStyle.Components.Appearance(fromSystem: .darkAqua),
                           RecorderControlStyle.Components.Appearance.darkAqua)
        }
    }

    func testTintFromSystem() {
        XCTAssertEqual(RecorderControlStyle.Components.Tint(fromSystem: .blueControlTint),
                       RecorderControlStyle.Components.Tint.blue)
        XCTAssertEqual(RecorderControlStyle.Components.Tint(fromSystem: .graphiteControlTint),
                       RecorderControlStyle.Components.Tint.graphite)
    }

    func testLayoutDirectionFromSystem() {
        XCTAssertEqual(RecorderControlStyle.Components.LayoutDirection(fromSystem: .leftToRight),
                       RecorderControlStyle.Components.LayoutDirection.leftToRight)
        XCTAssertEqual(RecorderControlStyle.Components.LayoutDirection(fromSystem: .rightToLeft),
                       RecorderControlStyle.Components.LayoutDirection.rightToLeft)
    }

    func testStringRepresentation() {
        typealias Components = RecorderControlStyle.Components

        func ComponentsString(_ appearance: Components.Appearance, _ accessibility: Components.Accessibility,
                              _ layoutDirection: Components.LayoutDirection, _ tint: Components.Tint) -> String {
            return Components(appearance: appearance, accessibility: accessibility,
                              layoutDirection: layoutDirection, tint: tint).stringRepresentation
        }

        for appearance in Components.Appearance.allCases {
            for accessibility in Components.Accessibility.allCases {
                for layoutDirection in Components.LayoutDirection.allCases {
                    for tint in Components.Tint.allCases {
                        let expected = """
                        \(appearance.stringRepresentation())\
                        \(accessibility.stringRepresentation())\
                        \(layoutDirection.stringRepresentation())\
                        \(tint.stringRepresentation())
                        """
                        let actual = ComponentsString(appearance, accessibility, layoutDirection, tint)
                        XCTAssertEqual(actual, expected)
                    }
                }
            }
        }
    }
}
