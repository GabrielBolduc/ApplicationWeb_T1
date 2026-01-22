class CreateImageDescriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :image_descriptions do |t|
      t.references :imageable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
