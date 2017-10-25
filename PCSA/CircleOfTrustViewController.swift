//
//  CircleOfTrustViewController.swift
//  PCSA
//
//  Created by Chamika Weerasinghe on 6/8/16.
//  Copyright © 2016 Peacecorps. All rights reserved.
//

import UIKit
import Contacts

class CircleOfTrustViewController: MainViewController {

    // MARK: Properties
    @IBOutlet weak var buttonHelpMe: UIButton!
    
    @IBOutlet weak var constraintNorthHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintSouthHeight: NSLayoutConstraint!
    @IBOutlet weak var imageTrustee1: UIImageView!
    @IBOutlet weak var imageTrustee2: UIImageView!
    @IBOutlet weak var imageTrustee3: UIImageView!
    @IBOutlet weak var imageTrustee4: UIImageView!
    @IBOutlet weak var imageTrustee5: UIImageView!
    @IBOutlet weak var imageTrustee6: UIImageView!
    
    @IBOutlet weak var nameTrustee1: UILabel!
    @IBOutlet weak var nameTrustee2: UILabel!
    @IBOutlet weak var nameTrustee3: UILabel!
    @IBOutlet weak var nameTrustee4: UILabel!
    @IBOutlet weak var nameTrustee5: UILabel!
    @IBOutlet weak var nameTrustee6: UILabel!
    
