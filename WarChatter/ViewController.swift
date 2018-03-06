//
//  ViewController.swift
//  WarChatter
//
//  Created by Reilly Chase on 2/26/18.
//  Copyright © 2018 rchase. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let userDefs = UserDefaults.standard

    @IBOutlet weak var remember: UISwitch!
    @IBOutlet weak var serverPicker: UIPickerView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var server: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var clientPicker: UIPickerView!
    @IBOutlet weak var client: UITextField!
    @IBAction func login(_ sender: Any) {
    }
    let serverOptions = ["server.war2.ru", "backup.war2.ru", "server.war2.me", "backup.war2.me"]
    let clientOptions = ["Warcraft 2", "Warcraft 3 RoC", "Warcraft 3 TFT", "Diablo 1", "Diablo 2", "Diablo 2 LOD", "Starcraft", "Starcraft Broodwar"]
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let serverPickerView = UIPickerView()
        serverPickerView.delegate = self
        serverPickerView.tag = 1
        server.inputView = serverPickerView
        
        let clientPickerView = UIPickerView()
        clientPickerView.delegate = self
        clientPickerView.tag = 2
        client.inputView = clientPickerView
        self.hideKeyboard()
        if userDefs.value(forKey: "username") != nil {
        username.text = userDefs.value(forKey: "username") as! String
        }
        if userDefs.value(forKey: "password") != nil {
            password.text = userDefs.value(forKey: "password") as! String
        }
        if userDefs.value(forKey: "server") != nil {
            server.text = userDefs.value(forKey: "server") as! String
        }
        if userDefs.value(forKey: "client") != nil {
            client.text = userDefs.value(forKey: "client") as! String
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {


        if pickerView.tag == 1 {
            return serverOptions[row]
        } else {
            return clientOptions[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        

        if pickerView.tag == 1 {
            return serverOptions.count
        } else {
            return clientOptions.count
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            server.text = serverOptions[row]
        } else {
            client.text = clientOptions[row]
        }
        self.view.endEditing(true)
        
    }
    override func viewDidLayoutSubviews() {
        serverPicker.subviews[1].isHidden = true
        serverPicker.subviews[2].isHidden = true
        clientPicker.subviews[1].isHidden = true
        clientPicker.subviews[2].isHidden = true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let chatroomController = segue.destination as! ChatroomView
        chatroomController.username = username.text!
        chatroomController.password = password.text!
        chatroomController.server = server.text!
        var clientName = ""
        if client.text! == "Warcraft 2" {
            clientName = "w2bn"
        }
        chatroomController.client = clientName
        
        if remember.isOn {
            self.userDefs.set(chatroomController.username, forKey: "username")
            self.userDefs.set(chatroomController.password, forKey: "password")
            self.userDefs.set(chatroomController.server, forKey: "server")
            self.userDefs.set(chatroomController.client, forKey: "client")
        } else {
            
            self.userDefs.set(nil, forKey: "username")
            self.userDefs.set(nil, forKey: "password")
            self.userDefs.set("server.war2.ru", forKey: "server")
            self.userDefs.set("Warcraft 2", forKey: "client")
        
        }
    }


}
extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

