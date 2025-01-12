//
//  SimulationViewModel.swift
//  DTN
//
//  Created by Yu Takahashi on 12/18/24.
//

import SwiftUI

@Observable
class SimulationViewModel {
    var dotCount = 5
    var messageCount = 2
    var dots = [Dot]()
    var links = [Link]()
    var messages = [Message]()
    var timer: Timer?
    var areAllMessagesReceived: Bool {
        messages.filter { $0.isReceived }.count == messageCount
    }

    var totalTimeUntilAllMessagesReceived: Double = 0

    init(in size: CGSize) {
        setupRandomDotsAndLinks(in: size)
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    func setupRandomDotsAndLinks(in size: CGSize) {
        dots.removeAll()
        links.removeAll()
        for message in messages {
            message.timer?.invalidate()
        }
        messages.removeAll()

        for _ in 0 ..< dotCount {
            var randomPosition: CGPoint = .zero
            var isDotNearby = true
            while isDotNearby {
                randomPosition = .init(x: CGFloat.random(in: 50 ... (size.width - 50)), y: CGFloat.random(in: 50 ... (size.height - 100)))
                if dots.filter({
                    ($0.position.x - 50 < randomPosition.x && randomPosition.x < $0.position.x + 50)
                        &&
                        ($0.position.y - 50 < randomPosition.y && randomPosition.y < $0.position.y + 50)
                }).isEmpty {
                    isDotNearby = false
                }
            }
            dots.append(Dot(at: randomPosition))
        }

        for i in 0 ..< dots.count {
            let start = dots[i]
            let end = dots[(i + 1) % dots.count]
            links.append(Link(dot1: start, dot2: end))
        }

        var messageIndex = 0
        while messageIndex < messageCount {
            guard let dot = dots.randomElement() else { continue }
            guard messages.filter({ $0.id == dot.id }).isEmpty else { continue }
            addMessage(at: dot, sender: messageIndex == 0)
            messageIndex += 1
        }

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
            if self.areAllMessagesReceived {
                self.timer?.invalidate()
                self.timer = nil
                return
            }
            self.totalTimeUntilAllMessagesReceived += 0.5
        })
        timer?.fire()
    }

    private func addMessage(at dot: Dot, sender: Bool = false) {
        guard let link = links.filter({ $0.dot1.id == dot.id || $0.dot2.id == dot.id }).randomElement() else { fatalError() }
        let nextDot = link.dot1.id == dot.id ? link.dot2 : link.dot1

        let newMessage = Message(from: dot, to: nextDot, sender: sender)
        messages.append(newMessage)
        startMovingMessage(for: newMessage)
    }

    private func calculateDifference(for message: Message) -> CGPoint {
        var slope = (message.destination.position.y - message.start.position.y) / (message.destination.position.x - message.start.position.x)
        if message.destination.position.y < message.start.position.y && slope > 0 || message.start.position.y < message.destination.position.y && slope < 0 {
            slope *= -1
        }
        let dx = Constant.speed * cos(atan(slope)) * (message.destination.position.x < message.start.position.x ? -1 : 1)
        let dy = Constant.speed * sin(atan(slope))
        return .init(x: dx, y: dy)
    }

    private func startMovingMessage(for message: Message) {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { fatalError() }

        messages[index].timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            let message = self.messages[index]

            if !message.isMoving, message.difference == .zero {
                guard let link = self.links.filter({ $0.dot1.id == message.start.id || $0.dot2.id == message.start.id }).randomElement() else { fatalError() }
                self.messages[index].destination = link.dot1.id == message.start.id ? link.dot2 : link.dot1

                self.messages[index].difference = self.calculateDifference(for: self.messages[index])
                self.messages[index].isMoving = true
            }

            self.messages[index].currentPosition = CGPoint(
                x: message.currentPosition.x + message.difference.x,
                y: message.currentPosition.y + message.difference.y
            )

            if self.messages[index].isDotNearby(from: self.messages) {
                self.messages[index].isReceived = true
            }

            if message.isAround(of: message.destination.position) {
                self.messages[index].isMoving = false
                self.messages[index].difference = .zero
                self.messages[index].start = message.destination
                self.messages[index].currentPosition = message.destination.position
            }
        }
        messages[index].timer?.fire()
    }
}
