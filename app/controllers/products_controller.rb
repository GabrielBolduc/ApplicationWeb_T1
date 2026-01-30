# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_user_product, only: %i[edit update destroy]
  before_action :set_product, only: %i[show]

  def index
    @products = Product.all

    # Optimisation Cache HTTP (Brakeman aime l'optimisation)
    return unless stale?(etag: @products, last_modified: @products.maximum(:updated_at))

    respond_to do |format|
      format.html
      format.json { render json: @products }
    end
  end

  def show
    return unless stale?(@product)

    respond_to do |format|
      format.html
      format.json { render json: @product }
    end
  end

  def new
    @product = current_user.products.build
    @product.build_image_description
  end

  def create
    @product = current_user.products.build(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Créé avec succès." }
        format.json { render json: @product, status: :created }
      else
        @product.build_image_description unless @product.image_description
        format.html { render :new, status: :unprocessable_entity }
        # test negatif
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @product.build_image_description unless @product.image_description
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Mis à jour." }
        format.json { render json: @product, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        # test nagatif
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_path, notice: "Supprimé." }
      format.json { head :no_content }
    end
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
    params.require(:product).permit(:name, :description, :inventory_count, image_description_attributes: %i[id attachment])
  end
end
