//
//  ShareLinkView.swift
//  YVLearning
//
//  Created by Yash Vyas on 27-02-2025.
//

import SwiftUI

struct ShareLinkView: View {

    private let shareItem = URL(string: "https://developer.apple.com/documentation/SwiftUI/ShareLink")!
    private let cornerRadius = 20.0
    private let spacing = 44.0

    @available(iOS 16.0, *)
    private var photo: Photo {
        .init(image: Image(systemName: "photo.artframe"), caption: "Photo")
    }

    var body: some View {
        if #available(iOS 16.0, *) {

            NavigationStack {
                VStack {
                    Divider()
                        .background(.ultraThickMaterial)

                    VStack(spacing: spacing) {
                        ShareLink(
                            "Share Url",
                            item: shareItem
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundStyle(Color.white)
                        .cornerRadius(cornerRadius)

                        ShareLink(
                            "Share Multiple Url",
                            items: [shareItem, shareItem]
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundStyle(Color.white)
                        .cornerRadius(cornerRadius)

                        ShareLink(
                            item: photo,
                            subject: Text("Cool Photo"),
                            message: Text("Check it out!"),
                            preview: SharePreview(
                                photo.caption,
                                image: photo.image
                            ),
                            label: {
                                VStack {
                                    photo.image
                                        .resizable()
                                        .scaledToFit()
                                    Label(
                                        "Share Image with Caption",
                                        systemImage: "square.and.arrow.up"
                                    )
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundStyle(Color.white)
                                .cornerRadius(cornerRadius)
                            }
                        )
                    }
                    .padding(.horizontal)
                    .padding(.vertical, spacing)
                }
                .font(.title2)
                .frame(maxHeight: .infinity, alignment: .top)
                .background(Color.yellow.opacity(0.7))
                .navigationTitle("Share")
                .navigationBarTitleDisplayMode(.inline)
            }

        } else {
            Button("Share", action: shareBeforeiOS16)
        }
    }

    func shareBeforeiOS16() {
        let activityVC = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }

}

@available(iOS 16.0, *)
struct Photo: Transferable {
    let image: Image
    let caption: String

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }
}

@available(iOS 16.0, *)
struct JSONFile: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .json) { jsonFile in
            SentTransferredFile(jsonFile.url)
        }
    }
}

#Preview {
    ShareLinkView()
}
