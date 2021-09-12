require 'booth_api'
require 'instagram_csv'

booth_api = BoothApi.new
items = booth_api.fetch_all_item_details

csv = InstagramCsv.from_items(items)
puts csv
