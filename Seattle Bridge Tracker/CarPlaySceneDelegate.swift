//
//  CarPlaySceneDelegate.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 8/30/24.
//

import Foundation
import UIKit
import SwiftUI
import CarPlay
import Mcrich23_Toolkit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate, CPInterfaceControllerDelegate {
    let viewModel = ContentViewModel()
    
    /// 1. CarPlay connected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        
        interfaceController.delegate = self
        
        let rootTemplate = self.makeRootTemplate()
            interfaceController.setRootTemplate(rootTemplate, animated: true,
                completion: nil)
        
        fetchTemplateUpdates(with: interfaceController)
    }
    
    /// 4. Information template
    private func makeRootTemplate() -> CPTemplate {
        // 5 - Setting the content for the template
        let items: [CPInformationItem] = [
            CPInformationItem(title: "Loading...", detail: nil)
        ]
        
//        loadingItem.handler = { $1() }
        
        // 6 - Selecting the template
        let infoTemplate = CPInformationTemplate(title: "Bridges", layout: .leading, items: items, actions: []) // CPListTemplate(title: "Bridges", sections: [.init(items: [loadingItem])])
        
        // 7 - Setting the information template as the root template
        return infoTemplate
    }
    
    func makeBridgeDetailTemplate(for bridge: Bridge) -> CPListTemplate {
        let item = CPListImageRowItem(text: bridge.status.rawValue.capitalized, images: [.init(url: bridge.imageUrl) ?? .bridgeIcon ])
        
        item.listImageRowHandler = { $2() }
        
        let template = CPListTemplate(title: bridge.name, sections: [.init(items: [item])])
        
        template.userInfo = [
            "isSubBridge" : true
        ]
        
        return template
    }
    
    func pushBridgeDetailTemplate(for bridge: Bridge, animated: Bool, interfaceController: CPInterfaceController) {
        let template = makeBridgeDetailTemplate(for: bridge)
        
        self.presentedBridgeTemplate = template
        
        interfaceController.pushTemplate(template, animated: animated, completion: nil)
    }
    
    var presentedBridgeTemplate: CPListTemplate?
    
    func checkIsConnected(interfaceController: CPInterfaceController) -> Bool {
        guard NetworkMonitor.shared.isConnected else {
            let items: [CPInformationItem] = [
                .init(title: "No Internet", detail: "Please check your connection and try again.")
            ]
            
            let template = CPInformationTemplate(title: "Bridges", layout: .leading, items: items, actions: [])
            
            interfaceController.setRootTemplate(template, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    func fetchTemplateUpdates(with interfaceController: CPInterfaceController) {
        viewModel.fetchData(repeatFetch: true) { sortedBridges in
            guard self.checkIsConnected(interfaceController: interfaceController) else { return }
            
            let sections: [CPListSection] = sortedBridges.map { name, bridges in
                let items = bridges.map({ bridge in
                    let icon: UIImage?
                    
                    switch bridge.status {
                    case .up: icon = .init(systemSymbol: .xmark)
                    case .down: icon = .init(systemSymbol: .checkmark)
                    case .maintenance: icon = .init(systemSymbol: .exclamationmarkTriangle)
                    default: icon = nil
                    }
                    
                    let item = CPListItem(text: bridge.name, detailText: bridge.status.rawValue.capitalized, image: UIImage(url: bridge.imageUrl), accessoryImage: icon, accessoryType: .cloud)
                    
                    item.handler = { _, action in
//                        self.pushBridgeDetailTemplate(for: bridge, animated: true, interfaceController: interfaceController)
                        
                        action()
                    }
                    
                    return item
                })
                
                return .init(items: items, header: name.capitalized, sectionIndexTitle: sortedBridges.keys.count > 1 ? name.capitalized : nil)
            }
            
            let mappedSectionItems = sections.flatMap({ $0.items.compactMap({ $0 as? CPListItem })})
            
            guard let rootTemplate: CPListTemplate = interfaceController.rootTemplate as? CPListTemplate else {
                if !mappedSectionItems.isEmpty {
                    let template = CPListTemplate(title: "Bridges", sections: sections)
                    
                    interfaceController.setRootTemplate(template, animated: true, completion: nil)
                }
                return
            }
            
            let rootSections: [CPListSection] = rootTemplate.sections as [CPListSection]
            let mappedRootSectionItems: [CPListItem] = rootSections.flatMap({ $0.items.compactMap({ $0 as? CPListItem })})
            
            if self.presentedBridgeTemplate != nil, 
                let templatesIndex = interfaceController.templates.firstIndex(where: { ($0 as? CPInformationTemplate)?.title == self.presentedBridgeTemplate?.title }),
                let bridge = sortedBridges.values.flatMap({ $0 }).first(where: { $0.name == self.presentedBridgeTemplate?.title }) {
                let template = self.makeBridgeDetailTemplate(for: bridge)
                
                (interfaceController.templates[templatesIndex] as? CPListTemplate)?.updateSections(template.sections)
            }
            
            if mappedSectionItems != mappedRootSectionItems && !mappedSectionItems.isEmpty {
                rootTemplate.updateSections(sections)
            }
        }
    }
    
    func templateWillDisappear(_ aTemplate: CPTemplate, animated: Bool) {
        if let userInfo = aTemplate.userInfo as? [String : Bool], (userInfo["isSubBridge"] ?? false) {
            self.presentedBridgeTemplate = nil
        }
    }
}
