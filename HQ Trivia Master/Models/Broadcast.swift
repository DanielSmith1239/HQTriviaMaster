//
//  Broadcast.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 2/20/18.
//  Copyright © 2018 Daniel Smith. All rights reserved.
//

import Foundation

struct Broadcast
{
    var socketUrl: URL?
    
    init(socketUrl urlString: String)
    {
        socketUrl = urlString.webSocketUrl
    }
    
    init(_ json: [String: Any])
    {
        if let urlString = json["socketUrl"] as? String
        {
            socketUrl = urlString.webSocketUrl
        }
    }
}
