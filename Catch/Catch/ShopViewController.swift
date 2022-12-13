//
//  ShopViewController.swift
//  Catch
//
//  Created by Ilyes Djari on 06/12/2022.
//

import UIKit
import Kingfisher
import PopupDialog


class ShopViewController: UIViewController {

    var shopData: [Pokemon]?
    var diamonds : Int = 0

    @IBOutlet weak var diamondCredit: UILabel!
    @IBOutlet weak var firstShopName: UILabel!
    @IBOutlet weak var thirdShopName: UILabel!
    @IBOutlet weak var secondShopName: UILabel!
    
    @IBOutlet weak var firstShopImage: UIImageView!
    @IBOutlet weak var secondShopImage: UIImageView!
    @IBOutlet weak var thirdShopImage: UIImageView!
    
    @IBAction func buy2(_ sender: Any) {
        let i = 1
            if diamonds >= 199 {
                saveData(i: i)
                perform(#selector(presentBought), with: nil, afterDelay: 0)
            } else {
                perform(#selector(presentNot), with: nil, afterDelay: 0)
            }
    }
    
    @IBAction func buy1(_ sender: Any) {
    let i = 0
        if diamonds >= 2 {
            saveData(i: i)
            perform(#selector(presentBought), with: nil, afterDelay: 0)
            print("succes")
        } else {
            perform(#selector(presentNot), with: nil, afterDelay: 0)
            print("No")

        }
        
    }
    
    @IBAction func buy3(_ sender: Any) {
        let i = 2
        
            if diamonds > 499 {
                saveData(i: i)
                perform(#selector(presentBought), with: nil, afterDelay: 0)

            } else {
                perform(#selector(presentNot), with: nil, afterDelay: 0)
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initShop()
        
    }
    
    func initShop() {
        
        diamondCredit.text = String(diamonds)
        
        firstShopName.text = shopData![0].name
        secondShopName.text = shopData![1].name
        thirdShopName.text = shopData![2].name
        
        let firsturl = URL(string: shopData![0].sprites.frontDefault ?? "he")
        let secondurl = URL(string: shopData![1].sprites.frontDefault ?? "he")
        let thirdurl = URL(string: shopData![2].sprites.frontDefault ?? "he")

        
        firstShopImage.kf.setImage(with: firsturl)
        secondShopImage.kf.setImage(with: secondurl)
        thirdShopImage.kf.setImage(with: thirdurl)

        //{ [self] result in
        //            switch result {
        //            case .success(let value):
        //                let colors = value.image.getColors()
        //                UIView.animate(withDuration: 1.0) { [self] in
        //
        //                }
        //            case .failure(let error):
        //                print("Error: \(error)")
        //            }
    


    }
    
    
    func saveData(i:Int) {
        print("called")
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let poke = StoredPokemon(context: context)
            poke.name = shopData![i].name
            poke.frontDefault = shopData![i].sprites.frontDefault
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    @objc private func presentBought() {
    let title = "Succesfull transaction"
    let message = "Now this pokemon is yours!"
    let image = UIImage(named: "userLocation-cover")
    let popup = PopupDialog(title: title, message: message, image: image)
    let skipButton = CancelButton(title: "Accept") {
    self.dismiss(animated: true, completion: nil)
    }
    popup.addButtons([skipButton])
    self.present(popup, animated: true, completion: nil)
    }
    
    @objc private func presentNot() {
    let title = "Refused transaction"
    let message = "You don't have enough diamonds, go catch some more!!"
    let image = UIImage(named: "userLocation-cover")
    let popup = PopupDialog(title: title, message: message, image: image)
    let skipButton = CancelButton(title: "Close") {
    self.dismiss(animated: true, completion: nil)
    }
    popup.addButtons([skipButton])
    self.present(popup, animated: true, completion: nil)
    }
    
}
