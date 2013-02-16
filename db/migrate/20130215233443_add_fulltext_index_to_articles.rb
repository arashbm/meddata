class AddFulltextIndexToArticles < ActiveRecord::Migration
  def up
    execute "
      create index on articles using gin(to_tsvector('english', title));
      create index on articles using gin(to_tsvector('english', abstract));
      create index on articles using gin(to_tsvector('english', raw_pubmed_xml));"
  end

  def down
  end
end
