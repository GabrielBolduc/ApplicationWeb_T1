class ProductsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_user_product, only: %i[edit update destroy]
  before_action :set_product, only: %i[show]

  def index
    @products = Product.all
  end

  def show
  end

  def new
    @product = current_user.products.build
    @product.build_image_description
  end

  def create
    @product = current_user.products.build(product_params)

    if @product.save
      redirect_to @product
    else
      @product.build_image_description unless @product.image_description
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @product.build_image_description unless @product.image_description
  end

  def update
    if @product.update(product_params)
      redirect_to @product
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "Produit supprimé."
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def set_user_product
      @product = current_user.products.find_by(id: params[:id])
      redirect_to products_path, alert: "Non autorisé" if @product.nil?
    end

    def product_params
      # On modifie les paramètres pour accepter la structure imbriquée
      params.expect(product: [ :name, :description, image_description_attributes: [:id, :attachment] ])
    end
end