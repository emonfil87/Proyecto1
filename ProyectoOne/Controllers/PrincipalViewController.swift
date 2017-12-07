//
//  PrincipalViewController.swift
//  ProyectoOne
//
//  Created by Erick Monfil on 07/12/17.
//  Copyright © 2017 Blueicon. All rights reserved.
//

import UIKit

class PrincipalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SalirAction(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
