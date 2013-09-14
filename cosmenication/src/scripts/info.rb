#!/usr/bin/ruby -rubygems

require "pit"
require "rakuten"
require "json"

class String
  NormalizeRules = {
    "MQ" => "MAQuillAGE",
  }

  def normalize
    if NormalizeRules.key? self then
      NormalizeRules[self]
    else
      self
    end
  end
end

class RakutenSearch
  def initialize
    @pit = Pit.get("rakuten", :require => {
      "developer_id" => "Rakuten developerId"
    })
    @rakuten = Rakuten::Client.new(@pit["developer_id"])
  end

  def product_search(keyword)
    p @rakuten
    product = @rakuten.product_search("2010-11-18", :keyword => keyword, :maxProductHits => 1)
    p @rakuten
    product["Items"]["Item"][0]
  end

  def product_detail(keyword)
    product = product_search(keyword)
    detail = @rakuten.product_detail("2010-11-18", :productId => product["productId"])
    detail["Item"][0]
  end

  def genre_search(genre_id)
    @rakuten.product_genre_info("2010-11-18", :genreId => genre_id)["GenreInformation"]
  end

  def genre_search_all(genre_id)
    genres = []
    while true
      genre = genre_search(genre_id)
      current = genre["current"][0]
      name = current["genreName"].normalize
      level = current["genreLevel"]

      genres.unshift(name)
      if level == 1 then
        break
      end
      genre_id = genre["parent"][0]["genreId"]
    end
    genres.reverse
  end

  STORES = [
    "oukastore", "jyugo", nil
  ]
  def get_caption(keyword, store)
    if store then
      items = @rakuten.item_search("2010-09-15", :keyword => keyword, :shopCode => store)["Items"]["Item"]
    else
      items = @rakuten.item_search("2010-09-15", :keyword => keyword)["Items"]["Item"]
    end
    if items.length > 0 then
      caption = items[0]["itemCaption"]
      if caption && caption.length > 0 then
        caption
      end
    end
  end

  def product_info(keyword)
    info = {}
    product = product_detail(keyword)

    info["name"] = product["productName"]
    info["image"] = product["mediumImageUrl"]
    info["url"] = product["productUrlPC"]

    brand = product["brandName"]
    name = product["productName"]
    info["name"] = name.sub!(/^#{brand} */, "")
    info["brand"] = brand.normalize

    caption = product["productCaption"]
    genre_id = product["genreId"]

    if caption.length == 0 then
      STORES.each do|store|
        begin
          caption = get_caption(keyword, store)
          info["caption"] = caption
          break
        rescue Rakuten::ApiError => error
          STDERR.puts error
        end
      end
    end

    info["genres"] = genre_search_all(genre_id)

    info
  end
end

rakuten = RakutenSearch.new

if ARGV.length == 0 then
  puts "example:\n  $ item_info.rb 4901872357932"
  exit
end

informations = []
ARGV.each do|arg|
  begin
    info = rakuten.product_info arg
    informations.push info
  rescue Rakuten::ApiError => error
  end
end

STDOUT.print informations.to_json
STDOUT.flush

# vim: set ts=2 sw=2 et fdm=syntax:
