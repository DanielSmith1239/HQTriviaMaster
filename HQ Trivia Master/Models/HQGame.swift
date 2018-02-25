//
//  HQGame.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 2/20/18.
//  Copyright © 2018 Daniel Smith. All rights reserved.
//

import Foundation

struct HQGame
{
    var active: Bool
    var prize: String?
    var broadcast: Broadcast?
    
    init(isActive _active: Bool, gamePrize _prize: String?, gameBroadcast _broadcast: Broadcast)
    {
        active = _active
        prize = _prize
        broadcast = _broadcast
    }
    
    init(_ json: [String: Any])
    {
        active = json["active"] as? Bool ?? false
        prize = json["prize"] as? String
        
        if let gameBroadcast = json["broadcast"] as? [String: Any]
        {
            broadcast = Broadcast(gameBroadcast)
        }
    }
}
