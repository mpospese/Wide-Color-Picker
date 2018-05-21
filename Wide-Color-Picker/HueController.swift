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

protocol HueControllerDelegate: class {
  func didChange(hue: CGFloat)
}

class HueController: UIViewController {
  
  @IBOutlet weak private var wheelImageView: UIImageView!
  private let colorTargetView = UIImageView(image: #imageLiteral(resourceName: "Reticule"))
  
  weak var delegate: HueControllerDelegate?  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(colorTargetView)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    moveTargetTo(color: color)
  }
  
  private var gamut: Gamut = .displayP3
  
  private(set) var hue: CGFloat = 0
  
  private(set) var color: UIColor = .red
}

// MARK: change gamut

extension HueController {
  
  func setGamut(_ gamut: Gamut) {
    self.gamut = gamut
    let traits = UITraitCollection(displayGamut: gamut.displayGamut)
    wheelImageView.image = UIImage(named: gamut.imageName, in: nil, compatibleWith: traits)
    didMove(to: colorTargetView.center)
  }
}

// MARK: Color change

extension HueController {
  func setColor(_ color: UIColor) {
    self.color = color
    moveTargetTo(color: color)
    updateColorFrom(point: self.colorTargetView.center)
  }
}

// MARK: conversion between point in circle and color

extension HueController {
  
  private func didMove(to point: CGPoint) {
    
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
    
    updateColorFrom(point: position)
    delegate?.didChange(hue: hue)
  }
  
  private func updateColorFrom(point: CGPoint) {
    
    let center = wheelImageView.center
    
    let xOffset = point.x - center.x
    let yOffset = point.y - center.y
    
    // atan returns values between -pi and +pi
    let atan = atan2(yOffset, xOffset)
    // convert to a value between 0 and 2*pi
    let angle = atan >= 0 ? atan : (atan + (2 * CGFloat.pi))
    
    self.hue = 1 - (angle / (2 * CGFloat.pi))
    
    let hsbColor = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
    
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
    hsbColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
    
    switch gamut {
    case .displayP3:
      self.color = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
    case .sRGB:
      self.color = UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
  }
  
  private func moveTargetTo(color: UIColor) {
    colorTargetView.center = positionFrom(color: color)
  }
  
  private func positionFrom(color: UIColor) -> CGPoint {
    // extract hue from color
    var hue: CGFloat = 0
    if color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil) == false {
      // Color space was not compatible, so let's convert to extended SRGB,
      // which is compatible
      if let colorSpace = CGColorSpace(name: CGColorSpace.extendedSRGB),
        let convertedCGColor = color.cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil) {
        let extendedSRGBColor = UIColor(cgColor: convertedCGColor)
        // Try again with our extended SRGB color
        if extendedSRGBColor.getHue(&hue, saturation: nil, brightness: nil, alpha: nil) == false {
          print("Hue Controller failed to get hue")
        }
      }
    }
    
    let angle = (1 - hue) * (2 * CGFloat.pi)
    
    let center = wheelImageView.center
    let radius = min (wheelImageView.bounds.width / 2, wheelImageView.bounds.height / 2)
    
    let x = center.x + (cos(angle) * radius)
    let y = center.y + (sin(angle) * radius)
    
    return CGPoint(x: x, y: y)
  }
}

// MARK: Touch-based event handling

extension HueController {
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches {
      didMove(to: t.location(in: view))
      break
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches {
      didMove(to: t.location(in: view))
      break
    }
  }
}
