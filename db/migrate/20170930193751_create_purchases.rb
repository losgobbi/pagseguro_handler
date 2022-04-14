class CreatePurchases < ActiveRecord::Migration[5.0]
  def change
    create_table :purchases do |t|
      t.string  :store_id
      t.string  :buyer_email
      t.string  :buyer_name
      t.string  :payment_errors
      t.string  :checkout_code
      t.timestamps
    end
  end
end
