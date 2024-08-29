//
//  NotificationPreferencesBody.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 3/27/23.
//

import SwiftUI
import Mcrich23_Toolkit
import SwiftUIX

struct NotificationPreferencesBody: View {
    @Binding var preference: NotificationPreferences
    @ObservedObject var preferencesModel = NotificationPreferencesModel.shared
    @ObservedObject var contentViewModel = ContentViewModel.shared
    @State var isEditingTitle = false
    @State var titleEditorIsFocused = false
    @State var editedTitle = ""
    var body: some View {
        VStack {
            HStack {
                HStack {
                    if isEditingTitle {
                        HStack {
                            Group {
                                TitleTextEditor(text: $editedTitle, isEditing: $titleEditorIsFocused, clearButtonMode: .whileEditing) {
                                    withAnimation {
                                        preferencesModel.saveUpdatedTitle(for: preference, with: editedTitle, showTextEditorIfDuplicate: false) {
                                            self.titleEditorIsFocused = false
                                            self.isEditingTitle = false
                                        }
                                    }
                                }
                                .minimumScaleFactor(0.6)
                                .padding(.leading)
                                .accessibility(identifier: "Title Editor")
                            }
                            .padding([.top, .trailing, .bottom], 5.0)
                        }
                        .background(Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .frame(maxWidth: 150)
                    } else {
                        Text(preference.title)
                            .font(.title2)
                    }
                }
                if isEditingTitle {
                    HStack {
                        Button {
                            withAnimation {
                                editedTitle = preference.title
                                self.titleEditorIsFocused = false
                                self.isEditingTitle = false
                            }
                        } label: {
                            Text("X")
                                .foregroundColor(.red)
                        }
                        Button {
                            withAnimation {
                                preferencesModel.saveUpdatedTitle(for: preference, with: editedTitle, showTextEditorIfDuplicate: false) {
                                    self.titleEditorIsFocused = false
                                    self.isEditingTitle = false
                                }
                            }
                        } label: {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                } else {
                    Button {
                        withAnimation {
                            self.isEditingTitle = true
                            self.titleEditorIsFocused = true
                        }
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
                Spacer()
                Button {
                    Mcrich23_Toolkit.presentShareSheet(activityItems: [ "https://bridges.mcrich23.com/notifications/\(Utilities.deviceID ?? "")/\(preference.id)" ], excludedActivityTypes: [])
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .hoverEffect(SwiftUI.HoverEffect.highlight)
                Button {
                    preferencesModel.duplicateNotificationPreferenceAlert(basedOn: preference, onDone: {})
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .hoverEffect(SwiftUI.HoverEffect.highlight)
                Button {
                    preferencesModel.deleteNotificationPreference(preference: preference)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(Color.red)
                }
                .hoverEffect(SwiftUI.HoverEffect.highlight)
            }
            .imageScale(.large)
            .frame(height: 40)
            Divider()
                .padding(.bottom)
            NotificationPreferenceDaysPicker(preference: $preference)
            NotificationPreferencesTimePicker(preference: $preference)
            if #available(iOS 15, *) {
                NotificationPreferencesImportance(preference: $preference)
            }
            NotificationPreferencesSelectedBridges(preference: $preference)
            NotificationPreferencesActiveToggle(preference: $preference)
        }
        .padding()
        .onAppear {
            self.editedTitle = preference.title
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.systemGroupedBackground)
        }
    }
}

struct NotificationPreferencesBody_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPreferencesBody(preference: .constant(.defaultPreferences))
    }
}
