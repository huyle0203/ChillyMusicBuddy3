import SwiftUI

struct MusicView: View {
    @State private var selectedInput: InputType = .keyboard
    @State private var indicatorOffset: CGFloat = 0
    
    enum InputType: Int, CaseIterable {
        case keyboard, camera, microphone
        
        var icon: String {
            switch self {
            case .keyboard: return "keyboard"
            case .camera: return "camera"
            case .microphone: return "mic"
            }
        }
        
        var color: Color {
            switch self {
            case .keyboard: return Color(hex: "00C0F9")
            case .camera: return Color(hex: "6E60FB")
            case .microphone: return Color(hex: "DC00FE")
            }
        }
    }
    
    private func getNextColor(_ current: InputType) -> Color {
        let allCases = InputType.allCases
        let currentIndex = allCases.firstIndex(of: current)!
        let nextIndex = (currentIndex + 1) % allCases.count
        return allCases[nextIndex].color
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Text("Chilly")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                
                // Input type selector
                ZStack(alignment: .leading) {
                    // Background container
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: InputType.allCases.map { $0.color }),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                        .frame(height: 40)
                    
                    // Sliding indicator
                    RoundedRectangle(cornerRadius: 16)
                        .fill(selectedInput.color.opacity(0.5))
                        .frame(width: 100, height: 32)
                        .padding(.horizontal, 4)
                        .offset(x: indicatorOffset)
                        .animation(.spring(response: 0.3), value: indicatorOffset)
                    
                    // Input type buttons
                    HStack(spacing: 0) {
                        ForEach(InputType.allCases, id: \.self) { type in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedInput = type
                                    indicatorOffset = CGFloat(type.rawValue) * 100
                                }
                            }) {
                                Image(systemName: type.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 40)
                            }
                        }
                    }
                }
                .frame(width: 300)
                
                // Content view switching
                switch selectedInput {
                case .keyboard:
                    KeyboardView(
                        currentColor: selectedInput.color,
                        nextColor: getNextColor(selectedInput)
                    )
                case .camera:
                    CameraView()
                case .microphone:
                    MicrophoneView(
                        currentColor: selectedInput.color,
                        nextColor: getNextColor(selectedInput)
                    )
                }
            }
        }
    }
}

struct MusicView_Previews: PreviewProvider {
    static var previews: some View {
        MusicView()
            .preferredColorScheme(.dark)
    }
}

