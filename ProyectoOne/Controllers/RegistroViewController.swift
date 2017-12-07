//
//  RegistroViewController.swift
//  ProyectoOne
//
//  Created by Erick Monfil on 07/12/17.
//  Copyright © 2017 Blueicon. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
class RegistroViewController: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable {
    @IBOutlet weak var btnRegistro: UIButton!
    @IBOutlet weak var vistaNombre: UIView!
    @IBOutlet weak var vistaCorreo: UIView!
    @IBOutlet weak var vistaContrasena: UIView!
    @IBOutlet weak var vistaContrasena2: UIView!
    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    @IBOutlet weak var txtContrasena2: UITextField!
    
    var correo :String = ""
    var nombre : String = ""
    var contrasena :String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func style(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        
        txtNombre.delegate = self
        txtCorreo.delegate = self
        txtContrasena.delegate = self
        txtContrasena2.delegate = self
        
        let logo = #imageLiteral(resourceName: "logo")
        let imageView = UIImageView(image:logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
        btnRegistro.layer.cornerRadius = 15
        
        vistaCorreo.backgroundColor = UIColor.clear
        vistaCorreo.layer.borderColor = Constans.colores.colorBorde.cgColor
        vistaCorreo.layer.borderWidth = 2
        
        vistaNombre.backgroundColor = UIColor.clear
        vistaNombre.layer.borderColor = Constans.colores.colorBorde.cgColor
        vistaNombre.layer.borderWidth = 2
        
        vistaContrasena.backgroundColor = UIColor.clear
        vistaContrasena.layer.borderColor = Constans.colores.colorBorde.cgColor
        vistaContrasena.layer.borderWidth = 2
        
        vistaContrasena2.backgroundColor = UIColor.clear
        vistaContrasena2.layer.borderColor = Constans.colores.colorBorde.cgColor
        vistaContrasena2.layer.borderWidth = 2
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegistroViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
    @IBAction func RegistroAction(_ sender: UIButton) {
        if txtCorreo.text == "" || txtContrasena.text == "" || txtContrasena2.text == "" || txtNombre.text == "" {
            showMessage("Faltan datos.")
            return
        }
        self.nombre = txtNombre.text!
        self.correo = txtCorreo.text!
        if !isValidEmail(self.correo){
            showMessage("El correo no es valido.")
            return
        }
        if txtContrasena.text != txtContrasena2.text {
            showMessage("Las contraseñas no coinciden")
            return
        }
        self.contrasena = txtContrasena.text!
        registraUsuarioService()
    }
    
    func showMessage(_ mensaje : String){
        let alert = UIAlertController(title: "", message: "\(mensaje)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    func registraUsuarioService(){
        let parametersObj : [String : Any] = [
            "nombre": "\(self.nombre)",
            "correo": "\(self.correo)",
            "contrasena":"\(self.contrasena)"
        ]
        self.startAnimating(Constans.LoadingConfig.size, type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor.yellow)
        Alamofire.request("https://hrapedidos.herokuapp.com/api/v1/creaUsuario", method: .post, parameters: parametersObj)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        print("Ok")
                        var resultado = [] as AnyObject
                        if let JSON = response.result.value{
                            print("JSON: \(JSON)")
                            resultado = JSON as AnyObject
                        }
                        let resp : Bool = resultado["response"] as! Bool
                        if resp == true {
                            DispatchQueue.main.async(execute: {
                                self.stopAnimating()
                            })
                            self.txtContrasena.text = ""
                            self.txtCorreo.text = ""
                            self.txtNombre.text = ""
                            self.txtContrasena2.text = ""
                            self.performSegue(withIdentifier: "sendToPrincipal2", sender: nil)
                        }
                        else{
                            let mensaje :String = resultado["message"] as! String
                            self.showMessage(mensaje)
                            DispatchQueue.main.async(execute: {
                                self.stopAnimating()
                            })
                        }
                    }
                    break
                case .failure(_):
                    print("Error")
                    self.showMessage("Ocurrio un error al intentar ingresar")
                    break
                    
                }
                
                
        }
    }
}
