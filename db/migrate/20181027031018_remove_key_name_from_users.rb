class RemoveKeyNameFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :key_name, :string
  end
end
