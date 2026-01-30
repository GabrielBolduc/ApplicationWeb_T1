import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "detail", "nameInput", "inventoryInput", "fileInput"]

  connect() {
    console.log("API Controller connect")
    this.listProducts() // load la list des que la page s'ouvre
  }

  // list 
  listProducts() {
    fetch("/products.json")
      .then(response => response.json())
      .then(data => {
        this.listTarget.innerHTML = "" // vide la list

        data.forEach(product => {
          const li = document.createElement("li")

          li.innerHTML = `
            <strong>${product.name}</strong> (Stock: ${product.inventory_count})
            <button data-action="click->api#showProduct" data-id="${product.id}">Show</button>
            <button data-action="click->api#deleteProduct" data-id="${product.id}">delete</button>
          `
          this.listTarget.appendChild(li)
        });
      })
  }

  // show
  showProduct(event) {
    const id = event.target.dataset.id
    fetch(`/products/${id}.json`)
      .then(response => response.json())
      .then(product => {
        this.detailTarget.innerHTML = `
          <div style="border: 1px solid; padding: 15px;">
            <h4>${product.name}</h4>
            <p><strong>Id: </strong> ${product.id}</p>
            <p><strong>Inventaire:</strong> ${product.inventory_count}</p>
            <p><strong>Description:</strong> ${product.description || "Aucune"}</p>
          </div>
        `
      })
  }

  // create
  createProduct(){
    if(this.fileInputTarget.files.length === 0){
      alert("Image obligatoire")
      return
    }

    const token = document.querySelector('meta[name="csrf-token"]').content

    const formData = new FormData()
    formData.append('product[name]', this.nameInputTarget.value)
    formData.append('product[inventory_count]', this.inventoryInputTarget.value)

    formData.append('product[image_description_attributes][attachment]', this.fileInputTarget.files[0])

    fetch("/products.json", {
      method: "POST",
      headers: {
        "X-CSRF-Token": token
      },
      body: formData
    })
    .then(async response =>{
      if(response.ok){
        this.nameInputTarget.value = ""
        this.inventoryInputTarget.value = ""
        this.fileInputTarget.value = "" 
        this.listProducts()
        console.log("Produit créé avec succès")
      }else{
        const errorData = await response.json()
        alert("Erreur lors de la création :\n" + JSON.stringify(errorData, null, 2))
      }
    })
    .catch(error => console.error("Erreur réseau:", error))
  }

  //delete
  deleteProduct(event){
    if (!confirm("Supprimer?")) return

    const id = event.target.dataset.id
    const token = document.querySelector('meta[name="csrf-token"]').content

    fetch(`/products/${id}.json`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": token,
        "Content-Type": "application/json"
      }
    })
    .then(response => {
      if (response.ok) {
        this.listProducts()
        this.detailTarget.innerHTML = "<p>Produit delete</p>"
      } else{
        alert("error")
      }
    })
  }
}