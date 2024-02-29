//
//  GalleryView.swift
//  Aspyre
//

import SwiftUI
import SkeletonUI
import Kingfisher

struct GalleryView: View {
    
    @StateObject var viewModel: GalleryViewModel = .make()
    @State var searchContactName: String = Constants.empty
    @State var isContactSheetOpened: Bool = false
    @State var isTappedSearch: Bool = false
    @State var selectedItem: String?
    
    private let columns: [GridItem] = Array(
        repeating: .init(.flexible(), spacing: Constants.galleryCardSpacing),
        count: Constants.galleryGridColumns
    )
    
    var emptyState: some View {
        VStack {
            Spacer()
            Text(L10n.emptyState)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    var welcome: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                    .frame(width: 36)
                
                Text(L10n.findPhotos)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier(Constants.welcomeTextIdentifier)
                
                Spacer()
                    .frame(width: 36)
            }
            
            Spacer()
            
        }
    }
    
    var body: some View {
        
        NavigationView {
            
            ZStack(alignment: .bottom) {
                
                if viewModel.showEmptyState {
                    emptyState
                }
                else if viewModel.contactName.isEmpty {
                    welcome
                }
                else {
                    photos
                }
                
                search
            }
            .navigationBarTitle(L10n.appName, displayMode: .inline)
        }
    }
    
    var search: some View {
        
        SearchBar(
            searchText: $searchContactName,
            onTapSearch: {
                viewModel.setContact(name: searchContactName)
            },
            onTapContact: {
                isContactSheetOpened.toggle()
            }
        )
        .sheet(
            isPresented: $isContactSheetOpened,
            content: {
                ContactPicker(contactSelected: $searchContactName) {
                    isContactSheetOpened = false
                }
            }
        )
        .onChange(of: searchContactName) { _ in
            viewModel.setContact(name: searchContactName)
        }
    }
    
    var photos: some View {
        
        GeometryReader { geometry in
            
            /// Image size
            let size = geometry.size.width / CGFloat(Constants.galleryGridColumns) - Constants.galleryCardSpacing
            
            List {
                
                LazyVGrid(
                    columns: columns,
                    spacing: Constants.galleryCardSpacing
                ) {
                    
                    SkeletonForEach(
                        with: viewModel.photos,
                        quantity: Constants.photosPerPage
                    ) { loading, model in
                        
                        let id = model?.id ?? Constants.empty
                        let imageURL = URL(string: model?.getSmallImage() ?? Constants.empty)
                        
                        KFImage(imageURL)
                            .resizable()
                            .scaledToFill()
                            .skeleton(with: loading)
                            .shape(type: .rectangle)
                            .frame(width: size, height: size)
                            .clipped()
                            .background(
                                NavigationLink(
                                    destination: DetailView(id: id, photo: model?.getMediumImage()),
                                    tag: id,
                                    selection: $selectedItem
                                ) { EmptyView() }
                                    .opacity(Double(Constants.zero))
                                    .buttonStyle(PlainButtonStyle())
                            )
                            .onTapGesture {
                                selectedItem = id
                            }
                            .accessibilityIdentifier(Constants.photoImageViewIdentifier)
                    }
                }
                .accessibilityIdentifier(Constants.photosGridIdentifier)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                
                if viewModel.areMorePhotosAvailable() {
                    
                    HStack {
                    
                        Spacer()
                        
                        ProgressView()
                            .onAppear {
                                viewModel.loadMore()
                            }
                        
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
            }
            .refreshable { viewModel.reload() }
            .listStyle(PlainListStyle())
        }
    }
    
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
    }
}
