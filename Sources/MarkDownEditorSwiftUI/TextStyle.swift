//
//  TextStyle.swift
//  MarkDownEditorSwiftUI
//
//  Created by Alisher on 01.12.2025.
//

import UIKit

// MARK: - TextStyle

/// Defines the visual appearance for a text element
public struct TextStyle {
    public var font: UIFont
    public var color: UIColor
    public var backgroundColor: UIColor?
    public var paddingTop: CGFloat
    public var paddingBottom: CGFloat

    public init(
        font: UIFont,
        color: UIColor,
        backgroundColor: UIColor? = nil,
        paddingTop: CGFloat = 0,
        paddingBottom: CGFloat = 0
    ) {
        self.font = font
        self.color = color
        self.backgroundColor = backgroundColor
        self.paddingTop = paddingTop
        self.paddingBottom = paddingBottom
    }

    public static func `default`(size: CGFloat = 17) -> TextStyle {
        TextStyle(font: .systemFont(ofSize: size), color: .label)
    }
}

// MARK: - StyleType

/// Available style types for markdown elements
public enum StyleType: CaseIterable {
    case body
    case h1, h2, h3, h4, h5, h6
    case bold, italic, strikethrough
    case code, quote
}

// MARK: - VerticalEdge

/// Vertical edge options for padding
public enum VerticalEdge {
    case top, bottom, vertical
}
