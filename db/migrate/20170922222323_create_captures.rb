class CreateCaptures < ActiveRecord::Migration[5.1]
  def change
    create_table :captures do |t|

      t.timestamps
    end
  end
end
