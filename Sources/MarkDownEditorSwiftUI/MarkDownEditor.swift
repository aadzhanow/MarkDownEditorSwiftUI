//
//  MarkDownEditor.swift
//  MarkDownEditorSwiftUI
//
//  Created by Alisher on 01.12.2025.
//

import SwiftUI
import UIKit

/// A SwiftUI markdown editor with rich text formatting support
public struct MarkDownEditor: UIViewRepresentable {

    // MARK: - Properties

    @Binding public var text: String
    public var onTextChange: ((String) -> Void)?
    public var onFocusChange: ((Bool) -> Void)?

    private var isScrollEnabled = false
    private var textContainerInset = UIEdgeInsets.zero
    private var configuration: EditorConfiguration = .default
    private var editorBackgroundColor: UIColor = .systemBackground
    private var editorTintColor: UIColor?

    // MARK: - Initialization

    public init(text: Binding<String>, onTextChange: ((String) -> Void)? = nil) {
        self._text = text
        self.onTextChange = onTextChange
    }

    // MARK: - Modifiers

    public func scrollEnabled(_ enabled: Bool) -> MarkDownEditor {
        var editor = self
        editor.isScrollEnabled = enabled
        return editor
    }

    public func textInsets(_ insets: UIEdgeInsets) -> MarkDownEditor {
        var editor = self
        editor.textContainerInset = insets
        return editor
    }

    public func configuration(_ config: EditorConfiguration) -> MarkDownEditor {
        var editor = self
        editor.configuration = config
        return editor
    }

    public func backgroundColor(_ color: UIColor) -> MarkDownEditor {
        var editor = self
        editor.editorBackgroundColor = color
        return editor
    }

    public func tint(_ color: UIColor) -> MarkDownEditor {
        var editor = self
        editor.editorTintColor = color
        return editor
    }

    public func lineSpacing(_ spacing: CGFloat) -> MarkDownEditor {
        var editor = self
        editor.configuration.lineSpacing = spacing
        return editor
    }

    public func onFocusChange(_ action: @escaping (Bool) -> Void) -> MarkDownEditor {
        var editor = self
        editor.onFocusChange = action
        return editor
    }

    public func padding(_ edge: VerticalEdge, _ value: CGFloat, for styleType: StyleType) -> MarkDownEditor {
        var editor = self
        var style = editor.configuration.style(for: styleType)

        switch edge {
        case .top:
            style.paddingTop = value
        case .bottom:
            style.paddingBottom = value
        case .vertical:
            style.paddingTop = value
            style.paddingBottom = value
        }

        editor.configuration.setStyle(style, for: styleType)
        return editor
    }

    // MARK: - UIViewRepresentable

    public func makeUIView(context: Context) -> RichTextView {
        let textView = RichTextView()
        configureTextView(textView, context: context)
        return textView
    }

    public func updateUIView(_ textView: RichTextView, context: Context) {
        textView.isScrollEnabled = isScrollEnabled
        textView.textContainerInset = textContainerInset
        textView.backgroundColor = editorBackgroundColor
        textView.configuration = configuration

        if let tintColor = editorTintColor {
            textView.tintColor = tintColor
        }

        // Update typing attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = configuration.lineSpacing
        textView.typingAttributes = [
            .font: configuration.body.font,
            .foregroundColor: configuration.body.color,
            .paragraphStyle: paragraphStyle
        ]

        // Only update if markdown changed externally
        let currentMarkdown = MarkdownProcessor.markdown(from: textView.attributedText)
        guard currentMarkdown != text else { return }

        let selectedRange = textView.selectedRange
        textView.attributedText = MarkdownProcessor.attributedString(from: text, configuration: configuration)

        if selectedRange.location <= textView.text.count {
            textView.selectedRange = selectedRange
        }
    }

    @available(iOS 16.0, *)
    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: RichTextView, context: Context) -> CGSize? {
        let width = proposal.width ?? UIScreen.main.bounds.width
        let size = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: max(size.height, 44))
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Private Helpers

    private func configureTextView(_ textView: RichTextView, context: Context) {
        textView.delegate = context.coordinator
        textView.configuration = configuration

        textView.onTextChange = { _ in
            let markdown = MarkdownProcessor.markdown(from: textView.attributedText)
            context.coordinator.parent.text = markdown
            context.coordinator.parent.onTextChange?(markdown)
        }

        // Basic setup
        textView.isEditable = true
        textView.isSelectable = true
        textView.font = configuration.body.font
        textView.textColor = configuration.body.color
        textView.textContainerInset = textContainerInset
        textView.backgroundColor = editorBackgroundColor
        textView.allowsEditingTextAttributes = true
        textView.isScrollEnabled = isScrollEnabled

        // Set default typing attributes with proper paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = configuration.lineSpacing
        textView.typingAttributes = [
            .font: configuration.body.font,
            .foregroundColor: configuration.body.color,
            .paragraphStyle: paragraphStyle
        ]

        if let tintColor = editorTintColor {
            textView.tintColor = tintColor
        }

        // Layout configuration
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.widthTracksTextView = true
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)

        // Initial content
        textView.attributedText = MarkdownProcessor.attributedString(from: text, configuration: configuration)
    }

    // MARK: - Coordinator

    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: MarkDownEditor

        init(_ parent: MarkDownEditor) {
            self.parent = parent
        }

        public func textViewDidChange(_ textView: UITextView) {
            let markdown = MarkdownProcessor.markdown(from: textView.attributedText)
            parent.text = markdown
            parent.onTextChange?(markdown)
        }

        public func textViewDidBeginEditing(_ textView: UITextView) {
            parent.onFocusChange?(true)
        }

        public func textViewDidEndEditing(_ textView: UITextView) {
            parent.onFocusChange?(false)
        }
    }
}
