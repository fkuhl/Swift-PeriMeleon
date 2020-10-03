//
//  Services.swift
//  PMClient
//
//  Created by Frederick Kuhl on 5/15/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import PMDataTypes

struct ServicesView: View {
    var member: Member
    
    var body: some View {
        //Don't put these inside a Vstack or List: in context they're already in a List
        ForEach(member.services, id: \.self) { service in
            ServiceRowView(item: service)
        }
    }
}

struct ServiceRowView: View {
    var item: PMDataTypes.Service
    
    var body: some View {
        NavigationLink(destination: ServiceView(service: item)) {
            Text("\(dateForDisplay(item.date))  \(item.type.rawValue)")
                .font(.body)
        }
    }
}

struct ServiceView: View {
    var service: PMDataTypes.Service
    var body: some View {
        List {
            TextAttributeView(caption: "date", text: dateForDisplay(service.date))
            TextAttributeView(caption: "type", text: service.type.rawValue)
            if !nugatory(service.place) {
                TextAttributeView(caption: "place", text: service.place)
            }
            if !nugatory(service.comment) {
                TextAttributeView(caption: "comment", text: service.comment)
            }
        }        .navigationBarTitle("Service")

    }
}

//struct Services_Previews: PreviewProvider {
//    static var previews: some View {
//        Services()
//    }
//}
