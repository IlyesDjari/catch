//
//  ViewController.swift
//  Catch
//
//  Created by Ilyes Djari on 22/11/2022.
//

import UIKit
import PokemonAPI
import CoreData
import Kingfisher

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pokemonMapView: UIView!
    
    var shopPokemon : [ShopPokemon] = []
    var storedpokemon : [StoredPokemon] = []
    var allInfo : [[Welcome]?]? = []
    var yourPokemons: [Pokemon]?
    var shopData: [Pokemon]?
    var thePokemon: [Welcome]?
    var diamond: Int = 0
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.allowsSelectionDuringEditing = true
        tableView.dataSource = self
        tableView.rowHeight = 230.0
        callApi()
        getStore()
    }
    
    func getStore() {
    
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            do {
                shopPokemon = try context.fetch(ShopPokemon.fetchRequest())
            } catch {
                print("Fetching Failed")
            }
            
            if shopPokemon.count == 0 {
                Task {
                    await getPokemonForShop()
                }
            } else {
                 shopData = []
               for pokemons in shopPokemon {
                   let pokemonInfo = Pokemon(id: Int(bitPattern: pokemons.id), name: pokemons.name!, sprites: Pokemon.Sprites.init(frontDefault: pokemons.frontDefault!))
                   shopData?.append(pokemonInfo)
               }
            }

    }
    
    @objc private func getPokemonForShop() async  -> Void {
        await Webservice.getDataFromWebservice { pokemonInfo in
            self.shopData = pokemonInfo
            self.saveShopData()
        }
    }
    
    func saveShopData() {
        for wholeShop in self.shopData! {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let pokemon = ShopPokemon(context: context)
            pokemon.name = wholeShop.name
            pokemon.frontDefault = wholeShop.sprites.frontDefault
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }
    
    func callApi() {
        Task {
            await getData()
        }
    }
    
    @objc private func getData() async  -> Void {
        
        for pokemons in storedpokemon {
            await Webservice.getPokemonFromWebservice(chosenPokemon: pokemons.name!) { [self] pokemonInfo in
                self.thePokemon = pokemonInfo
                allInfo?.append(pokemonInfo)
            }
        }
    }

 
}
    

extension ViewController: UITableViewDataSource, UITableViewDelegate {
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: cell.contentView.frame.width, y: cell.contentView.frame.height)
        UIView.animate(withDuration: 0.5, animations: {
            cell.transform = CGAffineTransform(translationX: cell.contentView.frame.width, y: cell.contentView.frame.height)
            cell.alpha = 1
        })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return (storedpokemon.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokeCell", for: indexPath) as! pokeCell
        DispatchQueue.main.async { [self] in
        cell.pokeLabel.text = storedpokemon[indexPath.row].name!
            let url = URL(string: storedpokemon[indexPath.row].frontDefault!)
            cell.pokeImg.kf.setImage(with: url)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            self.performSegue(withIdentifier: "detailSegue", sender: self)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "detailSegue" {
                let details = segue.destination as! PokemonViewController
                let row = tableView.indexPathForSelectedRow!.row
                details.chosenPokemon = (storedpokemon[row].name)
                details.pokeData = (allInfo?[row])
                
            } else if segue.identifier == "shopSegue" {
                let shop = segue.destination as! ShopViewController
                shop.shopData = shopData
                shop.diamonds = diamond
            }
            
        }
}

class pokeCell : UITableViewCell {
    @IBOutlet weak var pokeImg: UIImageView!
    @IBOutlet weak var pokeLabel: UILabel!
}


