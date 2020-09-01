//
//  PopupButton.swift
//  KubeDoctor
//
//  Created by 翟怀楼 on 2020/8/1.
//  Copyright © 2020 翟怀楼. All rights reserved.
//

import Foundation
import SwiftUI
import Foundation

struct PopupButton<T: Hashable> : NSViewRepresentable
{
    @Binding var selectedValue: T
    @Binding var items: [T]

    private let onChange: ((T) -> Void)?

    init(selectedValue: Binding<T>, items: [T], onChange: ((T) -> Void)? = nil)
    {
        self._selectedValue = selectedValue
        self._items = Binding.constant(items)
        self.onChange = onChange
    }

    func makeNSView(context: Context) -> NSPopUpButton {
        let button = NSPopUpButton(frame: .zero, pullsDown: false)
        button.bezelStyle = .texturedRounded
        button.target = context.coordinator
        button.action = #selector(Coordinator.valueChanged(_:))
        button.addItems(withTitles: self.items.map({ String(describing: $0) }))
        let idx = self.items.firstIndex(of: self.selectedValue) ?? 0
        button.selectItem(at: idx)
        return button
    }

    func updateNSView(_ view: NSPopUpButton, context: Context) {
        context.coordinator.items = items
        view.removeAllItems()
        view.addItems(withTitles: self.items.map({ String(describing: $0) }))
        let idx = self.items.firstIndex(of: self.selectedValue) ?? 0
        view.selectItem(at: idx)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(binding: self.$selectedValue, items: self.items, onChange: self.onChange)
    }

    final class Coordinator : NSObject {
        let binding: Binding<T>
        var items: [T]
        
        let onChange: ((T) -> Void)?

        init(binding: Binding<T>, items: [T], onChange: ((T) -> Void)?) {
            self.binding = binding
            self.items = items
            self.onChange = onChange
        }

        @objc func valueChanged(_ sender: NSPopUpButton) {
            self.binding.wrappedValue = self.items[sender.indexOfSelectedItem]
            self.onChange?(self.binding.wrappedValue)
        }
    }
}
