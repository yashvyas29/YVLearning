//
//  RouterSheetModifier.swift
//  MVI-SwiftUI
//
//  Created by Vyacheslav Ansimov.
//

import SwiftUI
import Combine

protocol RouterSheetScreenProtocol {}

struct RouterSheetModifier<Screen, ScreenType> where Screen: View, ScreenType: RouterSheetScreenProtocol {

    // MARK: Public

    var isFullScreenCover: Bool = false
    let publisher: AnyPublisher<ScreenType, Never>
    var screen: (ScreenType) -> Screen
    let onDismiss: ((ScreenType) -> Void)?

    // MARK: Private

    @State private var screenType: ScreenType?

    private var isPresented: Binding<Bool> {
        Binding<Bool>(
            get: { screenType != nil },
            set: {
                if !$0 {
                    if let type = screenType { onDismiss?(type) }
                    screenType = nil
                }
            })
    }

    @ViewBuilder private var sheetContent: some View {
        if let type = screenType {
            screen(type)
        } else {
            EmptyView()
        }
    }
}

// MARK: - ViewModifier

extension RouterSheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        let view = content
            .onReceive(publisher) { screenType = $0 }
        return sheetBody(view: view)
    }

    @ViewBuilder private func sheetBody(view: some View) -> some View {
        if #available(iOS 14.0, *) {
            if isFullScreenCover {
                view.fullScreenCover(isPresented: isPresented, content: { self.sheetContent })
            } else {
                view.sheet(isPresented: isPresented, content: { self.sheetContent })
            }
        } else {
            view.sheet(isPresented: isPresented, content: { self.sheetContent })
        }
    }
}
