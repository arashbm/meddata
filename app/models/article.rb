class Article < ActiveRecord::Base

  has_many :article_keywords
  has_many :keywords, :through => :article_keywords

  attr_accessible :abstract, :pubmed_id, :raw_pubmed_xml, :title
  
  def extract_pubmed_title
    doc = Nokogiri.XML(raw_pubmed_xml)
    doc.css('PubmedArticle MedlineCitation Article ArticleTitle').first.try(:text)
  end

  def extract_pubmed_abstract
    doc = Nokogiri.XML(raw_pubmed_xml)
    doc.css('PubmedArticle MedlineCitation Article Abstract AbstractText').first.try(:text)
  end

  def extract_pubmed_data!
    update_attributes title: extract_pubmed_title, abstract: extract_pubmed_abstract
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

  def text
    title.to_s+"\n"+abstract.to_s
  end

  # Uses a list for keywords
  def extract_keywords_from_list(index_list)
    index_list.each do |kw|
      # TODO use a better way for search rather than scan.
      if (text.scan(kw).size > 0)
        key = Keyword.find_or_create_by_title(kw)
        self.keywords << key
      end
    end
  end
end
