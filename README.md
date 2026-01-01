# MarkDownEditorSwiftUI

A WYSIWYG markdown editor for SwiftUI with customizable styling.

## Installation

Add the package to your Xcode project via Swift Package Manager.

## Basic Usage

```swift
import SwiftUI
import MarkDownEditorSwiftUI

struct ContentView: View {
    @State private var markdown = "# Hello World\n\nThis is **bold** and *italic* text."

    var body: some View {
        MarkDownEditor(text: $markdown)
    }
}
```

## Supported Markdown

| Syntax | Description |
|--------|-------------|
| `# Text` | Heading 1 |
| `## Text` | Heading 2 |
| `### Text` | Heading 3 |
| `#### Text` | Heading 4 |
| `##### Text` | Heading 5 |
| `###### Text` | Heading 6 |
| `**text**` | Bold |
| `*text*` or `_text_` | Italic |
| `` `text` `` | Inline code |
| `~~text~~` | Strikethrough |
| `> text` | Quote |

## Modifiers

### Scroll & Layout

```swift
MarkDownEditor(text: $markdown)
    .scrollEnabled(true)
    .textInsets(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
```

### Appearance

```swift
MarkDownEditor(text: $markdown)
    .backgroundColor(.secondarySystemBackground)
    .tint(.systemBlue)
    .lineSpacing(5)
```

### Custom Configuration

```swift
let config = EditorConfiguration(
    body: TextStyle(font: .systemFont(ofSize: 16), color: .label),
    h1: TextStyle(font: .boldSystemFont(ofSize: 32), color: .systemBlue),
    h2: TextStyle(font: .boldSystemFont(ofSize: 26), color: .systemIndigo),
    bold: TextStyle(font: .boldSystemFont(ofSize: 16), color: .label),
    italic: TextStyle(font: .italicSystemFont(ofSize: 16), color: .label),
    code: TextStyle(
        font: .monospacedSystemFont(ofSize: 14, weight: .regular),
        color: .systemRed,
        backgroundColor: .systemGray6
    ),
    quote: TextStyle(
        font: .italicSystemFont(ofSize: 16),
        color: .secondaryLabel,
        backgroundColor: .systemGray6
    ),
    lineSpacing: 5
)

MarkDownEditor(text: $markdown)
    .configuration(config)
```

### Heading Padding

```swift
MarkDownEditor(text: $markdown)
    .padding(.vertical, 8, for: .h1)
    .padding(.top, 6, for: .h2)
    .padding(.bottom, 4, for: .h3)
```

### Text Change Callback

```swift
MarkDownEditor(text: $markdown) { newMarkdown in
    print("Markdown changed: \(newMarkdown)")
}
```

## Full Example

```swift
import SwiftUI
import MarkDownEditorSwiftUI

struct ContentView: View {
    @State private var markdown = """
    # Welcome

    This is a **bold** text and this is *italic*.

    ## Features

    Here's some `inline code` as well.

    > This is a quote

    ~~strikethrough text~~
    """

    var body: some View {
        NavigationStack {
            ScrollView {
                MarkDownEditor(text: $markdown)
                    .configuration(EditorConfiguration(
                        h1: TextStyle(font: .boldSystemFont(ofSize: 32), color: .systemBlue),
                        h2: TextStyle(font: .boldSystemFont(ofSize: 26), color: .systemIndigo),
                        code: TextStyle(
                            font: .monospacedSystemFont(ofSize: 14, weight: .regular),
                            color: .systemRed,
                            backgroundColor: .systemGray6
                        )
                    ))
                    .backgroundColor(.secondarySystemBackground)
                    .textInsets(UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16))
                    .scrollEnabled(false)
                    .padding(.vertical, 8, for: .h1)
                    .padding(.vertical, 6, for: .h2)
            }
            .navigationTitle("Editor")
        }
    }
}
```

## Formatting Menu

Select text and use the context menu to apply formatting:
- Bold
- Italic
- Strikethrough
- Code
- Headings (1-6)
- Clear Formatting

## Requirements

- iOS 15.0+
- Swift 5.9+
