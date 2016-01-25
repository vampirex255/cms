class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |table|
      table.belongs_to :site, null: false

      table.string :url, null: false, limit: 64
      table.string :name, null: false, limit: 64
      table.boolean :private, default: false, null: false
      table.boolean :contact_form, default: false, null: false
      table.text :html_content

      table.timestamps null: false

      table.index [:site_id, :url], unique: true
    end
  end
end