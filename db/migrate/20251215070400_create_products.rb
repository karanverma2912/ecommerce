class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, default: 0.00, null: false
      t.string :sku
      t.integer :quantity_in_stock
      t.references :category, null: false, foreign_key: true
      t.boolean :is_active, default: true
      t.decimal :discount_percentage, default: 0

      t.timestamps
    end

    add_index :products, :sku, unique: true
    add_index :products, :name
  end
end
