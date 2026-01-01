//
//  EditorConfiguration.swift
//  MarkDownEditorSwiftUI
//
//  Created by Alisher on 01.12.2025.
//

import UIKit

/// Configuration for all markdown editor styles
public struct EditorConfiguration {

    // MARK: - Style Properties

    public var body: TextStyle
    public var h1: TextStyle
    public var h2: TextStyle
    public var h3: TextStyle
    public var h4: TextStyle
    public var h5: TextStyle
    public var h6: TextStyle
    public var bold: TextStyle
    public var italic: TextStyle
    public var strikethrough: TextStyle
    public var code: TextStyle
    public var quote: TextStyle

    // MARK: - Layout Properties

    public var lineSpacing: CGFloat

    // MARK: - Initialization

    public init(
        body: TextStyle? = nil,
        h1: TextStyle? = nil,
        h2: TextStyle? = nil,
        h3: TextStyle? = nil,
        h4: TextStyle? = nil,
        h5: TextStyle? = nil,
        h6: TextStyle? = nil,
        bold: TextStyle? = nil,
        italic: TextStyle? = nil,
        strikethrough: TextStyle? = nil,
        code: TextStyle? = nil,
        quote: TextStyle? = nil,
        lineSpacing: CGFloat = 0
    ) {
        let defaultBody = body ?? TextStyle(font: .systemFont(ofSize: 17), color: .label)
        let baseSize = defaultBody.font.pointSize
        let baseColor = defaultBody.color

        self.body = defaultBody
        self.h1 = h1 ?? TextStyle(font: .boldSystemFont(ofSize: baseSize + 11), color: baseColor)
        self.h2 = h2 ?? TextStyle(font: .boldSystemFont(ofSize: baseSize + 7), color: baseColor)
        self.h3 = h3 ?? TextStyle(font: .boldSystemFont(ofSize: baseSize + 3), color: baseColor)
        self.h4 = h4 ?? TextStyle(font: .boldSystemFont(ofSize: baseSize + 1), color: baseColor)
        self.h5 = h5 ?? TextStyle(font: .boldSystemFont(ofSize: baseSize - 1), color: baseColor)
        self.h6 = h6 ?? TextStyle(font: .boldSystemFont(ofSize: baseSize - 3), color: baseColor)
        self.bold = bold ?? TextStyle(font: .boldSystemFont(ofSize: baseSize), color: baseColor)
        self.italic = italic ?? TextStyle(font: .italicSystemFont(ofSize: baseSize), color: baseColor)
        self.strikethrough = strikethrough ?? TextStyle(font: .systemFont(ofSize: baseSize), color: baseColor)
        self.code = code ?? TextStyle(
            font: .monospacedSystemFont(ofSize: baseSize - 2, weight: .regular),
            color: baseColor,
            backgroundColor: .systemGray5
        )
        self.quote = quote ?? TextStyle(
            font: .systemFont(ofSize: baseSize),
            color: .secondaryLabel,
            backgroundColor: .systemGray6
        )
        self.lineSpacing = lineSpacing
    }

    public static var `default`: EditorConfiguration { EditorConfiguration() }

    // MARK: - Style Accessors

    public func style(for type: StyleType) -> TextStyle {
        switch type {
        case .body: body
        case .h1: h1
        case .h2: h2
        case .h3: h3
        case .h4: h4
        case .h5: h5
        case .h6: h6
        case .bold: bold
        case .italic: italic
        case .strikethrough: strikethrough
        case .code: code
        case .quote: quote
        }
    }

    public mutating func setStyle(_ style: TextStyle, for type: StyleType) {
        switch type {
        case .body: body = style
        case .h1: h1 = style
        case .h2: h2 = style
        case .h3: h3 = style
        case .h4: h4 = style
        case .h5: h5 = style
        case .h6: h6 = style
        case .bold: bold = style
        case .italic: italic = style
        case .strikethrough: strikethrough = style
        case .code: code = style
        case .quote: quote = style
        }
    }
}
