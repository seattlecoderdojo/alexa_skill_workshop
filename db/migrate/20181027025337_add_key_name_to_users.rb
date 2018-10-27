class AddKeyNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :key_name, :string
  end
end
