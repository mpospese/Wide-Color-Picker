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

class ColorSwatchController: UIViewController {
  
  @IBOutlet weak private var rgbLabel: UILabel!
  @IBOutlet weak private var rgbRedLabel: UILabel!
  @IBOutlet weak private var rgbRedValueLabel: UILabel!
  @IBOutlet weak private var rgbGreenLabel: UILabel!
  @IBOutlet weak private var rgbGreenValueLabel: UILabel!
  @IBOutlet weak private var rgbBlueLabel: UILabel!
  @IBOutlet weak private var rgbBlueValueLabel: UILabel!

  @IBOutlet weak private var p3Label: UILabel!
  @IBOutlet weak private var p3RedLabel: UILabel!
  @IBOutlet weak private var p3RedValueLabel: UILabel!
  @IBOutlet weak private var p3GreenLabel: UILabel!
  @IBOutlet weak private var p3GreenValueLabel: UILabel!
  @IBOutlet weak private var p3BlueLabel: UILabel!
  @IBOutlet weak private var p3BlueValueLabel: UILabel!
  
  private var allLabels: [UILabel] {
    return [rgbLabel, rgbRedLabel, rgbRedValueLabel, rgbGreenLabel, rgbGreenValueLabel, rgbBlueLabel, rgbBlueValueLabel,
            p3Label, p3RedLabel, p3RedValueLabel, p3GreenLabel, p3GreenValueLabel, p3BlueLabel, p3BlueValueLabel]
  }
}

// MARK: set color

extension ColorSwatchController {
  func setColor(_ color: UIColor) {
    view.backgroundColor = color
    
    displayP3Values(for: color)
    displayRGBValues(for: color)
    updateTextColor(for: color)
  }
}

// MARK: update labels

extension ColorSwatchController {
  private func displayP3Values(for color: UIColor) {
    
    // UIColors are in sRGB color space and expressed in extended sRGB even if they were created
    // with UIColor.init(displayP3Red:green:blue:alpha:)
    
    // Convert color to P3 color space
    guard let colorSpaceP3 = CGColorSpace(name: CGColorSpace.displayP3),
      let cgP3Color = color.cgColor.converted(to: colorSpaceP3, intent: .defaultIntent, options: nil),
      let components = cgP3Color.components,
      components.count >= 3 else {
        p3RedValueLabel.text = nil
        p3GreenValueLabel.text = nil
        p3BlueValueLabel.text = nil
        return
    }
    
    p3RedValueLabel.text = String(format: "%.02f", components[0])
    p3GreenValueLabel.text = String(format: "%.02f", components[1])
    p3BlueValueLabel.text = String(format: "%.02f", components[2])
  }
  
  private func displayRGBValues(for color: UIColor) {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: nil)
    
    rgbRedValueLabel.text = String(format: "%.02f", red)
    rgbGreenValueLabel.text = String(format: "%.02f", green)
    rgbBlueValueLabel.text = String(format: "%.02f", blue)
  }
  
  private func updateTextColor(for color: UIColor) {
    var brightness: CGFloat = 0
    guard color.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil) == true else {
      return
    }
    
    let white = CGFloat(brightness > 0.5 ? 0.0 : 1.0)
    let alpha = brightness > 0.5 ? brightness : (1 - brightness)
    let textColor: UIColor = UIColor(white: white, alpha: alpha)
    
    for label in allLabels {
      label.textColor = textColor
    }
  }
}
