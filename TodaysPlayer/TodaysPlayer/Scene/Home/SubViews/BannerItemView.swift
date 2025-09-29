import SwiftUI

struct BannerItemView: View {
    let bannerItem: BannerItem
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경 이미지 (사이즈 규격화)
                Image(bannerItem.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: 160)
                    .clipped()
                
                // 할인 태그 (값이 있을 때만)
                if !bannerItem.discountTag.isEmpty {
                    VStack {
                        HStack {
                            Spacer()
                            
                            Text(bannerItem.discountTag)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.trailing, 16)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 16)
                }
            }
        }
    }
}

#Preview {
    BannerItemView(bannerItem: BannerItem(discountTag: "30% OFF", imageName: "HomeBanner1"))
        .frame(width: 200, height: 120)
}
