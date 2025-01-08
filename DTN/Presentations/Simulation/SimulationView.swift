import SwiftUI

struct SimulationView: View {
    @State private var viewModel = SimulationViewModel(in: UIScreen.main.bounds.size)

    var body: some View {
        ZStack {
            ForEach(viewModel.links) { link in
                LineView(start: link.dot1.position, end: link.dot2.position)
            }

            ForEach(viewModel.dots) { dot in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 20, height: 20)
                    .position(dot.position)
            }

            ForEach(viewModel.messages) { message in
                Circle()
                    .fill(message.isReceived ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                    .position(message.currentPosition)
            }
            
            VStack {
                HStack {
                    VStack {
                        Stepper("Dots \(viewModel.dotCount)", value: $viewModel.dotCount)
                        Stepper("Messages \(viewModel.messageCount)", value: $viewModel.messageCount)
                    }
                    Spacer()
                    Button {
                        viewModel.setupRandomDotsAndLinks(in: UIScreen.main.bounds.size)
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
                .padding()
                Spacer()
            }
        }
    }
}
