//
//  ViewController.swift
//  gst_test1
//
//  Created by Lazar Mladenovic on 12/28/17.
//  Copyright © 2017 Lazar Mladenovic. All rights reserved.
//

import UIKit
import Alamofire

enum ViewStateType {
    case UP
    case CENTER
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

class ViewController: UIViewController, GStreamerBackendDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var serverURL: UITextField!
    
    @IBOutlet weak var videoView: UIView!
    
    var gstBackend: GStreamerBackend?
    var viewState: ViewStateType = .CENTER
    
    @IBAction func play(_ sender: Any) {
        makeGetCallWithAlamofire()
        
        gstBackend?.play()
    }
    
    @IBAction func stop(_ sender: Any) {
        gstBackend?.pause()
    }
    
    func gstreamerInitialized() {
        DispatchQueue.main.async {
            self.playButton.isEnabled = true
            self.stopButton.isEnabled = true
            self.label.text = "READY! :)"
        }
    }
    
    func gstreamerSetUIMessage(message: String) {
        DispatchQueue.main.async {
            self.label.text = message
        }
    }
    
    func makeGetCallWithAlamofire() {
        if let streamingServerURL: String = serverURL.text {
            Alamofire.request(streamingServerURL)
                .responseJSON { response in
                    // check for errors
                    guard response.result.error == nil else {
                        // got an error in getting the data, need to handle it
                        print("error calling GET on ", streamingServerURL)
                        print(response.result.error!)
                        return
                    }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serverURL.placeholder = "ServerURL"
        serverURL.text = "http://172.17.168.12:3000"
        serverURL.returnKeyType = .done
        serverURL.delegate = self
        
        gstBackend = GStreamerBackend.createGStreamerBackend(self, videoView: self.videoView)
        
        //label.text = gstBackend?.getGStreamerVersion()
        playButton.isEnabled = false
        stopButton.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard viewState == .CENTER else {
            return
        }
        
        guard UIDevice().screenType == .iPhone5 else { return }
        
        if self.view.bounds.origin.y != 0.0 { return }
        
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        
        let rawFrame = value.cgRectValue
        let keyboardFrame = view.convert(rawFrame!, from: nil)
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.bounds.origin.y += keyboardFrame.size.height * 0.3
        })
        
        viewState = .UP
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard viewState == .UP else {
            return
        }
        
        let info  = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]! as AnyObject
        
        let rawFrame = value.cgRectValue
        let keyboardFrame = view.convert(rawFrame!, from: nil)
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.bounds.origin.y -= keyboardFrame.size.height * 0.3
        })
        
        viewState = .CENTER
    }
    

}

