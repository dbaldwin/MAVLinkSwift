//
//  UDPSender.swift
//  MAVLinkSwift
//
//  Created by Dennis Baldwin on 1/28/19.
//  Copyright © 2019 Unmanned Airlines, LLC. All rights reserved.
//

import Foundation
import SwiftSocket

class UDPSender {
    
    var host: String
    var port: Int32
    var sender: UDPClient
    
    init(host: String, port: Int32) {
        self.host = host
        self.port = port
        self.sender = UDPClient(address: self.host, port: self.port)
    }
    
    public func sendData(bytes: [Byte]) {
        sender.send(data: bytes)
    }
    
    public func destroy() {
        
    }
    
}
