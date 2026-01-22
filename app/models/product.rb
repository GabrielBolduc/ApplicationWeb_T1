class Product < ApplicationRecord
  belongs_to :user

  has_one_attached :featured_image
  has_rich_text :description

  validates :name, presence: true

  validate :image_presence

  private

  def image_presence
    errors.add(:featured_image, "doit être présente") unless featured_image.attached?
  end
end