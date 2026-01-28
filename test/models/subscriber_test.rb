class Subscriber < ApplicationRecord
  belongs_to :product
  
  # AJOUTEZ CETTE LIGNE 👇
  generates_token_for :unsubscribe

  # (Vos autres validations éventuelles...)
  # validates :email, presence: true...
end