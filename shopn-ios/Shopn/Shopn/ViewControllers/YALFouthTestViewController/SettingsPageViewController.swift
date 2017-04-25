//
//  SettingsPageViewController.swift
//  shopn
//
//  Created by Frantzdy romain on 11/19/15.
//  Copyright © 2015 Frantz. All rights reserved.
//

import UIKit
import MessageUI
import Foundation
import CoreLocation


struct SettingsVar {
    static var loginDefaults = NSUserDefaults.standardUserDefaults();
    static var mySwitch = UISwitch(frame:CGRectMake(0, 0, 50, 30));
    static var locationManager = CLLocationManager()
    

}

class SettingsPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate, CLLocationManagerDelegate  {
    
    //let locationManager = CLLocationManager()

    
    @IBOutlet var tableView: UITableView!
    var options: [String] = ["Send Us Feedback", "Read our Privacy Policy"];
    let loginDefaults = NSUserDefaults.standardUserDefaults();
    var useLocation = SettingsVar.loginDefaults.boolForKey("LocationAccessGranted");
    
    //let useLocation = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.scrollEnabled = false
        
        SettingsVar.locationManager.delegate = self
               SettingsVar.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 2 requestWhenInUseAuthorization
        //SettingsVar.locationManager.requestWhenInUseAuthorization()
        SettingsVar.locationManager.startUpdatingLocation()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView(frame: CGRect.zero);
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false);
        self.tabBarController?.selectedIndex = 3;
        
        SettingsVar.locationManager.delegate = self
        SettingsVar.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 2 requestWhenInUseAuthorization
        //SettingsVar.locationManager.requestWhenInUseAuthorization()
        SettingsVar.locationManager.startUpdatingLocation()
        //requestLocation()
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ){
            loginDefaults.setBool(true, forKey: "LocationAccessGranted")
            useLocation = SettingsVar.loginDefaults.boolForKey("LocationAccessGranted");
        
        }
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Restricted){
            loginDefaults.setBool(false, forKey: "LocationAccessGranted")
        }
