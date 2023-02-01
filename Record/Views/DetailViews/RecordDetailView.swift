//
//  RecordDetailView.swift
//  Recorder
//
//  Created by 김보승 on 2022/06/13.
//


import SwiftUI
import CoreData
import LinkPresentation

struct RecordDetailView: View {
    
    //coredata 관련 변수
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    
    let item: Content
    
    @State private var photo = false
    @State private var story = false
    @State private var deleteItemAlert = false // delete item alert
    @State private var saveImage = false
    @State private var clickEdit = false {
        willSet {
            UIView.setAnimationsEnabled(true)
        } didSet {
            DispatchQueue.main.async {
                UIView.setAnimationsEnabled(true)
            }
        }
    }
    
    var body: some View {
        
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            
            Image("backwindow")
                .padding(.leading, UIScreen.getWidth(90))
            
            VStack {
                // MARK: 노래 정보
                VStack(alignment: .leading, spacing: UIScreen.getHeight(10)) {
                    Text(item.title ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.titleBlack)
                        .multilineTextAlignment(.leading)
                    Text(item.artist ?? "")
                        .font(.customBody1())
                        .fontWeight(.regular)
                        .foregroundColor(.titleDarkgray)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.leading, UIScreen.getWidth(35))
                .padding(.top, UIScreen.getHeight(15))
                
                
                ZStack {
                    VStack(spacing: 40) {
                        
                        // MARK: - 가사
                        ZStack {
                            Image("LylicComp")
                            
                            Text(item.lyrics ?? "")
                                .foregroundColor(.titleDarkgray)
                                .font(.customBody2())
                                .frame(width: UIScreen.getWidth(240), alignment: .center)
                        }
                        
                        // MARK: CD Player
                        HStack {
                            Spacer()
                            CDPlayerComp(music: Music(artist: item.artist ?? "", title: item.title ?? "", albumArt: item.albumArt ?? ""))
                        }
                    }
                    
                    ZStack {
                        HStack {
                            VStack(spacing: UIScreen.getHeight(60)) {
                                
                                // MARK: Image
                                ZStack {
                                    Image("DetailPhotoComp") // 이미지 삽입
                                        .fullScreenCover(isPresented: $photo, onDismiss: { photo = false }, content: { PhotoModalView(image: item.image!) } )
                                    
                                    if let image = item.image {
                                        Image(uiImage: UIImage(data: image)!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 95, height: 105)
                                            .clipped()
                                            .scaleEffect()
                                            .offset(y: UIScreen.getHeight(-15))
                                    }
                                }
                                .onTapGesture {
                                    photo.toggle()
                                    UIView.setAnimationsEnabled(false)
                                }
                                .padding(.top, UIScreen.getHeight(30))
                                
                                // MARK: Story
                                ZStack {
                                    
                                    Image("StoryComp")
                                    
                                    Text(item.story ?? "")
                                        .font(Font.customBody2())
                                        .foregroundColor(.titleDarkgray)
                                        .lineLimit(5)
                                        .truncationMode(.tail)
                                        .multilineTextAlignment(.leading)
                                        .lineSpacing(5)
                                        .frame(width: UIScreen.getWidth(130))
                                }
                                .onTapGesture {
                                    story.toggle()
                                    UIView.setAnimationsEnabled(false)
                                }
                                .fullScreenCover(isPresented: $story, onDismiss: { story = false }, content: { StoryModalView(content: item.story!) } )
                                .fixedSize()
                                .offset(x: UIScreen.getWidth(62))
                            }
                            Spacer()
                        }
                        .padding(.top, UIScreen.getHeight(150))
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .topLeading)
        }
        .navigationBarItems(trailing: Menu(content: {
            
            Button(action: { // MARK: 편집 기능
                clickEdit.toggle()
            }) {
                Label("편집", systemImage: "square.and.pencil")
            }
            
            // MARK: 이미지 저장 기능
            Button(action: {
                actionSheet()
            }) { Label("이미지 공유", systemImage: "square.and.arrow.up") }
            
            // MARK: 삭제 기능
            Button(role: .destructive, action: {
                deleteItemAlert = true
            }, label: {Label("제거", systemImage: "trash")})
            
        }
                                           , label: {
            Image(systemName: "ellipsis")
                .padding(.vertical, 10)
                .foregroundColor(.pointBlue)
        }))// Menu 목록 End
        .fullScreenCover(isPresented: $clickEdit) {
            NavigationView {
                WriteView(music: Music(artist: item.artist!, title: item.title!, albumArt: item.albumArt!), isWrite: .constant(false) ,isEdit: .constant(true), item: item)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .alert("삭제", isPresented: $deleteItemAlert) {
            Button("삭제", role: .destructive) {
                PersistenceController.shared.deleteContent(item: item)
                presentation.wrappedValue.dismiss()
            }
        } message: { Text("정말 삭제하시겠습니까?") }
        // 본문 ZStack End
            .alert("저장완료", isPresented: $saveImage) {
                Button("확인") {
                }
            } message: {  }
        // 본문 ZStack End
        
        
    }
    func actionSheet() {
        let shareImage = self.snapShot()
        let activityItemMetadata = MyActivityItemSource(text: "\(item.title!) - \(item.artist!)" , image: shareImage)
        let activitiViewController = UIActivityViewController(activityItems: [activityItemMetadata, shareImage], applicationActivities: nil)
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        windowScene?.windows.first?.rootViewController?.present(activitiViewController, animated: true, completion: nil)
    }
    
}


struct CDPlayerComp: View {
    
    let music: Music
    @State private var angle = 0.0
    var body: some View {
        ZStack {
            Image("CdPlayer")
                .padding(.trailing, 20.0)
            
            ZStack(alignment: .center) {
                Image(uiImage: getImage())
                    .resizable()
                    .frame(width: 200, height: 200)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .scaleEffect(0.46)
                    .rotationEffect(.degrees(self.angle))
                    .animation(.timingCurve(0, 0.8, 0.2, 1, duration: 10), value: angle)
                    .onTapGesture {
                        self.angle += Double.random(in: 3600..<3960)
                    } // albumArt를 불러오는 URLImage
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.background)
                    .overlay(
                        Circle()
                            .stroke(.background, lineWidth: 0.1)
                            .shadow(color: .titleDarkgray, radius: 2, x: 3, y: 3)
                    )
            }.offset(x: -10.6, y: -133) // albumArt를 CD모양으로 불러오는 ZStack
            
            ZStack {
                Circle()
                    .foregroundColor(.titleLightgray)
                    .frame(width: 30 , height: 30)
                Circle()
                    .foregroundColor(.titleDarkgray)
                    .frame(width: 15 , height: 15)
                    .shadow(color: Color(.gray), radius: 4, x: 0, y: 4)
                Circle()
                    .foregroundColor(.background)
                    .frame(width: 3 , height: 3)
            }.offset(x: -10.6, y: -133)
            
        }// ZStack End
    }
    func getImage() -> UIImage {
        if let url = URL(string: music.albumArt) {
            if let data = try? Data(contentsOf: url ) {
                return UIImage(data: data)!
            } else {
                return UIImage(systemName: "xmark")!
            }
        } else {
            return UIImage(systemName: "xmark")!
        }
    }
}

//출처: https://developer.apple.com/forums/thread/687916
class MyActivityItemSource: NSObject, UIActivityItemSource {
    var title: String = "RE:CORD"
    var text: String
    var image: UIImage
    
    init(text: String, image: UIImage) {
        self.text = text
        self.image = image
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return text
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return text
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.iconProvider = NSItemProvider(object: UIImage(imageLiteralResourceName: "AppIcon") )
        metadata.originalURL = URL(fileURLWithPath: text)
        return metadata
    }
}