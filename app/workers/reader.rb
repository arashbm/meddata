class ArticleReaderWorker
  include Sidekiq::Worker

  # This will find an xml file that is not locked, imported or known
  # to has errors based on name given
  def find_free_xml(name)
    # checking
    name
  end

  def mark_dataset(dataset, mark='marked')
    Sidekiq.redis do |redis|
      redis.sadd "datasets:#{mark}", dataset.to_s
    end
  end
  def unmark_dataset(dataset, mark='marked')
    Sidekiq.redis do |redis|
      redis.srem "datasets:#{mark}", dataset.to_s
    end
  end
  def dataset_marked?(dataset, mark='marked')
    Sidekiq.redis do |redis|
      return redis.sismember "datasets:#{mark}", dataset.to_s
    end
  end

  # this will do the given block within a lock to keep xml files safe
  def with_locked_xml(filename)
    puts "locking #{filename}"
    if dataset_marked?(filename, 'locked') 
      raise "already marked as locked"
    end
    # actual locking
    mark_dataset(filename, 'locked')
    begin
      yield
    ensure
      puts "unlocking #{filename}"
      # actual unlocking
      unmark_dataset(filename, 'locked')
    end
  end

  # it will find a file, read it, validate it and import it to database as raw
  # article data. Then mark the file as imported.
  def perform(name)
    filename = find_free_xml(name)
    articles_to_import = []
    unless filename
      puts 'no files left'
      return
    end
    with_locked_xml filename do
      puts "Opening file at #{filename}"
      file = File.open filename
      puts "creating a nokogiri document..."
      doc = Nokogiri.XML(file)
      if doc.errors.length > 0
        puts "error reading file #{filename}, marking 'errors'"
        mark_dataset(filename, 'errors')
        # mark the file as incomplete
        raise 'bad file'
      end
      doc.css('PubmedArticle').each do |article|
        pmid = article.css('MedlineCitation PMID').first.text.to_i
        if pmid
          a = Article.find_or_initialize_by_pubmed_id(pmid)
          a.raw_pubmed_xml = article.to_s
          a.extract_pubmed_data_from_node(article)
          if a.persisted?
            a.save! if a.changed?
          else
            articles_to_import << a
          end
        else
          puts 'Ignoring article without ID... What the hell?'
        end
      end

      # we are pretty confident about validity of data
      Article.import articles_to_import, :validate => false if articles_to_import.size > 0

      # mark the file as imported
      unmark_dataset(filename, 'errors')
      mark_dataset(filename, 'imported')
    end
  end
end
