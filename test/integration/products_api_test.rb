require "test_helper"

class ProductsApiTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @product = products(:iphone)

    # CORRECTION IMPORTANTE : On attache une image au produit existant
    # pour éviter l'erreur de validation lors du test 'Update'
    unless @product.image_description
      desc = @product.build_image_description
      file_path = Rails.root.join('test', 'fixtures', 'files', 'icon.png')
      # On s'assure que le fichier existe avant de l'attacher
      unless File.exist?(file_path)
        Dir.mkdir(File.dirname(file_path)) unless Dir.exist?(File.dirname(file_path))
        FileUtils.touch(file_path) 
      end
      desc.attachment.attach(io: File.open(file_path), filename: 'icon.png', content_type: 'image/png')
      @product.save!
    end

    sign_in @user
  end

  # --- TEST 1 : LISTER (INDEX) ---
  test "API should list products" do
    # CRITÈRE 4 (NON-Modification BDD) : On vérifie que lire ne change rien
    assert_no_difference("Product.count") do
      get products_url(format: :json)
    end

    # CRITÈRE 1 (Code HTTP)
    assert_response :success 

    # CRITÈRE 2 (Format réponse)
    assert_equal "application/json; charset=utf-8", response.content_type

    # CRITÈRE 3 (Données)
    json_response = JSON.parse(response.body)
    assert_includes json_response.map { |p| p["name"] }, "iPhone 15"
  end

  # --- TEST 2 : VOIR (SHOW) ---
  test "API should show product" do
    # CRITÈRE 4 (NON-Modification BDD)
    assert_no_difference("Product.count") do
      get product_url(@product, format: :json)
    end

    # CRITÈRE 1 (Code HTTP)
    assert_response :success

    # CRITÈRE 2 (Format réponse)
    assert_equal "application/json; charset=utf-8", response.content_type

    # CRITÈRE 3 (Données)
    json_response = JSON.parse(response.body)
    assert_equal @product.id, json_response["id"]
  end

  # --- TEST 3 : CRÉATION (CREATE) ---
  test "API should create product" do
    file = fixture_file_upload("icon.png", "image/png")

    # CRITÈRE 4 (Modification BDD : +1)
    assert_difference("Product.count", 1) do
      post products_url(format: :json), params: {
        product: {
          name: "Nouveau Produit API",
          inventory_count: 50,
          image_description_attributes: { attachment: file }
        }
      }
    end

    # CRITÈRE 1 (Code HTTP)
    assert_response :created

    # CRITÈRE 2 (Format réponse)
    assert_equal "application/json; charset=utf-8", response.content_type

    # CRITÈRE 3 (Données)
    json_response = JSON.parse(response.body)
    assert_equal "Nouveau Produit API", json_response["name"]
  end

  # --- TEST 4 : MISE À JOUR (UPDATE) ---
  test "API should update product" do
    # CRITÈRE 4 (Modification BDD : Valeur changée)
    patch product_url(@product, format: :json), params: {
      product: { name: "Nom Modifié" }
    }
    
    # On vérifie la BDD
    @product.reload 
    assert_equal "Nom Modifié", @product.name

    # CRITÈRE 1 (Code HTTP)
    assert_response :ok

    # CRITÈRE 2 (Format réponse)
    assert_equal "application/json; charset=utf-8", response.content_type

    # CRITÈRE 3 (Données)
    json_response = JSON.parse(response.body)
    assert_equal "Nom Modifié", json_response["name"]
  end

  # --- TEST 5 : SUPPRESSION (DESTROY) ---
  test "API should destroy product" do
    # CRITÈRE 4 (Modification BDD : -1)
    assert_difference("Product.count", -1) do
      delete product_url(@product, format: :json)
    end

    # CRITÈRE 1 (Code HTTP)
    assert_response :no_content

    # CRITÈRE 2 & 3 (Format/Données)
    # Pour un 204 No Content, le corps DOIT être vide par définition standard
    assert_empty response.body
  end
end