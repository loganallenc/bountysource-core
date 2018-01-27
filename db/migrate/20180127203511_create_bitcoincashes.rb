class CreateBitcoincashes < ActiveRecord::Migration
  def change
    create_table :bitcoincashes do |t|

      t.timestamps
    end
  end
end