//        SettingsVar.locationManager.delegate = self
//        SettingsVar.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        // 2 requestWhenInUseAuthorization
//        SettingsVar.locationManager.requestWhenInUseAuthorization()
//        SettingsVar.locationManager.startUpdatingLocation()

        
        [self.tableView .reloadData()]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section==0){
            return self.options.count;
        }else{
            return 1;
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2;
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section==0){
            return "About Us"
        }
        return "";
    };
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 74;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if(indexPath.section==0){
            cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            
            cell.textLabel?.text = self.options[indexPath.row]
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
            
            //return cell;
        }else if(indexPath.section==1){
            //let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            cell?.selectionStyle = UITableViewCellSelectionStyle.None;
            cell.textLabel?.text = "Location"
            cell.accessoryView = SettingsVar.mySwitch;
            if(useLocation){
                SettingsVar.mySwitch.setOn(true, animated: false);
            }else{
                SettingsVar.mySwitch.setOn(false, animated: false);
            }
            SettingsVar.mySwitch.addTarget(self, action:Selector("switchValueDidChange"), forControlEvents: .ValueChanged);
            
            //return cell;
        
        }
        
        
        return cell;
        
    }
    func switchValueDidChange(){
        if(SettingsVar.mySwitch.on){
            //if the switch was switched to on
            NSLog("Switched On");
            if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied ){
                loadMissingLocationDialog()
            }else{
                requestLocation()
            }
            
            //
//            getCityState()
//            getCurrentSeason()
//            loginDefaults.setBool(true, forKey: "LocationAccessGranted")
        }else{
            //switched off
            NSLog("Switched Off");
            turnOffLocationDialog()
            //loginDefaults.setBool(false, forKey: "LocationAccessGranted")
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section==0){
            if indexPath.row == 0{
                print("You selected cell #\(indexPath.row)!")
                
                comPoseMessage()
            }else if indexPath.row == 1 {
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PrivacyViewController") as UIViewController
                self.navigationController?.pushViewController(viewController, animated: false)
                print("You selected cell #\(indexPath.row)!")
            }
        }
        
        
    }
    
    func comPoseMessage(){
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
    let mailComposerVC = MFMailComposeViewController()
    mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
    
    mailComposerVC.setToRecipients(["shopnupdates@gmail.com"])
    mailComposerVC.setSubject("Feedback For Shopn...")
    mailComposerVC.setMessageBody("", isHTML: false)
    
    return mailComposerVC
    }
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func requestLocation(){
        SettingsVar.locationManager = CLLocationManager()
        SettingsVar.locationManager.delegate = self
        SettingsVar.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 2 requestWhenInUseAuthorization
        SettingsVar.locationManager.requestWhenInUseAuthorization()
//        SettingsVar.locationManager.startUpdatingLocation()
    }
    func getCityState(){
        
        SettingsVar.locationManager.startUpdatingLocation()
        
        CLGeocoder().reverseGeocodeLocation(SettingsVar.locationManager.location!) { (placemarks, error) -> Void in
           let pm = placemarks?[0]
            self.loginDefaults.setValue(pm?.locality, forKey: "City")
            self.loginDefaults.setValue(pm?.administrativeArea, forKey: "State")
            NSLog("%@%@", (pm?.locality)!,(pm?.administrativeArea!)!)
            SettingsVar.locationManager.stopUpdatingLocation()
        }
       
    
    }
    func getCurrentSeason(){
        let pm = ProductsViewController()
        pm.getcurrentSeason(true);
    
    }
    func turnOffLocationDialog(){
        let alertController = UIAlertController(title: "Location Services", message: "Looks like you dont want us to use your location. Do you want to Disable it?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction!) in
            NSLog("you have pressed the Cancel button");
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Yes I'm Sure", style: .Default) { (action:UIAlertAction!) in
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
            //SettingsVar.mySwitch.setOn(false, animated: false);
            NSLog("you have pressed OK button");
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion:nil)
        
    }
    func loadMissingLocationDialog(){
        let alertController = UIAlertController(title: "Location Services", message: "Looks like we can't use your location right now. Do you want to enable it?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction!) in
            NSLog("you have pressed the Cancel button");
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK Sure", style: .Default) { (action:UIAlertAction!) in
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
            SettingsVar.mySwitch.setOn(false, animated: false);
            NSLog("you have pressed OK button");
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion:nil)
    
    }
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status{
        
        case CLAuthorizationStatus.Authorized:
            //[self.logindefaults setBool:YES forKey:@"LocationAccessGranted"];
            loginDefaults.setBool(true, forKey: "LocationAccessGranted")
            SettingsVar.mySwitch.setOn(true, animated: false);
            //getCityState()
            getCityState()
            getCurrentSeason()
            break
        case CLAuthorizationStatus.AuthorizedWhenInUse:
            loginDefaults.setBool(true, forKey: "LocationAccessGranted")
            SettingsVar.mySwitch.setOn(true, animated: false);
            //getCityState()
            getCityState()
            getCurrentSeason()
            break
        case CLAuthorizationStatus.Denied:
            //keep switch off
            loginDefaults.setBool(false, forKey: "LocationAccessGranted")
            SettingsVar.mySwitch.setOn(false, animated: false);
            //loadMissingLocationDialog()
            //requestLocation()
            break
        case CLAuthorizationStatus.NotDetermined:
            loginDefaults.setBool(false, forKey: "LocationAccessGranted")
            SettingsVar.mySwitch.setOn(false, animated: false);
            break
            //requestLocation()
            //getCityState()
            //getCurrentSeason()
        
        
            
         
        default:
            loginDefaults.setBool(true, forKey: "LocationAccessGranted")
            //getCityState()
            getCityState()
            getCurrentSeason()
            break
            //getCityState()
        
        
        }
    }

}
