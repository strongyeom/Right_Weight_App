//
//  SearchView.swift
//  ExerciseRecordApp
//
//  Created by 염성필 on 2023/03/19.
//

import SwiftUI

struct SearchView: View {
    
    private var mainCategoies: [Color] = [.red, .yellow, .mint, .gray, .green]
    @Environment(\.managedObjectContext) private var viewContext
    @State private var exampleString: Date = Date()
    @State private var searchText: String = ""
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Entity.date, ascending: false)]) private var datas: FetchedResults<Entity>
    @State private var isFullCoverSheet: Bool = false    
    var body: some View {
        
        
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(datas) { data in
                        
                        if let category = data.category {
                            if category == searchText {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(mainCategoies[Int(data.colorIndex)], lineWidth: 1)
                                        .frame(height: 80)
                                        .overlay {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 10) {
                                                    
                                                    HStack {
                                                        if let data = data.date {
                                                            
                                                            let dateFromCoreData: Date = data
                                                            let kDate = dateFromCoreData.toKSTString()
                                                            
                                                            
                                                            Text("\(kDate)")
                                                                .font(.footnote)
                                                                .foregroundColor(.gray)
                                                                .padding(.trailing, 20)
                                                        }
                                                        
                                                        Text(data.category ?? "")
                                                            .background {
                                                                RoundedRectangle(cornerRadius: 12)
                                                                    .fill(mainCategoies[Int(data.colorIndex)])
                                                                    .frame(width: 45, height: 25, alignment: .center)
                                                            }
                                                            .tint(.white)
                                                        
                                                    }
                                                    
                                                    Text(data.title ?? "")
                                                        .font(.title3)
                                                        .foregroundColor(.black)
                                                    
                                                }
                                                Spacer()
                                                Rectangle()
                                                    .fill(.white)
                                                    .opacity(0.001)
                                                Button {
                                                    updateIsSuccess(target: data)
                                                } label: {
                                                    Image(systemName : data.isSuccess ? "checkmark.square.fill" : "checkmark.square")
                                                }

                                                
                                                HStack {
                                                    Rectangle()
                                                        .cornerRadius(12, corners: [.bottomRight, .topRight])
                                                        .foregroundColor(mainCategoies[Int(data.colorIndex)])
                                                }
                                                .frame(width: UIScreen.main.bounds.width * 0.05)
                                            }
                                            .padding(.leading, 10)
                                        }
                                        .opacity(data.isSuccess ? 0.3 : 1.0)
                                        .fullScreenCover(isPresented: $isFullCoverSheet) {
                                            PlayView(data: data)
                                        }
                            }
                        }
                    }
                    .onTapGesture {
                        isFullCoverSheet.toggle()
                    }
                }
                .padding()
            }
            
            .searchable(text: $searchText, prompt: "카테고리로 검색")
            .navigationBarTitle("운동일지")
            .navigationBarTitleDisplayMode(.inline)

        }
    }
    
    func removeData(target: Entity) {
        withAnimation {
            viewContext.delete(target)
            try? viewContext.save()
        }
    }
    
    func updateIsSuccess(target: Entity) {
        withAnimation {
            target.isSuccess.toggle()
            try? viewContext.save()
        }
    }
}



struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
