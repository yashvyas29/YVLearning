//
//  RedactedView.swift
//  YVLearning
//
//  Created by Yash Vyas on 05/03/22.
//

import SwiftUI

@available(iOS 14.0, *)
struct RedactedView: View {
    @State var name: String?
    @State var designation: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hello \(name ?? .placeholder(length: 13))!")
                .fontWeight(.bold)
                .font(.largeTitle)
            Text("Designation: \(designation ?? .placeholder(length: 18))")
                .fontWeight(.medium)
                .font(.title2)
            Text("How are you ?")
                .fontWeight(.semibold)
                .font(.title3)
                .unredacted()
        }
        .redacted(if: name.isNil)
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                name = "Yash Vyas"
                designation = "iOS Developer"
            }
        }
    }
}

@available(iOS 14.0, *)
struct RedactedView_Previews: PreviewProvider {
    static var previews: some View {
        RedactedView()
    }
}
