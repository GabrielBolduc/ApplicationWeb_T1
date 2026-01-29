require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:tshirt) 
    @user = users(:david)       
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get show" do
    get product_url(@product)
    assert_response :success
  end

  test "should get new only if signed in" do

    get new_product_url
    assert_response :redirect
    assert_redirected_to new_user_session_url

    sign_in @user
    get new_product_url
    assert_response :success
  end

  test "should create product" do
    sign_in @user
    assert_difference("Product.count") do
      post products_url, params: { 
        product: { 
          name: "Nouveau", 
          inventory_count: 10,
          image_description_attributes: {
            attachment: fixture_file_upload('icon.png', 'image/png')
          }
        } 
      }
    end

    assert_redirected_to product_url(Product.last)
  end
end