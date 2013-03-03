class ArticleExtractorWorker
  include Sidekiq::Worker

  def self.queue_list(list_file)
    list = File.readlines(list_file).map(&:chomp).uniq

    list.each_slice(20) do |s|
      self.perform_async s.to_a 
    end
  end

  def perform(list, ids = nil)
    list.each do |term|
      keyword = Keyword.find_or_create_by_title(term)
      keyword.save_keyword_occurrence!(ids)
    end
  end

end
