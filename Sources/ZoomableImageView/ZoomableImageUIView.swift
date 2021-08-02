import UIKit

class ZoomableImageUIView: UIView, UIScrollViewDelegate {
    
    static let kMaximumZoomScale: CGFloat = 3.0
    static let kMinimumZoomScale: CGFloat = 1.0
    
    private var onSingleTapGesture: ((UITapGestureRecognizer) -> Void)?

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.bouncesZoom = true
        scrollView.maximumZoomScale = self.maximumZoomScale
        scrollView.minimumZoomScale = ZoomableImageUIView.kMinimumZoomScale
        scrollView.isMultipleTouchEnabled = true
        scrollView.delegate = self
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        scrollView.alwaysBounceVertical = false
        scrollView.contentInsetAdjustmentBehavior = .never
        self.addSubview(scrollView)
        return scrollView
    }()
    
    private lazy var imageContainerView: UIView = {
        let imageContainerView = UIView()
        imageContainerView.clipsToBounds = true
        imageContainerView.contentMode = .scaleAspectFill
        scrollView.addSubview(imageContainerView)
        return imageContainerView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageContainerView.addSubview(imageView)
        return imageView
    }()
    
    private lazy var maximumZoomScale: CGFloat = {
        return ZoomableImageUIView.kMaximumZoomScale
    }()
    
    init(frame: CGRect, maximumZoomScale: CGFloat = 3.0, onSingleTapGesture: ((UITapGestureRecognizer) -> Void)? = nil) {
        super.init(frame: frame)
        
        self.maximumZoomScale = maximumZoomScale
        self.onSingleTapGesture = onSingleTapGesture
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onSingleTap(tap:)))
        self.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(tap:)))
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        imageContainerView.addGestureRecognizer(doubleTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImage(image: UIImage) {
        imageView.image = image
        recoverSubviews()
    }
    
    override func updateConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recoverSubviews()
    }
    
    @objc
    func onSingleTap(tap: UITapGestureRecognizer) {
        guard let onSingleTapGesture = onSingleTapGesture else { return }
        onSingleTapGesture(tap)
    }
    
    @objc
    func onDoubleTap(tap: UITapGestureRecognizer) {
        if (scrollView.zoomScale > 1.0) {
            scrollView.contentInset = .zero
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let touchPoint: CGPoint = tap.location(in: self.imageView)
            let newZoomScale: CGFloat = scrollView.maximumZoomScale
            let sizeWidth: CGFloat = UIScreen.main.bounds.size.width / newZoomScale
            let sizeHeight: CGFloat = UIScreen.main.bounds.size.height / newZoomScale
            scrollView.zoom(to: CGRect(x: touchPoint.x - sizeWidth / 2.0,
                                       y: touchPoint.y - sizeHeight / 2.0,
                                       width: sizeWidth,
                                       height: sizeHeight),
                            animated: true)
        }
    }
    
    func recoverSubviews() {
        scrollView.setZoomScale(1.0, animated: false)
        resizeSubviews()
    }
    
    func resizeSubviews() {
        imageContainerView.frame.size = self.bounds.size
        imageContainerView.center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
        
        let imageWidth: CGFloat = imageView.image!.size.width
        let imageHeight: CGFloat = imageView.image!.size.height
        
        if (imageWidth / imageHeight > self.bounds.size.width / self.bounds.size.height * 3) {
            // 超宽图
            imageContainerView.frame.size.width = self.bounds.size.width
            imageContainerView.frame.size.height = imageContainerView.bounds.size.width / imageWidth * imageHeight
            
            scrollView.maximumZoomScale = self.bounds.size.height / imageContainerView.bounds.size.height
            
            let contentSizeWidth: CGFloat = max(imageContainerView.bounds.size.width, self.bounds.size.width)
            scrollView.contentSize = CGSize(width: contentSizeWidth, height: self.bounds.size.height)
            
            imageContainerView.center.y = self.bounds.size.height / 2.0
            imageContainerView.center.x = self.bounds.size.width / 2.0
        } else if (imageHeight / imageWidth > self.bounds.size.height / self.bounds.size.width * 3) {
            // 超高图
            imageContainerView.frame.size.height = self.bounds.size.height
            imageContainerView.frame.size.width = imageContainerView.bounds.size.height / imageHeight * imageWidth
            
            scrollView.maximumZoomScale = self.bounds.size.width / imageContainerView.bounds.size.width
            
            let contentSizeHeight: CGFloat = max(imageContainerView.bounds.size.height, self.bounds.size.height)
            scrollView.contentSize = CGSize(width: self.bounds.size.width, height: contentSizeHeight)
            
            imageContainerView.center.y = self.bounds.size.height / 2.0
            imageContainerView.center.x = self.bounds.size.width / 2.0
        } else {
            if ((imageWidth / imageHeight) > (self.bounds.size.width / self.bounds.size.height)) {
                // 左右对齐
                imageContainerView.frame.size.width = self.bounds.size.width
                
                var height: CGFloat = imageHeight / imageWidth * self.bounds.size.width
                if (height < 1 || height.isNaN) { height = self.bounds.size.height }
                height = floor(height)
                imageContainerView.frame.size.height = height
                
                let contentSizeHeight: CGFloat = max(imageContainerView.bounds.size.height, self.bounds.size.height)
                scrollView.contentSize = CGSize(width: self.bounds.size.width, height: contentSizeHeight)
                
                imageContainerView.center.y = self.bounds.size.height / 2.0
                imageContainerView.center.x = self.bounds.size.width / 2.0
            } else {
                // 上下对齐
                imageContainerView.frame.size.height = self.bounds.size.height
                
                var width = imageWidth / imageHeight * self.bounds.size.height
                if (width < 1 || width.isNaN) { width = self.bounds.size.width }
                width = floor(width)
                imageContainerView.frame.size.width = width
                
                let contentSizeWidth: CGFloat =  max(imageContainerView.bounds.size.width, self.bounds.size.width)
                scrollView.contentSize = CGSize(width: contentSizeWidth, height: self.bounds.size.height)
                
                imageContainerView.center.y = self.bounds.size.height / 2.0
                imageContainerView.center.x = self.bounds.size.width / 2.0
            }
            scrollView.maximumZoomScale = self.maximumZoomScale
        }
        scrollView.scrollRectToVisible(self.bounds, animated: false)
        scrollView.alwaysBounceVertical = imageContainerView.bounds.size.height > self.bounds.size.height
        
        imageView.frame = imageContainerView.bounds
    }
    
    func refreshImageContainerViewCenter() {
        let offsetX: CGFloat = (scrollView.bounds.size.width > scrollView.contentSize.width) ? ((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5) : 0.0
        let offsetY: CGFloat = (scrollView.bounds.size.height > scrollView.contentSize.height) ? ((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5) : 0.0
        imageContainerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageContainerView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = .zero
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        refreshImageContainerViewCenter()
    }
}
