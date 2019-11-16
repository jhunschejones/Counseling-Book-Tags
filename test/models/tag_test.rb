require 'test_helper'

# bundle exec ruby -Itest /Users/jjones/Documents/GitHub/Counseling-Book-Tags/test/models/tag_test.rb
class TagTest < ActiveSupport::TestCase
  fixtures :books, :tags

  describe "title_case" do
    test "follows capitalization rules" do
      tag = Tag.new(text: "this  iS A malForMed Tag")
      tag.title_case
      assert_equal "This is a Malformed Tag", tag.text
    end
  end

  describe "uniques_from_list_of_books" do
    test "returns de-duped list of all associated tags" do
      all_associated_tags = books(:one).tags.map { |t| t.text } << books(:two).tags.map { |t| t.text }
      unique_tags = Tag.uniques_from_list_of_books([books(:one), books(:two)]).map { |t| t.text }.sort
      refute_equal all_associated_tags.flatten.sort, unique_tags
      assert_equal [tags(:one).text, tags(:two).text, tags(:four).text].sort, unique_tags
    end
  end
end
