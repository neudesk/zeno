class CreateDefaultPrompt < ActiveRecord::Migration
  def change
    create_table :default_prompt do |t|
      t.string :name

      t.timestamps
    end
  end
end
