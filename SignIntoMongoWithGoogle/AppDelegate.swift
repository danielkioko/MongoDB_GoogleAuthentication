//
//  AppDelegate.swift
//  SignIntoMongoWithGoogle
//
//  Created by Daniel Nzioka on 6/6/20.
//  Copyright © 2020 Daniel Nzioka. All rights reserved.
//

import UIKit
import CoreData
import StitchCore
import StitchRemoteMongoDBService
import GoogleSignIn

let stitch = try! Stitch.initializeAppClient(withClientAppID: "Your app id here")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Register your GIDSignInDelegate & configure Google Sign-in with your client ID:
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        GIDSignIn.sharedInstance()?.clientID = "Google Client ID goes here"
        GIDSignIn.sharedInstance()?.serverClientID = "Google Server client ID goes here"
        
        return true
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("error received when logging in with Google: \(error.localizedDescription)")
        } else {
            
            switch user.serverAuthCode {
            case .some:
                let googleCredential = GoogleCredential.init(withAuthCode: user.serverAuthCode)
                //Send the credentials to Stitch
                stitch.auth.login(withCredential: googleCredential) { result in
                    switch result {
                    case .success:
                        print("successfully signed in with Google")
                        NotificationCenter.default.post(name: Notification.Name("OAUTH_SIGN_IN"), object: nil, userInfo: nil)
                    case .failure(let error):
                        print("failed logging in Stitch with Google. error: \(error)")
                        GIDSignIn.sharedInstance().signOut()
                    }
                }
            case .none:
                print("serverAuthCode not retreived")
                GIDSignIn.sharedInstance()?.signOut()
            }
            
        }
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "SignIntoMongoWithGoogle")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

