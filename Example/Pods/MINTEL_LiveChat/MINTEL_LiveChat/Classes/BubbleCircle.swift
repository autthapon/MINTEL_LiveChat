
import UIKit

/// A `UIView` subclass that maintains a mask to keep it fully circular
open class BubbleCircle: UIView {
    
    /// Lays out subviews and applys a circular mask to the layer
    open override func layoutSubviews() {
        super.layoutSubviews()
        layer.mask = roundedMask(corners: .allCorners, radius: bounds.height / 2)
    }
    
    /// Returns a rounded mask of the view
    ///
    /// - Parameters:
    ///   - corners: The corners to round
    ///   - radius: The radius of curve
    /// - Returns: A mask
    open func roundedMask(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        return mask
    }
    
}
