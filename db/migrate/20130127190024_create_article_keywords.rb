class CreateArticleKeywords < ActiveRecord::Migration
  def change
    create_table :article_keywords do |t|
      t.references :article
      t.references :keyword

      t.timestamps
    end
    add_index :article_keywords, :article_id
    add_index :article_keywords, :keyword_id
  end
end
