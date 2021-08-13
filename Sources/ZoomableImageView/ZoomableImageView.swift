//
//  ZoomableImageView.swift
//  ZoomableImageView
//
//  Created by Abenx on 2021/8/2.
//

import SwiftUI

/// Simple SwiftUI ImageView that enables dragging and zooming.
///
/// Double Tap the view will zoom-in.
///
/// ```swift
/// ZoomableImageView(image: UIImage(systemName: "photo")!)
/// ```
///
/// ```swift
/// @State var image: UIImage = UIImage()
///
/// var body: some View {
///     ZoomableImageView(image: image, maximumZoomScale: 10)
///         .task {
///             do {
///                 let url = URL(string: "https://apod.nasa.gov/apod/image/2108/PlutoEnhancedHiRes_NewHorizons_960.jpg")!
///                 let (imageLocalURL, _) = try await URLSession.shared.download(from: url)
///                 let imageData = try Data(contentsOf: imageLocalURL)
///                 image = UIImage(data: imageData)!
///             } catch {
///                 print(error)
///             }
///         }
/// }
/// ```
public struct ZoomableImageView: View {
    var image: UIImage
    var onSingleTapGesture: ((UITapGestureRecognizer) -> Void)?
    var maximumZoomScale: CGFloat
    
    /// Create a ZoomableImageView.
    /// - Parameters:
    ///   - image: The image to show.
    ///   - maximumZoomScale: The maximum zoomScale you can zoom-in the image. Default: 3.
    ///   - onSingleTapGesture: The callback action when the imageView on single tap gesture.
    public init(image: UIImage, maximumZoomScale: CGFloat = 3.0, onSingleTapGesture: ((UITapGestureRecognizer) -> Void)? = nil) {
        self.image = image
        self.maximumZoomScale = maximumZoomScale
        self.onSingleTapGesture = onSingleTapGesture
    }
    
    public var body: some View {
        GeometryReader { proxy in
            Representable(image: image, maximumZoomScale: maximumZoomScale, frame: proxy.frame(in: .global), onSingleTapGesture: onSingleTapGesture)
        }
    }
}

extension ZoomableImageView {
    typealias ViewRepresentable = UIViewRepresentable
    
    struct Representable: ViewRepresentable {
        typealias UIViewType = ZoomableImageUIView
        
        let image: UIImage
        let maximumZoomScale: CGFloat
        let frame: CGRect
        var onSingleTapGesture: ((UITapGestureRecognizer) -> Void)?
        
        func makeUIView(context: Context) -> ZoomableImageUIView {
            return ZoomableImageUIView(frame: frame, maximumZoomScale: maximumZoomScale, onSingleTapGesture: onSingleTapGesture)
        }
        
        func updateUIView(_ uiView: ZoomableImageUIView, context: Context) {
            uiView.updateImage(image: image)
        }
    }
}


struct ZoomableImageView_Previews: PreviewProvider {
    
    static var previews: some View {
        TestForZoomableImageView()
    }
    
    struct TestForZoomableImageView: View {
        @State var image: UIImage = UIImage()
        
        var body: some View {
            if #available(iOS 15.0, *) {
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
            } else {
                ZoomableImageView(image: UIImage(systemName: "photo")!)
            }
        }
    }
}
