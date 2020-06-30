//
//  AppDelegate.swift
//  RealText
//
//  Created by Kyle Southam on 26/06/20.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var populateMenu: NSMenuItem!
    @IBAction func populateMenu(_ sender: Any) {
        ViewController().readDataFromCSV()
    }
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

