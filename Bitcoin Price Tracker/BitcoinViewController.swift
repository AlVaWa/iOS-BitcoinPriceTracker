//
//  ViewController.swift
//  Bitcoin Price Tracker
//
//  Created by Aleksander Waage on 25/06/2020.
//  Copyright © 2020 Waageweb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var subSubLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Showing previous result initialy
        if let nok = UserDefaults.standard.string(forKey: Currencies.nok.rawValue){
             mainLabel.text = nok
        }
        if let eur = UserDefaults.standard.string(forKey: Currencies.eur.rawValue){
            subLabel.text = eur
        }
        if let usd = UserDefaults.standard.string(forKey: Currencies.usd.rawValue) {
            subSubLabel.text = usd
        }

        // Do any additional setup after loading the view.
        loadDataFromApi()

    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        loadDataFromApi()
    }
    
    func loadDataFromApi(){
        if let url = URL(string: "https://min-api.cryptocompare.com/data/price?fsym=BTC&tsyms=USD,NOK,EUR") {
            URLSession.shared.dataTask(with: url) { (data:Data?, response: URLResponse?, error: Error?) in
                if error == nil {
                    if data != nil {
                        if let  bitCoinPrices = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Double]{
                            if bitCoinPrices[Currencies.nok.rawValue] != nil && bitCoinPrices[Currencies.eur.rawValue] != nil && bitCoinPrices["USD"] != nil {
                                
                                DispatchQueue.main.async {
                                    let nokPrice = self.getStringFor(price: bitCoinPrices[Currencies.nok.rawValue]!, currencyCode: Currencies.nok.rawValue)
                                    let eurPrice = self.getStringFor(price: bitCoinPrices[Currencies.eur.rawValue]!, currencyCode: Currencies.eur.rawValue)
                                    let usdPrice = self.getStringFor(price: bitCoinPrices["USD"]!, currencyCode: "USD")
                                    
                                    // Storing data in user defaults so we have something to show on next app start
                                    UserDefaults.standard.set(nokPrice, forKey: Currencies.nok.rawValue)
                                    UserDefaults.standard.set(nokPrice, forKey: Currencies.eur.rawValue)
                                    UserDefaults.standard.set(nokPrice, forKey: "USD")
                                    
                                    self.mainLabel.text = nokPrice
                                    self.subLabel.text = eurPrice
                                    self.subSubLabel.text = usdPrice
                                }
                            }
                        }
                    }
                } else {
                    print("error")
                }
            }.resume()
        }
    }
    
    func getStringFor(price: Double, currencyCode: String) -> String {
        let formater = NumberFormatter()
        formater.numberStyle = .currency
        formater.currencyCode = currencyCode
        if let priceString = formater.string(from: NSNumber(value: price)){
            return priceString
        } else {
            return ""
        }
    }
    
    
}

enum Currencies: String {
    case nok = "NOK"
    case eur = "EUR"
    case usd = "USD"
}
