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

class ViewController: UIViewController {
  
  @IBOutlet weak private var pickerContainer: UIView!
  @IBOutlet weak private var sliderContainer: UIView!
  @IBOutlet weak private var swatchContainer: UIView!
  
  var colorWheel: HueController!
  var slider: BrightnessController!
  var swatch: ColorSwatchController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureColorWheel()
    configureBrightnessSlider()
    configureSwatch()
    
    let defaultColor = UIColor.green
    
    colorWheel.setColor(defaultColor)
    swatch.setColor(defaultColor)
    slider.updateBrightness(from: defaultColor)
    slider.setColor(colorWheel.color)
  }
}
  
// MARK: Color Wheel Controller Delegate

extension ViewController: HueControllerDelegate {
  func didChange(hue: CGFloat) {
    slider.setColor(colorWheel.color)
    updateSwatch()
  }
  
  func updateSwatch() {
    // Combine hue from color wheel and brightness from slider to update the
    // color swatch
    let hue = colorWheel.hue
    let brightness = slider.brightness
    let hueBrightnessColor = UIColor(hue: hue, saturation: 1, brightness: brightness, alpha: 1)
    
    swatch.setColor(hueBrightnessColor)
  }
}

// MARK: Brightness Controller Delegate

extension ViewController: BrightnessControllerDelegate {
  func didChange(brightness: CGFloat) {
    updateSwatch()
  }
}

// MARK: Appearance customization

extension ViewController {
  private func configureColorWheel() {
    let wheel = instantiateViewController(withIdentifier: "HueController") as! HueController
    wheel.delegate = self
    addChildViewController(wheel, to: pickerContainer)
    
    colorWheel = wheel
  }
  
  private func configureBrightnessSlider() {
    let brightnessSlider = instantiateViewController(withIdentifier: "BrightnessController") as! BrightnessController
    brightnessSlider.delegate = self
    addChildViewController(brightnessSlider, to: sliderContainer)
    
    slider = brightnessSlider
  }
  
  private func configureSwatch() {
    let colorSwatch = instantiateViewController(withIdentifier: "ColorSwatchController") as! ColorSwatchController
    addChildViewController(colorSwatch, to: swatchContainer)
    
    swatch = colorSwatch
  }
  
  private func instantiateViewController(withIdentifier identifier: String) -> UIViewController? {
    let storyboard = UIStoryboard(name:"Main", bundle: nil)
    return storyboard.instantiateViewController(withIdentifier: identifier)
  }
  
  private func addChildViewController(_ child: UIViewController, to parentView: UIView) {
    addChildViewController(child)
    child.view.frame = parentView.bounds
    parentView.addSubview(child.view)
    child.didMove(toParentViewController: self)
  }
}
