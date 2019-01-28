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

    override func viewDidLoad() {
        
        super.viewDidLoad()
        receiver = UDPReceiver(host: "192.168.86.27", port: 14550)
        receiver?.listenForData()
        
    }
    
    private func sendRequest(string: String, using client: UDPClient) {
        
        switch client.send(string: string) {
        case .success:
            print("Success")
            //return readResponse(from: client)
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
        }
        
    }
    
    // Not 100% sure if this is necessary
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        receiver?.destroy()
    }

}
