/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import UIKit

extension Gamut {
  var imageName: String {
    switch self {
    case .displayP3: return "Color_Wheel"
    case .sRGB: return "Color_Wheel_SRGB"
    }
  }
}

protocol ColorWheelControllerDelegate: class {
  func didPick(color: UIColor)
}

class ColorWheelController: UIViewController {
  
  @IBOutlet weak var wheelImageView: UIImageView!
  weak var delegate: ColorWheelControllerDelegate?
  
  let colorTargetView = UIImageView(image: #imageLiteral(resourceName: "Reticule"))
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(colorTargetView)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    moveTo(color: color)
  }
  
  var gamut: Gamut = .displayP3 {
    didSet {
      let traits = UITraitCollection(displayGamut: gamut.displayGamut)
      wheelImageView.image = UIImage(named: gamut.imageName, in: nil, compatibleWith: traits)
      moveTo(colorTargetView.center)
    }
  }
  
  private(set) var color: UIColor = UIColor(named: "rwGreen")!
}

extension ColorWheelController {
  
  func moveTo(_ point: CGPoint) {
    
    let center = wheelImageView.center
    let radius = min (wheelImageView.bounds.width / 2, wheelImageView.bounds.height / 2)
    
    // Calculate distance from touch to center of color wheel
    let xOffset = point.x - center.x
    let yOffset = point.y - center.y
    let distance = sqrt(pow(xOffset, 2) + pow(yOffset, 2))
    
    var position = point
    if distance > radius {
      // If touch is outside of the color wheel,
      // move it to the closest point along the circumference
      position.x = center.x + (xOffset * (radius / distance))
      position.y = center.y + (yOffset * (radius / distance))
    }
    
    colorTargetView.center = position
    
    color = colorFrom(point: position)
    delegate?.didPick(color: color)
  }
  
  func colorFrom(point: CGPoint) -> UIColor {
    
    let center = wheelImageView.center
    
    let xOffset = point.x - center.x
    let yOffset = point.y - center.y
    
    // atan returns values between -pi and +pi
    let atan = atan2(yOffset, xOffset)
    // convert to a value between 0 and 2*pi
    let angle = atan >= 0 ? atan : (atan + (2 * CGFloat.pi))
    
    let hue = 1 - (angle / (2 * CGFloat.pi))
    
    let hsbColor = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
    
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
    hsbColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
    
    switch gamut {
    case .displayP3: return UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
    case .sRGB: return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
  }
  
  func moveTo(color: UIColor) {
    colorTargetView.center = positionFrom(color: color)
  }
  
  func positionFrom(color: UIColor) -> CGPoint {
    var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0
    color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
    
    let angle = (1 - hue) * (2 * CGFloat.pi)
    
    let center = wheelImageView.center
    let radius = min (wheelImageView.bounds.width / 2, wheelImageView.bounds.height / 2)
    
    let x = center.x + (cos(angle) * radius)
    let y = center.y + (sin(angle) * radius)
    
    return CGPoint(x: x, y: y)
  }
}

// MARK: Touch-based event handling
extension ColorWheelController {
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches {
      moveTo(t.location(in: view))
      break
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches {
      moveTo(t.location(in: view))
      break
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
  }
  
}
