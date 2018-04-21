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

protocol BrightnessControllerDelegate: class {
  func didChange(brightness: CGFloat)
}

class BrightnessController: UIViewController {
  
  @IBOutlet weak private var trackBackground: UIView!
  @IBOutlet weak private var renderView: UIImageView!
  @IBOutlet weak private var gradient: GradientView!
  @IBOutlet weak private var slider: UISlider!
  
  weak var delegate: BrightnessControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    themeSlider()
  }
  
  @IBAction private func brightnessChanged(_ sender: Any) {
    delegate?.didChange(brightness: brightness)
  }
  
  var brightness: CGFloat {
    get {
      return CGFloat(1.0 - slider.value)
    }
    set {
      slider.value = Float(1.0 - newValue)
    }
  }
}

// MARK: Color change

extension BrightnessController {
  func setColor(_ color: UIColor) {
    renderColor(color)
  }
}

// MARK: Image rendering

extension BrightnessController {
  func renderColor(_ color: UIColor) {
    
    let size = renderView.bounds.size
    
    DispatchQueue.global().async { [weak self] in
      guard let strongSelf = self else {
        return
      }
      let image = strongSelf.image(for: color, withSize: size)
      
      DispatchQueue.main.async { [weak self] in
        guard let strongSelf = self else {
          return
        }
        strongSelf.renderView.image = image
      }
    }
  }
  
  func image(for color: UIColor, withSize size: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    
    let image = renderer.image { (renderContext) in
      let bounds = renderContext.format.bounds
      color.set()
      renderContext.fill(bounds)
    }

    return image
  }
}

// MARK: customize appearance

extension BrightnessController {
  private func themeSlider() {
    slider.setThumbImage(#imageLiteral(resourceName: "Reticule"), for: .normal)
    
    customizeGradient()
    
    trackBackground.layer.cornerRadius = 5
    trackBackground.layer.borderColor = UIColor(white: 0.5, alpha: 1).cgColor
    trackBackground.layer.borderWidth = 1
  }
  
  private func customizeGradient() {
    let gradientLayer = gradient.gradientLayer
    
    let startColor = UIColor(white: 0, alpha: 0)
    let endColor = UIColor(white: 0, alpha: 1)
    
    gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    gradientLayer.locations = [0, 1]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
  }
}
