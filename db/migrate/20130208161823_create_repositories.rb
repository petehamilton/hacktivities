class CreateRepositories < ActiveRecord::Migration
  def up
    create_table :repositories do |t|
      t.integer :hackathon_id
      t.string :original_url
    end
  end

  def down
    drop_table :repositories
  end
end
