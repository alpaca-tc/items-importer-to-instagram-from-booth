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
  # @param state [Array<String>] Filter items by state. Supported values are 'public', 'draft' and 'private'.
  #
  # @return [Array] items array
  def fetch_all_item_details(state: ['public'], **options)
    items = fetch_all_items(**options)
    item_ids = items.select { state.include?(_1['state']) }.map { _1['id'] }
    urls = item_ids.map { "/items/#{_1}.json" }
    pages = concurrent_get(urls)
    pages.map { JSON.parse(_1.body) }
  end

  private

  def concurrent_get(urls)
    h = {}

    threads = urls.map do |url|
      Thread.new do
        h[url] = client.get(url)
      end
    end

    threads.each(&:join)

    urls.map { h.fetch(_1) }
  end

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
