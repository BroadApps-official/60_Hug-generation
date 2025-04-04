import UIKit

func combineImagesHorizontally(image1: UIImage, image2: UIImage) -> UIImage? {
    let newWidth = image1.size.width + image2.size.width
    let newHeight = max(image1.size.height, image2.size.height)
    
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: newWidth, height: newHeight))
    
    let combinedImage = renderer.image { context in
        image1.draw(at: CGPoint(x: 0, y: 0))
        image2.draw(at: CGPoint(x: image1.size.width, y: 0))
    }
    
    return combinedImage
}
