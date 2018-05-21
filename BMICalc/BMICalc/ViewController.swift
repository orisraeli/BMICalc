//
//  ViewController.swift
//  BMICalc
//
//  Created by Or Israeli on 16/01/2017.
//  Copyright © 2017 Or Israeli. All rights reserved.
//

import UIKit

// storing locale - better to switch to default ios locale
fileprivate enum LocaleSystem {
	case metric, imperial
}

// storing measurement with helpful unit - better swtich to ios locale
fileprivate enum Measurement {
	case weight, height

	func unit(for locale: LocaleSystem) -> String {
		switch (locale, self) {
		case (.metric, .weight): return "kg"
		case (.metric, .height): return "cm"
		case (.imperial, .weight): return "lbs"
		case (.imperial, .height): return "inch"
		}
	}
}

// enum for better casing
fileprivate enum BMIStatus: String {
	case underweight = "Underweight"
	case normal = "Normal"
	case overweight = "Overweight"
	case obese = "Obese"

	var color: UIColor {
		switch self {
		case .underweight: return .red
		case .normal: return .blue
		case .overweight: return .orange
		case .obese: return .red
		}
	}
}

// added as extension not to override default (init: rawValue)
extension BMIStatus {
	init(value: Int) {
		switch value {
		case Int.min..<18: self = .underweight
		case 18..<25: self = .normal
		case 26..<30: self = .overweight
		case 31...Int.max: self = .obese
		default: self = .normal // this won't ever happen
		}
	}
}

class ViewController: UIViewController {

	// components for differenting pickers/segmented control
	fileprivate enum SegmentedComponents: Int { case metric = 0, imperial }
	fileprivate enum PickerComponents: Int { case weight = 0, weightUnit, height, heightUnit }

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var myPicker: UIPickerView!
	@IBOutlet weak var localeSegmentedControl: UISegmentedControl!

	// for light status bar
	override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

	// setting default locale based on ios settings
	fileprivate lazy var locale: LocaleSystem = {
		if Locale.current.usesMetricSystem {
			self.localeSegmentedControl.selectedSegmentIndex = SegmentedComponents.metric.rawValue
			return .metric
		} else {
			self.localeSegmentedControl.selectedSegmentIndex = SegmentedComponents.imperial.rawValue
			return .imperial
		}
	}()

	fileprivate var dataSource: [Measurement: [Int]] {
		switch self.locale {
		case .metric:
			return [.weight: (50...100).map { $0 }, .height: (150...200).map { $0 }]
		case .imperial:
			return [.weight: (110...220).map { $0 }, .height: (59...78).map { $0 }]
		}
	}

	// MARK: system methods
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePickers()
    }

	// MARK: outside actions
    @IBAction func segmentDidChange(_ sender: UISegmentedControl) {
		switch SegmentedComponents(rawValue: sender.selectedSegmentIndex) {
		case .metric?: locale = .metric
		case .imperial?: locale = .imperial
		case .none: return
		}
		updatePickers()
		updateText()
    }

	// MARK: helpers

	// calculating bmi based on w/h
	fileprivate func calculate() -> Int {
		guard let weight = dataSource[.weight]?[myPicker.selectedRow(inComponent: PickerComponents.weight.rawValue)] else { return 0 }
		guard let height = dataSource[.height]?[myPicker.selectedRow(inComponent: PickerComponents.height.rawValue)] else { return 0 }

		switch locale {
		case .metric:
			let tempHeight = Float(height)/100
			return Int(Float(weight) / (tempHeight * tempHeight))
		case .imperial:
			let tempWeight = Float(weight)*703
			return Int(tempWeight / ((Float(height) * Float(height))))
		}
	}

	fileprivate func display(bmi: Int) {
		let status = BMIStatus(value: bmi)
		statusLabel.text = status.rawValue
		statusLabel.textColor = status.color

		guard let name = nameInput.text else { return }

		backgroundImage.image = #imageLiteral(resourceName: "bckg-reg")
		resultLabel.textColor = .white
		resultLabel.text = "\(name)"

		if name.characters.count == 0 {
			resultLabel.text = "Your bmi is \(bmi)"
		}

		if name.characters.count > 16 {
			resultLabel.text = "Name is too long"
			statusLabel.text = ""
		}

		if name == "Pushi" {
			backgroundImage.image = #imageLiteral(resourceName: "bckg-egg")
			statusLabel.textColor = .purple
			resultLabel.textColor = .purple
			statusLabel.text = "Pushi i love you! ❤️"
			resultLabel.text = "Your BMI is \(bmi)"
		}
	}

	// update pickers to default values (avg let's say :p)
	private func updatePickers() {
		switch locale {
		case .metric:
			myPicker.selectRow(20, inComponent: PickerComponents.weight.rawValue, animated: false)
			myPicker.selectRow(20, inComponent: PickerComponents.height.rawValue, animated: false)
		case .imperial:
			myPicker.selectRow(20, inComponent: PickerComponents.weight.rawValue, animated: false)
			myPicker.selectRow(4, inComponent: PickerComponents.height.rawValue, animated: false)
		}
		myPicker.reloadAllComponents()
	}

	// reseting text to default
	private func updateText() {
		statusLabel.text = ""
		resultLabel.text = ""
	}

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension ViewController: UIPickerViewDelegate {
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		display(bmi: calculate())
	}
}

extension ViewController: UIPickerViewDataSource {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 4
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch PickerComponents(rawValue: component) {
		case .height?: return dataSource[.height]!.count
		case .weight?: return dataSource[.weight]!.count
		case .heightUnit?, .weightUnit?: return 1
		case .none: return 0
		}
	}

	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		let string: String
		switch PickerComponents(rawValue: component) {
		case .height?: string = String(dataSource[.height]![row])
		case .weight?: string = String(dataSource[.weight]![row])
		case .heightUnit?: string = Measurement.height.unit(for: locale)
		case .weightUnit?: string = Measurement.weight.unit(for: locale)
		case .none: string = ""
		}
		return NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName: UIColor.white,
		                                                       NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)])
	}

	func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		return 60
	}
}

extension ViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		display(bmi: calculate())
		textField.resignFirstResponder()
		return false
	}
}
