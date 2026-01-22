class ImageDescription < ApplicationRecord
  belongs_to :imageable, polymorphic: true

  has_one_attached :attachment

  validates :attachment, presence: true
  
end