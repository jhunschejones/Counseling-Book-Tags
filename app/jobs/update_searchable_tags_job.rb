class UpdateSearchableTagsJob < ApplicationJob
  queue_as :default

  def perform(book)
    book.searchable_tags = book.tags.map { |tag| tag.text }.uniq
    book.save!
  end
end
