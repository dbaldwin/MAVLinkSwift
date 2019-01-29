//
//  ViewController.swift
//  MAVLinkSwift
//
//  Created by Dennis Baldwin on 1/27/19.
//  Copyright © 2019 Unmanned Airlines, LLC. All rights reserved.
//

import UIKit
import SwiftSocket
import Mavlink

class ViewController: UIViewController {
    
    var receiver: UDPReceiver?
    var sender: UDPSender?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.receiver = UDPReceiver(host: "192.168.86.27", port: 14550)
        //self.receiver = UDPReceiver(host: "127.0.0.1", port: 33333)
        self.receiver?.listenForData()
        
        // Rosetta Drone running on Android
        
        // Node JS simulator on MacBook
        self.sender = UDPSender(host: "127.0.0.1", port: 33333)
        
    }
    
    // Not 100% sure if this is necessary
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        receiver?.destroy()
        sender?.destroy()
    }
    
    
    @IBAction func armDrone(_ sender: Any) {
    
        var message = mavlink_message_t()
        let len = mavlink_msg_heartbeat_pack(1, 1, &message, 2, 3, 65, 4, 4)
        
        let buff: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer.allocate(capacity: Int(len))
        mavlink_msg_to_send_buffer(buff, &message)
        
        print(message)
        print(buff)
        print(len)
        
        let bytes = Array(UnsafeBufferPointer(start: buff, count: Int(len)))
        self.sender?.sendData(bytes: bytes)
        
        
    }
    
}