    var phoneNumbers = [String]()
    var imageViews = [UIImageView]()
    var nameLabels = [UILabel]()
    let messageComposer = MessageComposer()

    
    //MARK: Actions
    @IBAction func helpMe(_ sender: AnyObject) {
        var recipients = [String]()
        
        for number in phoneNumbers {
            if(number.characters.count > 0){
                recipients.append(number)
            }
        }
        
        if(recipients.count > 0){
            if (messageComposer.canSendText()) {
                //ask for user to message type
                let actions = [
                    UIAlertAction(title: "Come get me", style: UIAlertActionStyle.default, handler: { (action) in
                        self.presentMessageSend(recipients, body: "Come and get me. I need help getting home Safely. Call ASAP to get my Location.Sent through First Aide's Circle of Trust.")
                    }),
                    UIAlertAction(title: "Call I need an interruption", style: UIAlertActionStyle.default, handler: { (action) in
                        self.presentMessageSend(recipients, body: "Call and pretend you need me. I need an interruption. Message sent through First Aide's Circle of Trust.")
                    }),
                    UIAlertAction(title: "I need to talk", style: UIAlertActionStyle.default, handler: { (action) in
                        self.presentMessageSend(recipients, body: "I need to talk. Message sent through First Aide's Circle of Trust.")
                    }),
                    UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil),
                    ]
                UIUtil.showAlert(self, title: "Select a request", message: "", actions: actions)
                
                
                
                
            } else {
                // Let the user know if his/her device isn't able to send text messages
                UIUtil.showAlert(self, title: "Send Message", message: "Your device cannot send messages", actions: nil)
            }
            
        }
        else{
            UIUtil.showAlert(self, title: "Numbers", message: "No numbers set. Tap Edit to add/edit numbers", actions: nil)
        }
    }
    
    @IBAction func unwindToNumberSave(_ sender:UIStoryboardSegue){
        if let sourceViewController = sender.source as? CircleOfTrustEditViewController{
            //Since numbers update only when save button in CircleOfTrustEditViewController is pressed
            phoneNumbers = sourceViewController.numbers
            updateViews(phoneNumbers)
        }
    }
    
    func presentMessageSend(_ recipients:[String],body:String){
        // Obtain a configured MFMessageComposeViewController
        let messageComposeVC = messageComposer.configuredMessageComposeViewController(recipients, textBody: body)
        present(messageComposeVC, animated: true, completion: nil)
    }
    
    //MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load, cot")
        
        UIUtil.initViewControllerViews(self)
        
        //reposition buttons 1,2,5,6 (buttons which are not in center Y)
        let radius = imageTrustee4.frame.origin.x - buttonHelpMe.frame.origin.x
        let height = radius * sin(NumberUtil.degToRad(60))/UIScreen.main.scale
        
        constraintNorthHeight.constant = height
        constraintSouthHeight.constant = height
        
        imageViews += [imageTrustee1,imageTrustee2,imageTrustee3,imageTrustee4,imageTrustee5,imageTrustee6]
        nameLabels += [nameTrustee1, nameTrustee2, nameTrustee3, nameTrustee4, nameTrustee5, nameTrustee6]
        
        if let savedNumbers = CircleOfTrustEditViewController.loadNumbers() {
            phoneNumbers += savedNumbers
        } else {
            for _ in 0...5{
                phoneNumbers.append("")
            }
        }
        
        for imageView in imageViews{
            imageView.layer.borderWidth = 1.0
            imageView.layer.masksToBounds = false
            imageView.layer.borderColor = UIColor.white.cgColor
            imageView.layer.cornerRadius = imageView.frame.size.width/2
            imageView.clipsToBounds = true
        }
        
        updateViews(phoneNumbers)
    }
    
    func updateViews(_ numbers:[String]){
        loadContactPhotosAndNames(numbers)
    }
    
    func loadContactPhotosAndNames(_ numbers:[String]) {
        var images = [Data]()
        var nameImageDictionary = [Int: (String?, Data?)]()
        var names = [String]()
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey,
            CNContactGivenNameKey,
            CNContactFamilyNameKey]
        contactStore.requestAccess(for: .contacts, completionHandler: { (granted, error) -> Void in
            if granted {
                
                DispatchQueue.global().async {
                    
                    //retrieve images in background
                    let predicate = CNContact.predicateForContactsInContainer(withIdentifier: contactStore.defaultContainerIdentifier())
                    var contacts: [CNContact]! = []
                    do {
                        contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as [CNKeyDescriptor])// [CNContact]
                    } catch {
                        
                    }
                    for contact in contacts {
                        var contactNumbers: [CNLabeledValue<CNPhoneNumber>]! = []
                        var number: CNPhoneNumber!
                        var phoneStr = ""
                        var name = ""
                        
                        for i in 0..<numbers.count{
                            if contact.phoneNumbers.count > 1 {
                                contactNumbers = contact.phoneNumbers
                                for j in 0..<contactNumbers.count {
                                    number = contact.phoneNumbers[j].value
                                    phoneStr = number.stringValue
                                    name = contact.givenName + " " + contact.familyName
                                    if(numbers[i] == phoneStr){
                                        names.append(name)
                                        if contact.imageDataAvailable {
                                            images.append(contact.thumbnailImageData!)
                                            nameImageDictionary[names.index(of: name)!] = (name, contact.thumbnailImageData)
                                        } else {
                                            nameImageDictionary[names.index(of: name)!] = (name, nil)
                                        }
                                    }
                                }
                            } else if contact.phoneNumbers.count == 1 {
                                number = contact.phoneNumbers[0].value
                                phoneStr = number.stringValue
                                name = contact.givenName + " " + contact.familyName
                                if(numbers[i] == phoneStr){
                                    names.append(name)
                                    if contact.imageDataAvailable {
                                        images.append(contact.thumbnailImageData!)
                                        nameImageDictionary[names.index(of: name)!] = (name, contact.thumbnailImageData)
                                    } else {
                                        nameImageDictionary[names.index(of: name)!] = (name, nil)
                                    }
                                }
                            }
                        }
                    }
                    NSLog("images.count \(images.count)")
                    

                    DispatchQueue.main.async {
                        // update UI main thread
                        
                        for i in 0..<self.imageViews.count {
                            if nameImageDictionary.keys.contains(i) {
                                let label = self.nameLabels[i]
                                let imageView = self.imageViews[i]
                                
                                let values = nameImageDictionary[i]
                                if let name = values?.0 {
                                    label.text = name
                                }
                                if let imageData = values?.1 {
                                    let image = UIImage(data:imageData,scale:1.0)
                                    imageView.image = image
                                }
                                if values == nil {
                                    imageView.image = UIImage(named: "TrusteeDefault")
                                }
                                label.setNeedsDisplay()
                                imageView.setNeedsDisplay()
                            } else {
                                let imageView = self.imageViews[i]
                                imageView.image = UIImage(named: "TrusteeDefault")
                                imageView.setNeedsDisplay()
                            }
                        }
                    }
                }
            }
        })
    }
    
}
