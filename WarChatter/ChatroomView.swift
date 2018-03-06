//
//  ChatroomView.swift
//  WarChatter
//
//  Created by Reilly Chase on 2/28/18.
//  Copyright © 2018 rchase. All rights reserved.
//

import UIKit
import SwiftSocket

class ChatroomView: UIViewController, UITextFieldDelegate {
    var password: String!
    var server: String!
    var username: String!
    var client: String!
    var channel: String!
    var talk: String!


    lazy var host = server
    let port = 6112
    
    var loop = "go"



    @IBAction func ChatroomMenu(_ sender: Any) {
        // 1
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 2
        let joinChannelAction = UIAlertAction(title: "Join a Channel", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("File Deleted")
            //1. Create the alert controller.
            let alert = UIAlertController(title: "Join a Channel", message: "Enter channel name", preferredStyle: .alert)
            
            //2. Add the text field. You can configure it however you need.
            alert.addTextField { (textField) in
                textField.text = ""
            }
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
                self.cxn!.send(string: "/join " + textField.text! + "\r\n")
            }))
            
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
        })
        let listChannelsAction = UIAlertAction(title: "Channels", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.cxn!.send(string: "/channels " + self.client + "\r\n")
            print("File Saved")
        })
        let viewGamesAction = UIAlertAction(title: "Games", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.cxn!.send(string: "/games " + self.client + "\r\n")
            
            print("File Saved")
        })
     
        let friendsOnlineAction = UIAlertAction(title: "Friends", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("File Saved")
            self.cxn!.send(string: "/f o\r\n")
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(joinChannelAction)
        optionMenu.addAction(listChannelsAction)
        optionMenu.addAction(viewGamesAction)
        optionMenu.addAction(friendsOnlineAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
    }
    @IBAction func returnPressed(_ sender: UITextField) {
        print("YOOOOOO")
        print(self.SendMessage.text!)
        cxn!.send(string: self.SendMessage.text! + "\r\n")
        self.talk = self.talk + "<" + self.username + "> "
        self.talk = self.talk + self.SendMessage.text!
        self.talk = self.talk + "\r\n"
        print(self.talk)
        DispatchQueue.main.async {
            self.ChatroomText.text = self.talk
            var bottom = NSMakeRange(self.ChatroomText.text.characters.count - 1, 1)
            self.ChatroomText.scrollRangeToVisible(bottom)
            self.SendMessage.text = ""
        }
        
        
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ChatroomUsers: UIBarButtonItem!
    @IBOutlet weak var ChatroomLogout: UIBarButtonItem!
    @IBOutlet weak var ChatroomNav: UINavigationBar!
    @IBOutlet weak var SendMessage: UITextField!
    @IBOutlet weak var ChatroomText: UITextView!
    func viewDidAppear(_animated: Bool) {
        super.viewDidAppear(_animated)
        print("loaded")
        // Do any additional setup after loading the view.
    }
    var cxn: TCPClient?
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LOADEDEDEDEDEDEDEDEDEDEDEDEDEDED")
        cxn = TCPClient(address: server, port: 6112)
        guard let cxn = cxn else { return }
        
        talk = ""
        if server == "server.war2.ru" {
            channel = "War2BNE"
        } else if server == "backup.war2.ru" {
            channel = "War2BNE"
        } else if server == "server.war2.me" {
            channel = "War2BNE"
        } else if server == "backup.war2.me" {
            channel = "War2BNE"
        } else {
            channel = "chat"
        }
        switch cxn.connect(timeout: 1) {
        case .success:
            cxn.send(string: "\r\n")
            cxn.send(string: username)
            cxn.send(string: "\r\n")
            cxn.send(string: password)
            cxn.send(string: "\r\n")
            cxn.send(string: "/join " + channel + "\r\n")

            DispatchQueue.global(qos: .background).async {
                
                while self.loop == "go" {
                    print("RAN")
                    guard var data = cxn.read(1024*10, timeout: 1) else { continue }
                    if var response = String(bytes: data, encoding: .utf8) {
                        self.talk = self.talk + response
                        print(self.talk)
                        DispatchQueue.main.async {
                            self.ChatroomText.text = self.talk
                            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
                            self.scrollView.setContentOffset(bottomOffset, animated: true)
                        }
                    }
                    sleep(1)
                }
                
            }
            
        case .failure(let error):
            print(error)// 💩
        }
        
        

        self.hideKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatroomView.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatroomView.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {

            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier)
        if (segue.identifier == "Main") {
            
            print("Logging out....")
            guard let cxn = cxn else { return }
            loop = "stop"
            print("loopp")
            print(loop)
            cxn.close()
            
            // Put your code here or call onLogoutClick(null)
        }
    }
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

