require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @product = products(:tshirt)

    # 1. On assigne un utilisateur (requis par belongs_to :user)
    @product.user = users(:david)

    # 2. On crée une fausse image (requis par validates :image_description)
    # On utilise l'icône par défaut de Rails qui existe dans le dossier public
    image = ImageDescription.new
    image.attachment.attach(
      io: File.open(Rails.root.join("public/icon.png")),
      filename: "icon.png",
      content_type: "image/png"
    )
    @product.image_description = image

    # On sauvegarde pour être sûr que le produit est valide en base de données
    @product.save!
  end

  test "sends email notifications when back in stock" do
    # On met le stock à 0
    @product.update!(inventory_count: 0)

    # On vérifie que 2 emails partent quand le stock revient à 99
    assert_emails 2 do
      @product.update!(inventory_count: 99)
    end
  end
end
