class Product < ApplicationRecord
  include Notifications
  has_many :subscribers, dependent: :destroy
  belongs_to :user
  has_rich_text :description

  has_one :image_description, as: :imageable, dependent: :destroy

  accepts_nested_attributes_for :image_description, allow_destroy: true

  validates :image_description, presence: true

  validates :name, presence: true

  validates :inventory_count, numericality: { greater_than_or_equal_to: 0 }

  after_update_commit :notify_subscribers, if: :back_in_stock?

  def back_in_stock?
    inventory_count_previously_was.zero? && inventory_count.positive?
  end

  def notify_subscribers
    subscribers.each do |subscriber|
      ProductMailer.with(product: self, subscriber: subscriber).in_stock.deliver_later
    end
  end

end