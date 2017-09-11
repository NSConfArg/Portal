//
//  SegmentedRenderer.swift
//  PortalView
//
//  Created by Cristian Ames on 4/4/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import UIKit

public let defaultSegmentedFontSize = UInt(UIFont.systemFontSize)
  
extension UISegmentedControl: MessageProducer {
    
    func apply<MessageType>(changeSet: SegmentedChangeSet<MessageType>,
                            layoutEngine: LayoutEngine) -> Render<MessageType> {
        apply(changeSet: changeSet.segments)
        apply(changeSet: changeSet.baseStyleSheet)
        apply(changeSet: changeSet.segmentedStyleSheet)
        layoutEngine.apply(changeSet: changeSet.layout, to: self)
        
        return Render<MessageType>(view: self, mailbox: getMailbox(), executeAfterLayout: .none)
    }
    
    fileprivate func dispatch<MessageType>(
        messages: [MessageType?],
        for event: UIControlEvents,
        with mailbox: Mailbox<MessageType> = Mailbox()) -> Mailbox<MessageType> {
        
        let dispatcher = MessageDispatcher(mailbox: mailbox) { sender in
            guard let segmentedControl = sender as? UISegmentedControl else { return .none }
            let index = segmentedControl.selectedSegmentIndex
            return index < messages.count ? messages[index] : .none
        }
        
        self.register(dispatcher: dispatcher)
        self.addTarget(dispatcher, action: dispatcher.selector, for: event)
        return dispatcher.mailbox
    }
    
}

fileprivate extension UISegmentedControl {

    fileprivate func apply<MessageType>(changeSet: PropertyChange<ZipList<SegmentProperties<MessageType>>>) {
        guard case .change(let segments) = changeSet else { return }
        
        // TODO avoid removing and reinserting segments if they
        // did not change.
        removeAllSegments()
        for (index, segment) in segments.enumerated() {
            switch segment.content {
                
            case .image(let image):
                insertSegment(with: image.asUIImage, at: index, animated: false)
                
            case .title(let text):
                insertSegment(withTitle: text, at: index, animated: false)
            }
            
            setEnabled(segment.isEnabled, forSegmentAt: index)
        }
        
        let messages = segments.map { $0.onTap }
        let _: Mailbox<MessageType> = self.on(event: UIControlEvents.valueChanged) { sender in
            guard let segmentedControl = sender as? UISegmentedControl else { return .none }
            let index = segmentedControl.selectedSegmentIndex
            return index < messages.count ? messages[index] : .none
        }
        
        selectedSegmentIndex = Int(segments.centerIndex)
    }
    
    fileprivate func apply(changeSet: [SegmentedStyleSheet.Property]) {
        var fontName: String? = .none
        var fontSize: CGFloat? = .none
        var textColor: UIColor? = .none
        
        for property in changeSet {
            switch property {
                
            case .borderColor(let borderColor):
                tintColor = borderColor.asUIColor
                
            case .textColor(let color):
                textColor = color.asUIColor
                
            case .textFont(let font):
                fontName = font.name
                
            case .textSize(let size):
                fontSize = CGFloat(size)
            }
        }
        
        setFont(name: fontName, size: fontSize, color: textColor)
    }
    
    fileprivate func setFont(name: String?, size: CGFloat?, color: UIColor?) {
        var dictionary = [String: Any]()
        let font = UIFont(name: name ?? UIFont.systemFont(ofSize: 15).fontName,
                          size: size ?? CGFloat(defaultSegmentedFontSize))
        color |> { dictionary[NSForegroundColorAttributeName] = $0 }
        font |> { dictionary[NSFontAttributeName] = $0 }
        setTitleTextAttributes(dictionary, for: .normal)
    }
    
}
