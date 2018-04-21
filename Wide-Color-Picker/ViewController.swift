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
  
  @IBOutlet weak var gamutSelector: UISegmentedControl!
  @IBOutlet weak var pickerContainer: UIView!
  @IBOutlet weak var trackBackground: UIView!
  @IBOutlet weak var gradientContainer: UIView!
  @IBOutlet weak var slider: UISlider!
  @IBOutlet weak var swatchContainer: UIView!
  
  var colorWheel: ColorWheelController!
  var swatch: ColorSwatchController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    themeSlider()
    configureColorWheel()
    configureSwatch()
    
    selectGamut(traitCollection.displayGamut)
    setColor(UIColor(named: "rwGreen")!)
  }
  
  @IBAction func gamutSelectionChanged(_ sender: Any) {
    setGamut(gamut)
  }
  
  @IBAction func brightnessChanged(_ sender: Any) {
    setBrightness(brightness)
  }
  
  var gamut: Gamut {
    guard let gamut = Gamut(rawValue: gamutSelector.selectedSegmentIndex) else {
      return .displayP3
    }
    
    return gamut
  }
  var brightness: CGFloat {
    return CGFloat(1.0 - slider.value)
  }
}

// MARK: Gamut Selector
extension ViewController {
  
  func selectGamut(_ displayGamut: UIDisplayGamut) {
    let gamut = Gamut.from(displayGamut: displayGamut)
    gamutSelector.selectedSegmentIndex = gamut.rawValue
    setGamut(gamut)
  }
  
  func setGamut(_ gamut: Gamut) {
    colorWheel.gamut = gamut
  }
}

// MARK: brightness

extension ViewController {
  func setBrightness(_ value: CGFloat) {
    didPick(color: colorWheel.color)
  }
}

// MARK: Color Wheel Controller Delegate

extension ViewController: ColorWheelControllerDelegate {
  func didPick(color: UIColor) {
    updateColor(with: color)
  }
  
  func updateColor(with hueColor: UIColor) {
    var hue: CGFloat = 0
    hueColor.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
    
    let b = self.brightness
    let hueBrightnessColor = UIColor(hue: hue, saturation: 1, brightness: b, alpha: 1)
    var finalColor: UIColor
    
    switch gamut {
    case .displayP3:
      var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
      hueBrightnessColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
      finalColor = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
    case .sRGB:
      finalColor = hueBrightnessColor
    }
    
    setColor(finalColor, updateBrightness: false)
  }
  
  func setColor(_ color: UIColor, updateBrightness: Bool = true) {
    swatch.setColor(color)
    
    if updateBrightness {
      var brightness: CGFloat = 0
      if color.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil) == false {
        print("failed to get brightness")
        return
      }
      
      slider.value = Float(1 - brightness)
    }
  }
}

// MARK: Appearance customization

extension ViewController {
  private func themeSlider() {
    slider.setThumbImage(#imageLiteral(resourceName: "Reticule"), for: .normal)
    
    buildSliderGradient()
    
    trackBackground.layer.cornerRadius = 5
    trackBackground.layer.borderColor = UIColor(white: 0.5, alpha: 1).cgColor
    trackBackground.layer.borderWidth = 1
  }
  
  private func buildSliderGradient() {
    let gradient = CAGradientLayer()
    
    gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
    gradient.locations = [0, 1]
    gradient.startPoint = CGPoint(x: 0, y: 0.5)
    gradient.endPoint = CGPoint(x: 1, y: 0.5)
    gradient.frame = gradientContainer.bounds
    
    gradientContainer.layer.addSublayer(gradient)
  }
  
  private func configureColorWheel() {
    
    let storyboard = UIStoryboard(name:"Main", bundle: nil)
    let picker = storyboard.instantiateViewController(withIdentifier: "ColorWheelController") as! ColorWheelController
    picker.delegate = self
    addChildViewController(picker)
    picker.view.frame = pickerContainer.bounds
    pickerContainer.addSubview(picker.view)
    picker.didMove(toParentViewController: self)
    
    colorWheel = picker
  }
  
  private func configureSwatch() {
    let storyboard = UIStoryboard(name:"Main", bundle: nil)
    let colorSwatch = storyboard.instantiateViewController(withIdentifier: "ColorSwatchController") as! ColorSwatchController
    addChildViewController(colorSwatch)
    colorSwatch.view.frame = swatchContainer.bounds
    swatchContainer.addSubview(colorSwatch.view)
    colorSwatch.didMove(toParentViewController: self)
    
    swatch = colorSwatch
  }
}
