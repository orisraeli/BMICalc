//
//  ViewController.swift
//  BMICalc
//
//  Created by Or Israeli on 16/01/2017.
//  Copyright © 2017 Or Israeli. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate { //delegates for picker + text field
   
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var nameInput: UITextField!            //name input decleration
    @IBOutlet weak var resultLabel: UILabel!              //result label decleration
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var myPicker: UIPickerView!            //ui picker decleration
    
     let metric:[[String]] = [                                        //declare array of string arrays for metric
        ["50","51","52","53","54","55","56","57","58","59",           //weight in kg array
         "60","61","62","63","64","65","66","67","68","69",
         "70","71","72","73","74","75","76","77","78","79",
         "80","81","82","83","84","85","86","87","88","89",
         "90","91","92","93","94","95","96","97","98","99",
         "100"], ["kg"],                                              //kg unit array
        ["150","151","152","153","154","155","156","157","158","159", //height in cm array
         "160","161","162","163","164","165","166","167","168","169",
         "170","171","172","173","174","175","176","177","178","179",
         "180","181","182","183","184","185","186","187","188","189",
         "190","191","192","193","194","195","196","197","198","199",
         "200"], ["cm"]                                               //cm unit array
    ]
    
    let imperial:[[String]] = [                                      //declare array of string arrays for imperial
        ["110","111","112","113","114","115","116","117","118","119",//weight in lbs array
         "120","121","122","123","124","125","126","127","128","129",
         "130","131","132","133","134","135","136","137","138","139",
         "140","141","142","143","144","145","146","147","148","149",
         "150","151","152","153","154","155","156","157","158","159",
         "160","161","162","163","164","165","166","167","168","169",
         "170","171","172","173","174","175","176","177","178","179",
         "180","181","182","183","184","185","186","187","188","189",
         "190","191","192","193","194","195","196","197","198","199",
         "200","201","202","203","204","205","206","207","208","209",
         "210","211","212","213","214","215","216","217","218","219",
         "220"], ["lbs"],                                            //lbs unit array
        [                                             "59",          //height in inches array
         "60","61","62","63","64","65","66","67","68","69",
         "70","71","72","73","74","75","76","77","78"],["inch"]      //inches unit array
    ]
    
    let weightComponent = 0             //names 1st array as the weight component
    let weightUnitComp = 1              //names 2nd array as the weight unit component
    let heightComponent = 2             //names 3rd array as the height component
    let heightUnitComp = 3              //names 4th array as the height unit component
    
    var unitRef = "EU"                  //var to hold the segmet state when not possible to use sender
    var bmi = 24                         //var to hold bmi
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
            myPicker.selectRow(20, inComponent: weightComponent, animated: false) //initialize weight row to avg.
            myPicker.selectRow(20, inComponent: heightComponent, animated: false) //initialize height row to avg.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { //sets picker to 4 columns (components)
        return 4
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { //sets number of rows for each column from the array
        if unitRef == "EU" {
            return metric[component].count
        }
        if unitRef == "US" {
            return imperial[component].count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { //sets rows content for each column from array
        if unitRef == "EU" {
            return metric[component][row]
        }
        if unitRef == "US" {
            return imperial[component][row]
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat { //sets width for each column
        switch component {
        case weightComponent:
            return CGFloat(60);
        case weightUnitComp:
            return CGFloat(40);
        case heightComponent:
            return CGFloat(60);
        case heightUnitComp:
            return CGFloat(60);
        default:
            print("error setting component width") //debugging
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { //uses row selection/change to run code
        if unitRef == "EU" {
            calculateMetricBMI()                                //calls metric calculate function
        }
        if unitRef == "US" {
            calculateImperialBMI()                              //calls imperial calculate function
        }
    }
    
    
    @IBAction func segmentDidChange(_ sender: UISegmentedControl) {               //uses segment selection/change to run code
        if sender.selectedSegmentIndex == 0 {                                     //determines segment state
            unitRef = "EU"
            print("selected metric")                                              //debugging
            myPicker.selectRow(20, inComponent: weightComponent, animated: false) //initialize weight row to avg.
            myPicker.selectRow(20, inComponent: heightComponent, animated: false) //initialize height row to avg.
        }
        else {                                                                    //determines segment state
            unitRef = "US"
            print("selected imperial")                                            //debugging
            myPicker.selectRow(20, inComponent: weightComponent, animated: false) //initialize weight row to avg.
            myPicker.selectRow(4 , inComponent: heightComponent, animated: false)  //initialize height row to avg.
        }
        myPicker.reloadAllComponents()                                            //refreshes picker contents
        statusLabel.text = ""                                                     //clears label
        resultLabel.text = ""                                                     //clears label
        
    }
    
    func calculateMetricBMI(){                                                    //bmi metric calculation
        print("calculated metric")                                                //debugging
        let userWeight:Float = Float (metric[weightComponent][myPicker.selectedRow(inComponent: weightComponent)])! //saves user picker selction and converts
        var userHeight:Float = Float (metric[heightComponent][myPicker.selectedRow(inComponent: heightComponent)])! //the string to float.
        userHeight = userHeight / 100                                             //bmi calc
        bmi = Int (userWeight / (userHeight * userHeight))                        //bmi calc
        printResult()
    }
    
    func calculateImperialBMI(){                                                  //bmi imperial calculation
        print("calculated imperial")                                              //debugging
        var userWeight:Float = Float (imperial[weightComponent][myPicker.selectedRow(inComponent: weightComponent)])! //saves user picker selction and converts
        let userHeight:Float = Float (imperial[heightComponent][myPicker.selectedRow(inComponent: heightComponent)])! //the string to float.
        userWeight = userWeight * 703                                             //bmi calc
        bmi = Int (userWeight / (userHeight * userHeight))                        //bmi calc
        printResult()
    }
    
    func printResult() {                                                          //this function prints the calc result to label
        print("printing result")
        var status = ""                                                           //placeholder for the result status
        if bmi >= 0 && bmi <= 18 {                                                //figures wich category the bmi belongs to and overwrite it to status
            status = "Underweight"
            statusLabel.textColor = UIColor.red
        }
        if bmi >= 19 && bmi <= 25 {
            status = "Normal"
            statusLabel.textColor = UIColor.blue
        }
        if bmi >= 26 && bmi <= 30 {
            status = "Overweight"
            statusLabel.textColor = UIColor.orange
        }
        if bmi >= 31 && bmi <= 60 {
            status = "Obese"
            statusLabel.textColor = UIColor.red
        }
        if bmi >= 60 {
            resultLabel.text = "error: BMI is not in range"                            //debugging
            print("error: BMI is not in range" )
        }
        if bmi < 0 {
            resultLabel.text = "error: BMI is not in range"                            //debugging
            print("error: BMI is not in range" )
        }
        let name = nameInput.text!                                                     //loads user's name input to string
        if name.characters.count > 16 {                                                //debugging
            backgroundImage.image = UIImage(named: "bckg-reg")
            resultLabel.textColor = UIColor.black
            resultLabel.text = "error: name is too long"
            statusLabel.text = ""
            print("error: name is too long")
        }
        else if name == "" {                                                           //checks if users name is empty
            backgroundImage.image = UIImage(named: "bckg-reg")
            resultLabel.textColor = UIColor.black
            statusLabel.text = status
            resultLabel.text = "Your BMI is \(bmi)."                                   //prints results if name is empty
            print("no name entered")                                                   //debugging
        }
        else if name == "Pushi" {                                                      //girlfriend mode (easter egg)
            backgroundImage.image = UIImage(named: "bckg-egg")
            statusLabel.textColor = UIColor.purple
            resultLabel.textColor = UIColor.purple
            statusLabel.text = "Pushi i love you! <3"
            resultLabel.text = "Your BMI is \(bmi)."
            print("gf mode")                                                           //debugging
        }
        else {                                                                         //prints results with name
            backgroundImage.image = UIImage(named: "bckg-reg")
            resultLabel.textColor = UIColor.black
            statusLabel.text = status
            resultLabel.text = "\(name), your BMI is \(bmi)."
        }
        nameInput.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {               //dismiss keyboard when user touch blank spots
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //dismiss keyboard and run code after user hit keyboard Return(Done)
        if unitRef == "EU" {
            calculateMetricBMI()                                //calls metric calculate function
            nameInput.resignFirstResponder()                    //dismiss keyboard
            return false
        }
        if unitRef == "US"{
            calculateImperialBMI()                              //calls imperial calculate function
            nameInput.resignFirstResponder()                    //dismiss keyboard
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
