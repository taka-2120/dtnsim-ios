//
//  Message.swift
//  DTN
//
//  Created by Yu Takahashi on 12/18/24.
//

import Foundation

struct Message: Identifiable {
    let id = UUID()
    var currentPosition: CGPoint
    var start: Dot
    var destination: Dot
    var difference: CGPoint
    var isMoving: Bool
    var isReceived: Bool
    var timer: Timer?
    
    init(from start: Dot, to destination: Dot, sender: Bool = false) {
        currentPosition = start.position
        self.start = start
        self.destination = destination
        isMoving = true
        isReceived = sender
        
        var slope = (destination.position.y - start.position.y) / (destination.position.x - start.position.x)
        if destination.position.y < start.position.y && 0 < slope {
            slope *= -1
        }
        if start.position.y < destination.position.y && slope < 0 {
            slope *= -1
        }
        let dx = Constant.speed * cos(atan(slope)) * (destination.position.x < start.position.x ? -1 : 1)
        let dy = Constant.speed * sin(atan(slope))
        difference = .init(x: dx, y: dy)
    }
}

extension Message {
    func isAround(of point: CGPoint) -> Bool {
        let threshold: CGPoint = .init(x: Constant.speed * abs(self.difference.x) / 2, y: Constant.speed * abs(self.difference.y) / 2)
        return (point.x - threshold.x < self.currentPosition.x && self.currentPosition.x < point.x + threshold.x)
        &&
        (point.y - threshold.y < self.currentPosition.y && self.currentPosition.y < point.y + threshold.y)
    }
    
    func isDotNearby(from messages: [Message]) -> Bool {
        let messagesOnSameLine = messages.filter({ $0.start.id == self.destination.id && $0.destination.id == self.start.id })
        for message in messagesOnSameLine {
            if self.isAround(of: message.currentPosition) && message.isReceived == true {
                return true
            }
        }
        return false
    }
}
