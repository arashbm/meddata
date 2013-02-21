class Article < ActiveRecord::Base

  has_many :article_keywords
  has_many :keywords, :through => :article_keywords

  attr_accessible :abstract, :pubmed_id, :raw_pubmed_xml, :title
  

  def self.save_keyword_occurrence(term, ids=nil)
    kw = Keyword.find_or_create_by_title(term)
    articles = ids ? self.where(id: ids) : self.scoped
    articles.basic_search(term).each do |article|
      article.keywords << kw unless article.keywords.include? kw
    end
  end

  def extract_pubmed_title(node)
    node.css('PubmedArticle MedlineCitation Article ArticleTitle').first.try(:text)
  end

  def extract_pubmed_abstract(node)
    node.css('PubmedArticle MedlineCitation Article Abstract AbstractText').first.try(:text)
  end

  def extract_pubmed_data!
    extract_pubmed_data.save!
  end
  def extract_pubmed_data_from_node!(node)
    extract_pubmed_data_from_node(node).save!
  end
  def extract_pubmed_data
    doc = Nokogiri.XML(raw_pubmed_xml)
    extract_pubmed_data_from_node(doc)
  end

  def extract_pubmed_data_from_node(node)
    title = extract_pubmed_title(node)
    abstract = extract_pubmed_abstract(node)
  end
  # Extract *all* words and remove some insignificant ones.
  def extract_keywords!
    # TODO: maybe we should collect things based on their p-o-s tags.
    # TODO: add training for tokenizer or use another one which supports
    # learning to enhance specialized word detection.

    t = Treat::Entities::Section.build(Treat::Entities::Title.build(title),Treat::Entities::Paragraph.build(abstract))
    t.apply(:segment, :tokenize, :stem)
    t.each_entity do |ent|
      if ent.has_feature? :stem
        t = ent.stem.downcase
      elsif ent.type == :symbol
        t = ent.to_s.downcase
      else
        next
      end

      # check against stopwords to save some IO

      self.keywords << Keyword.find_or_create_by_title(t)
    end
  end

  def text
    title.to_s+"\n"+abstract.to_s
  end
end
