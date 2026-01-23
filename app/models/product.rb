class Product < ApplicationRecord
  belongs_to :user
  has_rich_text :description

  has_one :image_description, as: :imageable, dependent: :destroy

  accepts_nested_attributes_for :image_description, allow_destroy: true

  validates :image_description, presence: true

  validates :name, presence: true
end