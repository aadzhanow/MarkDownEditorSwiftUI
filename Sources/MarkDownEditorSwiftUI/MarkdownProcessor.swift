//
//  MarkdownProcessor.swift
//  MarkDownEditorSwiftUI
//
//  Created by Alisher on 01.12.2025.
//

import UIKit

/// Converts between markdown strings and attributed strings
public enum MarkdownProcessor {

    // MARK: - Markdown to Attributed String

    public static func attributedString(
        from markdown: String,
        configuration: EditorConfiguration = .default
    ) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let lines = markdown.components(separatedBy: "\n")

        for (index, line) in lines.enumerated() {
            let isLastLine = index == lines.count - 1
            let parsedLine = parseLine(line, configuration: configuration, appendNewline: !isLastLine)
            result.append(parsedLine)
        }

        return result
    }

    private static func parseLine(
        _ line: String,
        configuration: EditorConfiguration,
        appendNewline: Bool = false
    ) -> NSAttributedString {
        let (processedLine, style) = parseLinePrefix(line, configuration: configuration)

        let paragraphStyle = createParagraphStyle(for: style, configuration: configuration)

        var attributes: [NSAttributedString.Key: Any] = [
            .font: style.font,
            .foregroundColor: style.color,
            .paragraphStyle: paragraphStyle
        ]
        if let bgColor = style.backgroundColor {
            attributes[.backgroundColor] = bgColor
        }

        let lineText = appendNewline ? processedLine + "\n" : processedLine
        let attributedLine = NSMutableAttributedString(string: lineText, attributes: attributes)
        processInlineFormatting(in: attributedLine, configuration: configuration)

        return attributedLine
    }

    private static func parseLinePrefix(
        _ line: String,
        configuration: EditorConfiguration
    ) -> (text: String, style: TextStyle) {
        // Order matters: check longer prefixes first
        switch true {
        case line.hasPrefix("###### "):
            return (String(line.dropFirst(7)), configuration.h6)
        case line.hasPrefix("##### "):
            return (String(line.dropFirst(6)), configuration.h5)
        case line.hasPrefix("#### "):
            return (String(line.dropFirst(5)), configuration.h4)
        case line.hasPrefix("### "):
            return (String(line.dropFirst(4)), configuration.h3)
        case line.hasPrefix("## "):
            return (String(line.dropFirst(3)), configuration.h2)
        case line.hasPrefix("# "):
            return (String(line.dropFirst(2)), configuration.h1)
        case line.hasPrefix("> "):
            return (String(line.dropFirst(2)), configuration.quote)
        default:
            return (line, configuration.body)
        }
    }

    private static func createParagraphStyle(
        for style: TextStyle,
        configuration: EditorConfiguration
    ) -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = configuration.lineSpacing
        paragraphStyle.paragraphSpacingBefore = style.paddingTop
        paragraphStyle.paragraphSpacing = style.paddingBottom
        return paragraphStyle
    }

    // MARK: - Inline Formatting

    private static func processInlineFormatting(
        in attributedString: NSMutableAttributedString,
        configuration: EditorConfiguration
    ) {
        // Style-based patterns
        let stylePatterns: [(pattern: String, style: TextStyle)] = [
            ("\\*\\*(.+?)\\*\\*", configuration.bold),
            ("\\*(.+?)\\*", configuration.italic),
            ("_(.+?)_", configuration.italic),
            ("`(.+?)`", configuration.code)
        ]

        for (pattern, style) in stylePatterns {
            applyInlinePattern(pattern, style: style, to: attributedString)
        }

        // Strikethrough (attribute-based, not style-based)
        applyStrikethroughPattern(to: attributedString, configuration: configuration)
    }

    private static func applyStrikethroughPattern(
        to attributedString: NSMutableAttributedString,
        configuration: EditorConfiguration
    ) {
        let pattern = "~~(.+?)~~"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }

        let fullRange = NSRange(location: 0, length: attributedString.length)
        let matches = regex.matches(in: attributedString.string, options: [], range: fullRange)

        for match in matches.reversed() {
            guard match.numberOfRanges >= 2,
                  let contentRange = Range(match.range(at: 1), in: attributedString.string) else {
                continue
            }

            let content = String(attributedString.string[contentRange])

            let existingParagraphStyle = attributedString.attribute(
                .paragraphStyle,
                at: match.range(at: 0).location,
                effectiveRange: nil
            ) as? NSParagraphStyle ?? NSParagraphStyle()

            let attributes: [NSAttributedString.Key: Any] = [
                .font: configuration.body.font,
                .foregroundColor: configuration.body.color,
                .paragraphStyle: existingParagraphStyle,
                .strikethroughStyle: NSUnderlineStyle.single.rawValue
            ]

            let replacement = NSAttributedString(string: content, attributes: attributes)
            attributedString.replaceCharacters(in: match.range(at: 0), with: replacement)
        }
    }

    private static func applyInlinePattern(
        _ pattern: String,
        style: TextStyle,
        to attributedString: NSMutableAttributedString
    ) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }

        let fullRange = NSRange(location: 0, length: attributedString.length)
        let matches = regex.matches(in: attributedString.string, options: [], range: fullRange)

        // Process in reverse to maintain valid ranges
        for match in matches.reversed() {
            guard match.numberOfRanges >= 2,
                  let contentRange = Range(match.range(at: 1), in: attributedString.string) else {
                continue
            }

            let content = String(attributedString.string[contentRange])

            // Preserve existing paragraph style
            let existingParagraphStyle = attributedString.attribute(
                .paragraphStyle,
                at: match.range(at: 0).location,
                effectiveRange: nil
            ) as? NSParagraphStyle ?? NSParagraphStyle()

            var attributes: [NSAttributedString.Key: Any] = [
                .font: style.font,
                .foregroundColor: style.color,
                .paragraphStyle: existingParagraphStyle
            ]
            if let bgColor = style.backgroundColor {
                attributes[.backgroundColor] = bgColor
            }

            let replacement = NSAttributedString(string: content, attributes: attributes)
            attributedString.replaceCharacters(in: match.range(at: 0), with: replacement)
        }
    }

    // MARK: - Attributed String to Markdown

    public static func markdown(from attributedString: NSAttributedString) -> String {
        var result = ""
        let string = attributedString.string
        let lines = string.components(separatedBy: "\n")
        var currentIndex = 0

        for (lineIndex, line) in lines.enumerated() {
            let lineRange = NSRange(location: currentIndex, length: line.utf16.count)
            let lineMd = convertLineToMarkdown(attributedString: attributedString, lineRange: lineRange, lineText: line)
            result += lineMd

            if lineIndex < lines.count - 1 {
                result += "\n"
            }
            currentIndex += line.utf16.count + 1 // +1 for newline
        }

        return result
    }

    private static func convertLineToMarkdown(
        attributedString: NSAttributedString,
        lineRange: NSRange,
        lineText: String
    ) -> String {
        guard lineRange.length > 0, lineRange.location < attributedString.length else {
            return lineText
        }

        // Check for heading at line start
        if let headingPrefix = detectHeading(in: attributedString, at: lineRange.location) {
            return headingPrefix + lineText
        }

        // Process inline formatting
        var result = ""
        let effectiveRange = NSRange(
            location: lineRange.location,
            length: min(lineRange.length, attributedString.length - lineRange.location)
        )

        attributedString.enumerateAttributes(in: effectiveRange, options: []) { attributes, range, _ in
            guard let swiftRange = Range(range, in: attributedString.string) else { return }
            var text = String(attributedString.string[swiftRange])

            // Skip newlines in formatting
            if text == "\n" {
                result += text
                return
            }

            if let font = attributes[.font] as? UIFont {
                text = applyInlineMarkdown(font: font, text: text)
            }

            // Handle strikethrough
            if attributes[.strikethroughStyle] != nil {
                text = "~~\(text)~~"
            }

            result += text
        }

        return result
    }

    private static func detectHeading(in attributedString: NSAttributedString, at location: Int) -> String? {
        guard location < attributedString.length else { return nil }

        let attributes = attributedString.attributes(at: location, effectiveRange: nil)
        guard let font = attributes[.font] as? UIFont else { return nil }

        let traits = font.fontDescriptor.symbolicTraits
        let size = font.pointSize

        // Match heading styles by font size
        switch size {
        case 28...: return "# "
        case 24..<28: return "## "
        case 20..<24: return "### "
        case 18..<20 where traits.contains(.traitBold): return "#### "
        case 16..<18 where traits.contains(.traitBold): return "##### "
        case 14..<16 where traits.contains(.traitBold): return "###### "
        default: return nil
        }
    }

    private static func applyInlineMarkdown(font: UIFont, text: String) -> String {
        let traits = font.fontDescriptor.symbolicTraits
        var result = text

        // Skip heading-sized text (handled separately)
        if font.pointSize >= 18 && traits.contains(.traitBold) {
            return text
        }
        if font.pointSize >= 20 {
            return text
        }

        // Inline code (monospace)
        if traits.contains(.traitMonoSpace) {
            return "`\(text)`"
        }

        // Bold and italic
        if traits.contains(.traitBold) {
            result = "**\(result)**"
        }
        if traits.contains(.traitItalic) {
            result = "*\(result)*"
        }

        return result
    }
}

// MARK: - Legacy API Support

public extension MarkdownProcessor {
    /// Legacy method name for backward compatibility
    static func markdownToAttributedString(
        _ markdown: String,
        configuration: EditorConfiguration = .default
    ) -> NSAttributedString {
        attributedString(from: markdown, configuration: configuration)
    }

    /// Legacy method name for backward compatibility
    static func attributedStringToMarkdown(_ attributedString: NSAttributedString) -> String {
        markdown(from: attributedString)
    }
}
