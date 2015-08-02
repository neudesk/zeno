class AddAttachmentPromptToDefaultPrompts < ActiveRecord::Migration
  def change
    change_table :default_prompt do |t|
      t.attachment :prompt
    end
  end
end
