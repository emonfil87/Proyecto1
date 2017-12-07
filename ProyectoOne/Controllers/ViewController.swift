//
//  ViewController.swift
//  ProyectoOne
//
//  Created by Erick Monfil on 06/12/17.
//  Copyright © 2017 Blueicon. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import FBSDKLoginKit
import FacebookLogin
import FacebookCore

class ViewController: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable {
    
    let screenSize: CGRect = UIScreen.main.bounds
    let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
    
    @IBOutlet weak var vistaCorreo: UIView!
    @IBOutlet weak var vistaContrasena: UIView!
    @IBOutlet weak var vistaFacebook: UIView!
    @IBOutlet weak var btnIngresar: UIButton!
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtContrasena: UITextField!
    @IBOutlet weak var topControls: NSLayoutConstraint!
    @IBOutlet weak var topBtningresar: NSLayoutConstraint!
    
    var usuario : String = ""
    var clave : String = ""
    var dict : [String : AnyObject]!
    var idFacebook : String = ""
    var email = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.stylyle()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stylyle(){
        txtCorreo.delegate = self
        txtContrasena.delegate = self
        vistaCorreo.backgroundColor = UIColor.clear
        vistaCorreo.layer.borderColor = Constans.colores.colorBorde.cgColor
        vistaCorreo.layer.borderWidth = 2
        vistaContrasena.backgroundColor = UIColor.clear
        vistaContrasena.layer.borderColor = Constans.colores.colorBorde.cgColor
        vistaContrasena.layer.borderWidth = 2
        vistaFacebook.backgroundColor = UIColor.clear
        btnIngresar.layer.cornerRadius = 15
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        var identificador :String = ""
        
        let screenHeight = screenSize.height
        if screenHeight == 568 { //iphone 5
            topControls.constant = 150
            topBtningresar.constant = 30
        }
        if screenHeight == 667 { // iphone 6
            topControls.constant = 150
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
    @IBAction func IngresarAction(_ sender: UIButton) {
        if txtCorreo.text == "" || txtContrasena.text == "" {
            showMessage("Faltan datos.")
            return
        }
        self.usuario = txtCorreo.text!
        if !isValidEmail(self.usuario){
            showMessage("El correo no es valido.")
            return
        }
        self.clave = txtContrasena.text!
        
        
        let parametersObj : [String : Any] = [
            "correo": "\(usuario)",
            "contrasena": "\(clave)"
        ]
        self.LoginService(parameters: parametersObj)
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

    @IBAction func LofinFacebookAction(_ sender: UIButton) {
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_birthday"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData(tokenFaceBook: "\(fbloginresult.token!.tokenString!)")
                        self.fbLoginManager.logOut()
                    }
                    else {
                        self.showMessage("Esta aplicación requiere todos los permisos indicados (E-mail y fecha de nacimiento).")
                    }
                }
                else {
                    print("error login face 2")
                    self.showMessage("Esta aplicación requiere todos los permisos indicados (E-mail y fecha de nacimiento).")
                }
            }
            else {
                print("error login facebook-> \(error)")
            }
        }
    }
    
    func getFBUserData(tokenFaceBook : String){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, age_range, gender"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    
                    self.dict = result as! [String : AnyObject]
                    print(result!)
                    self.idFacebook = self.dict["id"] as! String
                    self.email = self.dict["email"] as! String
                    
                    let parametersObj : [String : Any] = [
                        "nombre": "\(self.dict["first_name"] as! String)",
                        "correo": "\(self.dict["email"] as! String)",
                        "facebook" : "\(self.idFacebook)"
                    ]
                    print(parametersObj)
                    self.loginFaccebookService(obj: parametersObj)
                }else{
                    print("eror login face")
                }
            })
        }
    }
    
    func LoginService(parameters : [String : Any]){
        self.startAnimating(Constans.LoadingConfig.size, type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor.yellow)
        Alamofire.request("https://hrapedidos.herokuapp.com/api/v1/loginUsuario", method: .post, parameters: parameters)
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
                            self.txtContrasena.text == ""
                            self.txtCorreo.text = ""
                            self.performSegue(withIdentifier: "sendToPrincipal", sender: nil)
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
    
    func loginFaccebookService(obj : [String : Any]){
        self.startAnimating(Constans.LoadingConfig.size, type: NVActivityIndicatorType.ballSpinFadeLoader, color: UIColor.yellow)
        Alamofire.request("https://hrapedidos.herokuapp.com/api/v1/loginUsuarioFacebook", method: .post, parameters: obj)
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
                            self.performSegue(withIdentifier: "sendToPrincipal", sender: nil)
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

