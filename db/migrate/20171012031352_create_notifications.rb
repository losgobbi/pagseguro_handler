class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.string  :transaction_code
      t.string  :transaction_date
      t.string  :transaction_sender_email
      t.integer :transaction_status
      t.string  :transaction_cancellation_source
      t.string  :transaction_last_event_date
      t.string  :transaction_payment_type
      t.string  :transaction_amount
      t.string  :transaction_escrow_date
      t.string  :transaction_feeAmount
      t.integer :transaction_reference
      t.timestamps
    end
  end
end