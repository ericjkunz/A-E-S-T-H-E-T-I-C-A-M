//
//  AppDelegate.swift
//  A E S T H E T I C A M
//
//  Created by Nick Lee on 5/21/16.
//  Copyright © 2016 Nick Lee. All rights reserved.
//

import UIKit
import ADTransitionController
import AVFoundation
import Then
import Obsidian_UI_iOS
import RandomKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties
    
    var window: UIWindow?
    
    // MARK: Private Properties
    
    private let navDelegate = ADNavigationControllerDelegate()
    private let player = (try! AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource("chill", withExtension: "mp3")!)).then {
        $0.numberOfLoops = -1
        $0.volume = 0.1
    }
    
    // MARK: Delegate Methods

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        if let nav = window?.rootViewController as? UINavigationController {
            nav.delegate = navDelegate
            nav.setNavigationBarHidden(true, animated: false)
        }
        
        ImageDownloader.sharedInstance.download()
        
        registerNotifications()
        
        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        player.play()
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        player.pause()
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        registerRandomNotification()
    }
    
    
    // MARK: Notifications

    private func registerNotifications() {
        let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    private func registerRandomNotification() {
        
        for _ in 1...10 {
            let baseDate = UIApplication.sharedApplication().scheduledLocalNotifications?.last?.fireDate ?? NSDate()
            let interval = NSTimeInterval.random(36000...93600)
            let fireDate = baseDate.dateByAddingTimeInterval(interval)
            let note = UILocalNotification()
            note.soundName = "push.aiff"
            note.fireDate = fireDate
            note.alertTitle = "YOu gotta"
            note.alertBody = "Create your A E S T H E T I C"
            UIApplication.sharedApplication().scheduleLocalNotification(note)
            print("Scheduled notification for", fireDate)
        }
        
        
    }
    
}

