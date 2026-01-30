require "test_helper"

class ProductsApiTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @product = products(:ordinateur)

    unless @product.image_description
      desc = @product.build_image_description
      file_path = Rails.root.join('test', 'fixtures', 'files', 'icon.png')
      
      unless File.exist?(file_path)
        Dir.mkdir(File.dirname(file_path)) unless Dir.exist?(File.dirname(file_path))
        FileUtils.touch(file_path)
      end

      desc.attachment.attach(io: File.open(file_path), filename: 'icon.png', content_type: 'image/png')
      @product.save!
    end

    sign_in @user
  end

  # List
  test "List product" do
    assert_no_difference("Product.count") do
      get products_url(format: :json)
    end
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
  end

  # Show
  test "Show product" do
    assert_no_difference("Product.count") do
      get product_url(@product, format: :json)
    end
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Ordinateur", json_response["name"]
  end

  # Create
  test "Create product" do
    file = fixture_file_upload("icon.png", "image/png")
    
    assert_difference("Product.count", 1) do
      post products_url(format: :json), params: {
        product: { name: "Tablette", inventory_count: 10, image_description_attributes: { attachment: file } }
      }
    end
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "Tablette", json_response["name"]
  end

  # Create (Erreur)
  test "Not create product (erreur)" do
    file = fixture_file_upload("icon.png", "image/png")

    assert_no_difference("Product.count") do
      post products_url(format: :json), params: {
        product: { name: "", image_description_attributes: { attachment: file } }
      }
    end
    assert_response :unprocessable_entity
  end

  # Modification
  test "Not update product (erreur)" do
    # name vide
    patch product_url(@product, format: :json), params: {
      product: { name: "" }
    }
    assert_response :unprocessable_entity
    
    @product.reload
    assert_not_equal "", @product.name 
  end

  # Suppresion
  test "Destroy product" do
    assert_difference("Product.count", -1) do
      delete product_url(@product, format: :json)
    end
    assert_response :no_content
    assert_empty response.body
  end
end