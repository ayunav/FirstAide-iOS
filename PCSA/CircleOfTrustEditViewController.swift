//
//  CircleOfTrustEditViewController.swift
//  PCSA
//
//  Created by Chamika Weerasinghe on 6/10/16.
//  Copyright © 2016 Peacecorps. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class CircleOfTrustEditViewController: MainViewController, CNContactPickerDelegate, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var textFieldNumber1: UITextField!
    @IBOutlet weak var textFieldNumber2: UITextField!
    @IBOutlet weak var textFieldNumber3: UITextField!
    @IBOutlet weak var textFieldNumber4: UITextField!
    @IBOutlet weak var textFieldNumber5: UITextField!
    @IBOutlet weak var textFieldNumber6: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contactsButton1: UIButton!
    @IBOutlet weak var contactsButton2: UIButton!
    @IBOutlet weak var contactsButton3: UIButton!
    @IBOutlet weak var contactsButton4: UIButton!
    @IBOutlet weak var contactsButton5: UIButton!
    @IBOutlet weak var contactsButton6: UIButton!

    var numbers = [String]()
    var textFields = [UITextField]()
    var contactsButtons = [UIButton]()
    
    var selectedTextField: UITextField!
    var activeField: UITextField?
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("numbers")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIUtil.initViewControllerViews(self)

        contactsButtons = [contactsButton1, contactsButton2, contactsButton3,
                           contactsButton4, contactsButton5, contactsButton6]

        let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)

        for button in 0...5 {
            if status == .denied || status == .restricted {
                contactsButtons[button].isHidden = true
            } else {
                contactsButtons[button].isHidden = false
            }
        }

        textFields += [textFieldNumber1,textFieldNumber2,textFieldNumber3,textFieldNumber4,textFieldNumber5,textFieldNumber6]
        
        if let savedNumbers = CircleOfTrustEditViewController.loadNumbers() {
            numbers += savedNumbers
        } else {
            for _ in 0...5{
                numbers.append("")
            }
        }
        updateTextFields(numbers)
        
        //set textFields delegate
        for i in 0..<(textFields.count){
            textFields[i].delegate = self;
        }
        addDoneButtonOnKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        registerForKeyboardNotifications()
    }
    
    //MARK: Actions
    @IBAction func selectContact(_ sender: UIButton) {
        self.selectContactPick(sender.tag)
    }
    
    func selectContactPick(_ index:Int) {
        selectedTextField = textFields[index]
        let contactPicker = CNContactPickerViewController()
        contactPicker.displayedPropertyKeys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactImageDataKey, CNContactPhoneNumbersKey]
        contactPicker.delegate = self
        navigationController?.present(contactPicker,
                                                    animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if(identifier == "exitSaveNumbers" ){
            return self.saveNumbers()
        }
        return true
    }
    
    //MARK: Data
    func saveNumbers() -> Bool {
        for i in 0...5 {
            if !numbers.contains(textFields[i].text!) {
                numbers[i] = textFields[i].text!
            }
        }
        
        let saveSuccess = NSKeyedArchiver.archiveRootObject(numbers, toFile: CircleOfTrustEditViewController.ArchiveURL.path)
        if saveSuccess {
            return true
        } else {
            UIUtil.showAlert(self, title: "Save", message: "Numbers failed to save", actions: nil)
            return false
        }
    }
    
    static func loadNumbers() -> [String]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: CircleOfTrustEditViewController.ArchiveURL.path) as? [String]
    }
    
    func updateTextFields(_ numbers:[String]) {
        for i in 0..<numbers.count {
            textFields[i].text = numbers[i]
        }
    }
    
    //MARK: Keyboard handling
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 50))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(CircleOfTrustEditViewController.finishDecimalKeypad))
        
        var items: [UIBarButtonItem]? = [UIBarButtonItem]()
        items?.append(flexSpace)
        items?.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        for i in 0...5{
            textFields[i].inputAccessoryView=doneToolbar
        }
        
    }
    
    func finishDecimalKeypad() {
        for i in 0...5{
            textFields[i].resignFirstResponder()
        }
    }
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(CircleOfTrustEditViewController.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CircleOfTrustEditViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(_ notification: Notification)
    {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        let info : NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if (activeField != nil)
        {
            if (!aRect.contains(activeField!.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
        
        
    }
    
    
    func keyboardWillBeHidden(_ notification: Notification)
    {
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
        
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        activeField = nil
    }
    
    // MARK: Contacts Picker
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        let phoneNumber = contactProperty.value as! CNPhoneNumber
        selectedTextField.text = phoneNumber.stringValue
    }
    
}



