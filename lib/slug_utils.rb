# frozen_string_literal: true

require_relative "slug_utils/version"

module SlugUtils
  class Error < StandardError; end
  class InvalidText < Error; end

  # Your code goes here...
  def self.generate(text)
    raise InvalidText, "Text cannot be blank" if text.nil? || text.strip.empty?

    text.unicode_normalize(:nfkd)
        .encode("ASCII", replace: "")
        .downcase
        .gsub(/[^a-z0-9]+/, "-")
        .gsub(/^-|-$/, "")
  end
end
