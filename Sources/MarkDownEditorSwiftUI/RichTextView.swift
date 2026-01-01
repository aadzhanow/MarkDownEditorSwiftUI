//
//  RichTextView.swift
//  MarkDownEditorSwiftUI
//
//  Created by Alisher on 01.12.2025.
//

import UIKit

/// Custom UITextView with rich text formatting capabilities
public class RichTextView: UITextView {

    // MARK: - Properties

    var onTextChange: ((NSAttributedString) -> Void)?
    var onSizeChange: ((CGSize) -> Void)?
    var configuration: EditorConfiguration = .default

    private var lastCalculatedHeight: CGFloat = 0

    // MARK: - Intrinsic Size

    override public var intrinsicContentSize: CGSize {
        let width = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width
        let size = sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: UIView.noIntrinsicMetric, height: max(size.height, 44))
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        let newHeight = intrinsicContentSize.height
        guard abs(newHeight - lastCalculatedHeight) > 1 else { return }
        lastCalculatedHeight = newHeight
        invalidateIntrinsicContentSize()
        onSizeChange?(CGSize(width: bounds.width, height: newHeight))
    }

    // MARK: - Menu Configuration

    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let formatActions: [Selector] = [
            #selector(formatHeading1), #selector(formatHeading2), #selector(formatHeading3),
            #selector(formatHeading4), #selector(formatHeading5), #selector(formatHeading6),
            #selector(formatCode), #selector(formatStrikethrough)
        ]
        if formatActions.contains(action) {
            return selectedRange.length > 0
        }
        return super.canPerformAction(action, withSender: sender)
    }

    override public func buildMenu(with builder: any UIMenuBuilder) {
        super.buildMenu(with: builder)
        builder.remove(menu: .format)
        builder.insertSibling(createFormattingMenu(), afterMenu: .standardEdit)
    }

    private func createFormattingMenu() -> UIMenu {
        UIMenu(title: "Format", image: UIImage(systemName: "textformat"), children: [
            UIAction(title: "Bold", image: UIImage(systemName: "bold")) { [weak self] _ in
                self?.toggleBold()
            },
            UIAction(title: "Italic", image: UIImage(systemName: "italic")) { [weak self] _ in
                self?.toggleItalic()
            },
            UIAction(title: "Strikethrough", image: UIImage(systemName: "strikethrough")) { [weak self] _ in
                self?.formatStrikethrough()
            },
            UIAction(title: "Code", image: UIImage(systemName: "chevron.left.forwardslash.chevron.right")) { [weak self] _ in
                self?.formatCode()
            },
            createHeadingsMenu(),
            createClearFormattingMenu()
        ])
    }

    private func createHeadingsMenu() -> UIMenu {
        UIMenu(title: "Headings", image: UIImage(systemName: "textformat.size"), children: (1...6).map { level in
            UIAction(title: "Heading \(level)") { [weak self] _ in
                self?.applyHeading(level: level)
            }
        })
    }

    private func createClearFormattingMenu() -> UIMenu {
        UIMenu(options: .displayInline, children: [
            UIAction(title: "Clear Formatting", image: UIImage(systemName: "clear"), attributes: .destructive) { [weak self] _ in
                self?.clearFormatting()
            }
        ])
    }

    // MARK: - Formatting Actions

    @objc func toggleBold() { toggleFontTrait(.traitBold) }
    @objc func toggleItalic() { toggleFontTrait(.traitItalic) }
    @objc func formatStrikethrough() { toggleAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue) }
    @objc func formatCode() { applyStyle(configuration.code) }
    @objc func clearFormatting() { applyStyle(configuration.body) }

    @objc func formatHeading1() { applyStyle(configuration.h1) }
    @objc func formatHeading2() { applyStyle(configuration.h2) }
    @objc func formatHeading3() { applyStyle(configuration.h3) }
    @objc func formatHeading4() { applyStyle(configuration.h4) }
    @objc func formatHeading5() { applyStyle(configuration.h5) }
    @objc func formatHeading6() { applyStyle(configuration.h6) }

    private func applyHeading(level: Int) {
        let style: TextStyle
        switch level {
        case 1: style = configuration.h1
        case 2: style = configuration.h2
        case 3: style = configuration.h3
        case 4: style = configuration.h4
        case 5: style = configuration.h5
        default: style = configuration.h6
        }
        applyStyle(style)
    }

    // MARK: - Style Application

    private func applyStyle(_ style: TextStyle) {
        guard selectedRange.length > 0 else { return }

        let rangeToRestore = selectedRange
        let mutableText = NSMutableAttributedString(attributedString: attributedText)

        // Toggle behavior: if already this style, revert to body
        let isCurrentStyle = checkIfCurrentStyle(style)
        let targetStyle = isCurrentStyle ? configuration.body : style

        var attributes: [NSAttributedString.Key: Any] = [
            .font: targetStyle.font,
            .foregroundColor: targetStyle.color
        ]
        if let bgColor = targetStyle.backgroundColor {
            attributes[.backgroundColor] = bgColor
        }

        mutableText.removeAttribute(.backgroundColor, range: selectedRange)
        mutableText.addAttributes(attributes, range: selectedRange)

        attributedText = mutableText
        selectedRange = rangeToRestore
        onTextChange?(attributedText)
    }

    private func checkIfCurrentStyle(_ style: TextStyle) -> Bool {
        var isCurrentStyle = true
        attributedText.enumerateAttribute(.font, in: selectedRange, options: []) { value, _, _ in
            guard let font = value as? UIFont else {
                isCurrentStyle = false
                return
            }
            if font.pointSize != style.font.pointSize {
                isCurrentStyle = false
            }
        }
        return isCurrentStyle
    }

    private func toggleFontTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
        guard selectedRange.length > 0 else { return }

        let rangeToRestore = selectedRange
        let mutableText = NSMutableAttributedString(attributedString: attributedText)
        let hasTrait = checkIfHasTrait(trait)

        mutableText.enumerateAttribute(.font, in: selectedRange, options: []) { value, range, _ in
            let currentFont = (value as? UIFont) ?? .systemFont(ofSize: 17)
            var newTraits = currentFont.fontDescriptor.symbolicTraits

            if hasTrait {
                newTraits.remove(trait)
            } else {
                newTraits.insert(trait)
            }

            let newFont: UIFont
            if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(newTraits) {
                newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
            } else {
                newFont = hasTrait ? .systemFont(ofSize: currentFont.pointSize) : currentFont
            }

            mutableText.addAttribute(.font, value: newFont, range: range)
        }

        attributedText = mutableText
        selectedRange = rangeToRestore
        onTextChange?(attributedText)
    }

    private func checkIfHasTrait(_ trait: UIFontDescriptor.SymbolicTraits) -> Bool {
        var hasTrait = true
        attributedText.enumerateAttribute(.font, in: selectedRange, options: []) { value, _, _ in
            guard let font = value as? UIFont else {
                hasTrait = false
                return
            }
            if !font.fontDescriptor.symbolicTraits.contains(trait) {
                hasTrait = false
            }
        }
        return hasTrait
    }

    private func toggleAttribute(_ key: NSAttributedString.Key, value: Any) {
        guard selectedRange.length > 0 else { return }

        let rangeToRestore = selectedRange
        let mutableText = NSMutableAttributedString(attributedString: attributedText)

        var hasAttribute = true
        attributedText.enumerateAttribute(key, in: selectedRange, options: []) { existingValue, _, _ in
            if existingValue == nil { hasAttribute = false }
        }

        if hasAttribute {
            mutableText.removeAttribute(key, range: selectedRange)
        } else {
            mutableText.addAttribute(key, value: value, range: selectedRange)
        }

        attributedText = mutableText
        selectedRange = rangeToRestore
        onTextChange?(attributedText)
    }
}
