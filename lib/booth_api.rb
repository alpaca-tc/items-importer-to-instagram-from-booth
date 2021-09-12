require 'faraday'
require 'json'

class BoothApi
  # Fetch all shallow items json
  #
  # @return [Array] items array
  def fetch_all_items(**options)
    pages = collect_all_pages('/items.json', **options)
    bodies = pages.map { JSON.parse(_1.body)['items'] }
    bodies.inject([], &:+)
  end

  # Fetch all detail items json
  #
  # @return [Array] items array
  def fetch_all_item_details(**options)
    items = fetch_all_items(**options)
    item_ids = items.map { _1['id'] }
    pages = item_ids.map { client.get("/items/#{_1}.json") }
    pages.map { JSON.parse(_1.body) }
  end

  private

  def collect_all_pages(path, params = {}, **options)
    init_page = params[:page] || 1
    first_page = client.get(path, params.merge(page: init_page), **options)
    first_body = JSON.parse(first_page.body)
    total_pages = first_body['metadata']['total_pages']

    if total_pages > 1
      raise NotImplementedError, 'Use expeditor to fetch all pages'
    else
      [first_page]
    end
  end

  def client
    @client ||= Faraday.new(client_options) do |conn|
      conn.adapter Faraday.default_adapter
    end
  end

  def client_options
    {
      headers: {
        cookie: ENV.fetch('COOKIE')
      },
      url: 'https://manage.booth.pm'
    }
  end
end
