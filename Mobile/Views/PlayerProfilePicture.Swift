import SwiftUI

struct PlayerProfilePicture: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.gray.opacity(0.2))
            .frame(width: 80, height: 80)
            .overlay {
                Image(systemName: "person.fill") // Default placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(20)
                    .foregroundColor(.gray)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    PlayerProfilePicture()
}
