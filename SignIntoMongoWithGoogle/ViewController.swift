//
//  ViewController.swift
//  SignIntoMongoWithGoogle
//
//  Created by Daniel Nzioka on 6/6/20.
//  Copyright © 2020 Daniel Nzioka. All rights reserved.
//

import UIKit
import GoogleSignIn
import StitchCore
import MongoSwift
import StitchRemoteMongoDBService

class ViewController: UIViewController, GIDSignInDelegate {
    
    
    @IBAction func signIn(_ sender: Any){
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    //Register your sign-in screen's view controller with the shared GIDSignIn object
    private func googleSignIn(){
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("The user has not signed in before or they have since signed out.")
          } else {
            print("\(error.localizedDescription)")
          }
          return
        }
        
        let googleCredential = GoogleCredential.init(withAuthCode: user.serverAuthCode)
        stitch.auth.login(withCredential: googleCredential) { result in
            switch result {
            case .success:
                print("Successfully Signed In!")
            case .failure(let error):
                print("failed logging in Stitch with Google. error: \(error)")
                GIDSignIn.sharedInstance().signOut()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        googleSignIn()
    }

    //See Simone Hutsch's work
    @IBAction func photographerLink(_ sender: Any){
        if let url = URL(string: "https://unsplash.com/@heysupersimi") {
            UIApplication.shared.open(url)
        }
    }

}

