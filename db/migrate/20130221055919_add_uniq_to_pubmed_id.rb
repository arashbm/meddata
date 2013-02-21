class AddUniqToPubmedId < ActiveRecord::Migration
  def change
    add_index :articles, :pubmed_id, :unique => true
  end
end
