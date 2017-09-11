//
//  TextFieldRenderer.swift
//  PortalView
//
//  Created by Juan Franco Caracciolo on 4/10/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public let defaultTextFieldFontSize = UInt(UIFont.systemFontSize)

extension UITextField: MessageProducer {
    
    internal func apply<MessageType>(
        changeSet: TextFieldChangeSet<MessageType>,
        layoutEngine: LayoutEngine) -> Render<MessageType> {
        
        apply(changeSet: changeSet.properties)
        apply(changeSet: changeSet.baseStyleSheet)
        apply(changeSet: changeSet.textFieldStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render(view: self, mailbox: getMailbox(), executeAfterLayout: .none)
    }
    
}

fileprivate extension UITextField {
    
    fileprivate func apply<MessageType>(changeSet: [TextFieldProperties<MessageType>.Property]) {
        for property in changeSet {
            switch property {
                
            case .text(let text):
                self.text = text
            
            case .placeholder(let placeholder):
                self.placeholder = placeholder
                
            case .onEvents(let events):
                apply(events: events)
            }
        }
    }
    
    fileprivate func apply<MessageType>(events: TextFieldEvents<MessageType>) {
        for (event, maybeEvent) in events.getMessagesByEvent() {
            if let message = maybeEvent {
                _ = self.on(event: event, dispatch: message)
            } else {
                _ = self.unregisterDispatcher(for: event) as MessageDispatcher<MessageType>?
            }
        }
    }
    
    fileprivate func apply(changeSet: [TextFieldStyleSheet.Property]) {
        for property in changeSet {
            switch property {
                
            case .textAligment(let aligment):
                self.textAlignment = aligment.asNSTextAligment
            
            case .textColor(let color):
                self.textColor = color.asUIColor
                
            case .textFont(let font):
                let fontSize = self.font?.pointSize ?? CGFloat(defaultTextFieldFontSize)
                self.font = font.uiFont(withSize: fontSize)
                
            case .textSize(let textSize):
                let fontName = self.font?.fontName
                fontName |> { self.font = UIFont(name: $0, size: CGFloat(textSize)) }
            }
        }
    }
    
}

extension TextFieldEvents {
    
    fileprivate func getMessagesByEvent() -> [(UIControlEvents, MessageType?)] {
        return [
            (.editingDidBegin, onEditingBegin),
            (.editingChanged, onEditingChanged),
            (.editingDidEnd, onEditingEnd)
        ]
    }
    
}
