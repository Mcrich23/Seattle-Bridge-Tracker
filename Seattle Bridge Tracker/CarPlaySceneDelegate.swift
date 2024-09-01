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
        let sections: [CPListSection] = [
            .init(items: [
                .init(text: "Loading...", detailText: nil)
            ])
        ]
        
        // 6 - Selecting the template
        let infoTemplate = CPListTemplate(title: "Bridges", sections: sections)
        
        // 7 - Setting the information template as the root template
        return infoTemplate
    }
    
    func makeBridgeDetailTemplate(for bridge: Bridge) -> CPInformationTemplate {
        let items: [CPInformationItem] = [
            .init(title: bridge.status.rawValue.capitalized, detail: nil)
        ]
        
        let template = CPInformationTemplate(title: bridge.name, layout: .leading, items: items, actions: [])
        
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
    
    var presentedBridgeTemplate: CPInformationTemplate?
    
    func fetchTemplateUpdates(with interfaceController: CPInterfaceController) {
        guard NetworkMonitor.shared.isConnected else {
            let template = CPListTemplate(title: "No Internet", sections: [])
            
            interfaceController.setRootTemplate(template, animated: true, completion: nil)
            
            return
        }
        viewModel.fetchData(repeatFetch: true) { sortedBridges in
            let sections: [CPListSection] = sortedBridges.map { name, bridges in
                let items = bridges.map({ bridge in
                    let item = CPListItem(text: bridge.name, detailText: bridge.status.rawValue.capitalized, image: UIImage(url: bridge.imageUrl))
                    
                    item.handler = { _, action in
                        self.pushBridgeDetailTemplate(for: bridge, animated: true, interfaceController: interfaceController)
                        
                        action()
                    }
                    
                    return item
                })
                
                return .init(items: items, header: name.capitalized, sectionIndexTitle: sortedBridges.keys.count > 1 ? name.capitalized : nil)
            }
            
            let template = CPListTemplate(title: "Bridges", sections: sections)
            
            guard let rootTemplate: CPListTemplate = interfaceController.rootTemplate as? CPListTemplate else { return }
            
            let rootSections: [CPListSection] = rootTemplate.sections as [CPListSection]
            let mappedRootSectionItems: [CPListItem] = rootSections.flatMap({ $0.items.compactMap({ $0 as? CPListItem })})
            let mappedSectionItems = sections.flatMap({ $0.items.compactMap({ $0 as? CPListItem })})
            
            if self.presentedBridgeTemplate != nil, let templatesIndex = interfaceController.templates.firstIndex(where: { ($0 as? CPInformationTemplate)?.title == self.presentedBridgeTemplate?.title }) {
                if let bridge = sortedBridges.values.flatMap({ $0 }).first(where: { $0.name == self.presentedBridgeTemplate?.title }) {
                    let template = self.makeBridgeDetailTemplate(for: bridge)
                    
                    (interfaceController.templates[templatesIndex] as? CPInformationTemplate)?.items = template.items
                }
            }
            
            if mappedSectionItems != mappedRootSectionItems {
                (interfaceController.rootTemplate as? CPListTemplate)?.updateSections(sections)
            }
        }
    }
    
    func templateWillDisappear(_ aTemplate: CPTemplate, animated: Bool) {
        if let userInfo = aTemplate.userInfo as? [String : Bool], (userInfo["isSubBridge"] ?? false) {
            self.presentedBridgeTemplate = nil
        }
    }
}
