//
//  OR.swift
//  QRscannerDemo
//
//  Created by Manoj Amsavel on 9/7/23.
//
import SwiftUI
import CoreLocation
import _MapKit_SwiftUI

struct QRView: View {
    //@State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    var body: some View {
        VStack{
            
          Button{
            ScannerView() 
            }label: {
                Text("Next") .font(.footnote).fontWeight(.semibold)
                    .foregroundColor(.white)
              .padding()
            }.frame(width: 360,height: 49).background(Color(.systemBlue)).cornerRadius(10)
        
//            Map(coordinateRegion: $region)
//                .frame(width: 800, height: 900)
           
        }
    }
}
struct ORView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

