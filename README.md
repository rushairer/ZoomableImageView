# ZoomableImageView

![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/rushairer/ZoomableImageView) ![GitHub](https://img.shields.io/github/license/rushairer/ZoomableImageView) ![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/rushairer/ZoomableImageView?include_prereleases) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/rushairer/ZoomableImageView.svg)

Simple SwiftUI ImageView that enables dragging and zooming.

## Declaration

```swift
struct ZoomableImageView
```

### Overview

Double Tap the view will zoom-in.

```swift
ZoomableImageView(image: UIImage(systemName: "photo")!)
```

```swift
@State var image: UIImage = UIImage()

var body: some View {
    ZoomableImageView(image: image, maximumZoomScale: 10)
        .task {
            do {
                let url = URL(string: "https://apod.nasa.gov/apod/image/2108/PlutoEnhancedHiRes_NewHorizons_960.jpg")!
                let (imageLocalURL, _) = try await URLSession.shared.download(from: url)
                let imageData = try Data(contentsOf: imageLocalURL)
                image = UIImage(data: imageData)!
            } catch {
                print(error)
            }
        }
}
```

### History

[History](./HISTORY.md)


### LICENSE

[The MIT License (MIT)](./LICENSE)
