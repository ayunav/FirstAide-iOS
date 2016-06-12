//
//  CircleOfTrustViewController.swift
//  PCSA
//
//  Created by Chamika Weerasinghe on 6/8/16.
//  Copyright © 2016 Peacecorps. All rights reserved.
//

import UIKit

class CircleOfTrustViewController: UIViewController {
    
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
    
    var numbers = [String]()
    var imageViews = [UIImageView]()
    let messageComposer = MessageComposer()
    
    //MARK: Actions
    @IBAction func helpMe(sender: AnyObject) {
        var recipients = [String]()
        
        for number in numbers {
            if(number.characters.count > 0){
                recipients.append(number)
            }
        }
        
        if(recipients.count > 0){
            if (messageComposer.canSendText()) {
                //TODO ask for user to message type
                let body = "Come and get me" // Create your message body here
                // Obtain a configured MFMessageComposeViewController
                let messageComposeVC = messageComposer.configuredMessageComposeViewController(recipients, textBody: body)
                presentViewController(messageComposeVC, animated: true, completion: nil)
                
            } else {
                // Let the user know if his/her device isn't able to send text messages
                //            self.displayAlerViewWithTitle("Cannot Send Text Message", andMessage: "Your device is not able to send text messages.")
                print("Does not support sending SMS")
            }
            
        }
        else{
            print("No numbers set. Tap Edit to add/edit numbers")
        }
    }
    
    @IBAction func unwindToNumberSave(sender:UIStoryboardSegue){
        if let sourceViewController = sender.sourceViewController as? CircleOfTrustEditViewController{
            //Since numbers update only when save button in CircleOfTrustEditViewController is pressed
            numbers = sourceViewController.numbers
            updateImageViews(numbers)
        }
        
    }
    
    //MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIUtil.initViewControllerViews(self)
        
        //reposition buttons 1,2,5,6 (buttons which are not in center Y)
        let radius = imageTrustee4.frame.origin.x - buttonHelpMe.frame.origin.x
        let height = radius * sin(NumberUtil.degToRad(60))/UIScreen.mainScreen().scale
        
        constraintNorthHeight.constant = height
        constraintSouthHeight.constant = height
        
        imageViews += [imageTrustee1,imageTrustee2,imageTrustee3,imageTrustee4,imageTrustee5,imageTrustee6]
        
        if let savedNumbers = loadNumbers() {
            numbers += savedNumbers
        }else{
            for _ in 0...5{
                numbers.append("")
            }
        }
        
        updateImageViews(numbers)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: Data
    func loadNumbers() -> [String]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(CircleOfTrustEditViewController.ArchiveURL.path!) as? [String]
    }
    
    func updateImageViews(numbers:[String]){
        for i in 0..<(numbers.count){
            if(numbers[i].characters.count > 0){
                //TODO set images from contacts
            }
        }
    }
    
}
