//
//  AppDelegate.swift
//  LocationTracker
//
//  Created by Gokhan Demirer on 4.12.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    
    var locationManager = CLLocationManager()
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    var locationTimer = Timer()
    
    var isFirstRun = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupLocationManager()
        setupTimer()
        
        return true
    }
    
    func setupLocationManager() {
        
        if !CLLocationManager.locationServicesEnabled() {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func setupTimer() {
        locationTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { (_) in
            self.locationManager.startUpdatingLocation()
        })
        
        locationTimer.fire()
    }
    
    func beginBackgroundTask() {
        backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
        })
    }
    
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundUpdateTask)
        backgroundUpdateTask = .invalid
    }
    
    func runBackgroundTask() {
        
        DispatchQueue.main.async {
            self.beginBackgroundTask()

            RunLoop.current.add(self.locationTimer, forMode: RunLoop.Mode.default)
            RunLoop.current.run()

            self.endBackgroundTask()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let navigationController = window?.rootViewController as? UINavigationController, let viewController = navigationController.viewControllers.first as? ViewController, let location = locations.first {
            viewController.recordLocation(location: location)
            
            if !isFirstRun {
                viewController.setRegionToMap(location: location)
                isFirstRun = true
            }
            
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Enter background")
        runBackgroundTask()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "LocationTracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

