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
}