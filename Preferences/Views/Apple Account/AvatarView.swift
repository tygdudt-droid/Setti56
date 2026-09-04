import SwiftUI

struct AvatarView: View {
    let account: MockAppleAccount
    var size: CGFloat = 60

    var body: some View {
        Group {
            if let data = account.avatarData, let img = UIImage(data: data) {
                Image(uiImage: img).resizable().scaledToFill()
            } else {
                ZStack {
                    LinearGradient(colors: [Color(.systemGray2), Color(.systemGray4)], startPoint: .top, endPoint: .bottom)
                    Text(account.initials)
                        .font(.system(size: size * 0.4, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
