//
//  LoginViewController.swift
//  ARKit+CoreLocation
//
//  Created by Bobby Ren on 4/14/18.
//  Copyright © 2018 Project Dent. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    let gradientLayer = CAGradientLayer()
    
    @IBOutlet weak var inputSession: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colors = [UIColor(red: 150/255.0, green: 0, blue: 0, alpha: 1.0).cgColor, UIColor(red: 1, green: 0, blue: 0, alpha: 1.0).cgColor]
        gradientLayer.frame = self.view.frame
        gradientLayer.colors = colors
        gradientLayer.locations = [0.0,1.0]
        self.view.layer.addSublayer(gradientLayer)
        
        for subview in self.view.subviews {
            view.bringSubview(toFront: subview)
        }
        
        if let id = UserDefaults.standard.value(forKey: "DefaultSessionId") as? String {
            inputSession.text = id
        }
    }

    @IBAction func didClick(_ sender: Any) {
        guard let id = inputSession.text, !id.isEmpty else { return }
        UserDefaults.standard.set(id, forKey: "DefaultSessionId")
        UserDefaults.standard.synchronize()
        performSegue(withIdentifier: "toSetup", sender: id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? SetupViewController else { return }
        guard let id = sender as? String else { return }
        controller.sessionId = id
    }
}
