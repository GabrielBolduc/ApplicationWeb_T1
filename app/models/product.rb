class Product < ApplicationRecord
  belongs_to :user
  has_rich_text :description

  has_one :image_description, as: :imageable, dependent: :destroy

  # Cela permet de créer l'image_description EN MÊME TEMPS que le produit dans le formulaire
  accepts_nested_attributes_for :image_description, allow_destroy: true

  validates :name, presence: true
end