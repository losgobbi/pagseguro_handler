class CreatePurchaseItems < ActiveRecord::Migration[5.0]
  def change
    create_table :purchase_items do |t|
      t.integer    :sku_id
      t.string     :sku_description
      t.decimal    :sku_value
      t.belongs_to :purchase
      t.timestamps
    end
  end
end
