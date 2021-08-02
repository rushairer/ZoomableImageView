import XCTest
@testable import ZoomableImageView

final class ZoomableImageViewTests: XCTestCase {
    @available(iOS 15.0, *)
    func testRequestImageFromURL() async throws {

        let url = URL(string: "https://apod.nasa.gov/apod/image/2108/PlutoEnhancedHiRes_NewHorizons_960.jpg")!
        let (imageLocalURL, response) = try await URLSession.shared.download(from: url)
        let imageData = try Data(contentsOf: imageLocalURL)
        XCTAssertEqual((response as! HTTPURLResponse).statusCode, 200)
        XCTAssertNotNil(imageData)
        
        let image = UIImage(data: imageData)
        XCTAssertNotNil(image)
    }
}
