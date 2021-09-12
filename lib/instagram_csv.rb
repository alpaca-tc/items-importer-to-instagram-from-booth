require 'csv'

class InstagramCsv
  # Convert BOOTH items json to Instagram(FaceBook) shop csv
  #
  # @param items [Array<Hash>]
  #
  # @return [String]
  def self.from_items(items)
    CSV.generate do |csv|
      csv << InstagramCsv::Row::HEADERS

      items.each do |item|
        item['variations'].each do |variation|
          row = InstagramCsv::Row.new(item, variation)
          csv << row.to_a if row.published?
        end
      end
    end
  end

  class Row
    HEADERS = [
      'id', # 必須 | アイテムごとのユニークコンテンツIDです。利用できる場合はSKU(最小管理単位)のIDをご利用ください。同じコンテンツIDはカタログ内で1回しか使えません。ダイナミック広告を掲載する場合は、Facebookピクセルコードでの同じアイテムのコンテンツIDと、このIDが正確に一致する必要があります。(上限: 100文字)
      'title', # 必須 | アイテムの具体的なタイトルです。タイトルの仕様についてはhttps://www.facebook.com/business/help/2104231189874655をご覧ください。(上限: 150文字)
      'description', # 必須 | A short and relevant description of the item. Include specific or unique product features like material or color. Use plain text and don't enter text in all capital letters. See description specifications: https://www.facebook.com/business/help/2302017289821154 Character limit: 9999
      'availability', # 必須 | The current availability of the item. | Supported values: in stock; out of stock | サポートされている値: in stock; available for order; preorder; out of stock; discontinued
      'condition', # 必須 | The condition of the item. Enter one of the following: new; refurbished; used | サポートされている値: new; refurbished; used
      'price', # 必須 | アイテムの価格です。価格の後に3文字の通貨コード(ISO 4217)を入力してください。小数点はコンマではなくドット(.)で入力してください。
      'link', # 必須 | アイテムを購入できる具体的な商品ページのURLです。
      'image_link', # 必須 | アイテムのメイン画像のURLです。画像はサポートされている形式(JPG/GIF/PNG)で500x500ピクセル以上でなければなりません。
      'brand', # 必須 | アイテムのブランド名です。一意の製造部品番号(MPN)または国際取引商品番号(GTIN)を代わりに入力することもできます。GTINにはUPC、EAN、JAN、ISBNのいずれかを指定できます。(上限: 100文字)
      'google_product_category', # 任意 | アイテムのGoogle商品カテゴリです。商品カテゴリについて詳しくはhttps://www.facebook.com/business/help/526764014610932をご覧ください。
      'fb_product_category', # 任意 | アイテムのFacebook商品カテゴリです。商品カテゴリについて詳しくはhttps://www.facebook.com/business/help/526764014610932をご覧ください。
      'quantity_to_sell_on_facebook', # 任意 | FacebookとInstagramでチェックアウト付き販売にするために必要なこのアイテムの数量です。1以上にしないとアイテムを購入できなくなります
      'sale_price', # 任意 | セール中のアイテムの割引価格です。3文字の通貨コード(ISO 4217)の後に価格を入力してください。小数点はドット(.)で入力してください。割引価格のオーバーレイを使用したい場合は、セール価格は必須です。
      'sale_price_effective_date', # 任意 | セール期間の日程です。開始・終了それぞれの日付、時間、時間帯が必要です。セール期間を入力しない場合、sale_priceが含まれるアイテムは、sale_priceを削除しない限りすべてセール中として扱われます。フォーマットは「 YYYY-MM-DDT23:59+00:00/YYYY-MM-DDT23:59+00:00」です。開始日時をYYYY-MM-DD(年-月-日)形式で入力し、アルファベットの「T」の後に24時間表示(00:00～23:59)で時間を入力し、UTCタイムゾーンを入力してください(-12:00から +14:00まで)。その後、スラッシュ「/」の後に同じ形式で終了日時を入力してください。以下に例示する行では、太平洋標準時(-08000)が使用されています。
      'item_group_id', # 任意 | Use this field to create variants of the same item. Enter the same group ID for all variants within a group. Learn more about variants: https://www.facebook.com/business/help/2256580051262113 Character limit: 100.
      'gender', # 任意 | アイテムが対象としている人の性別です。 | サポートされている値: female; male; unisex
      'color', # 任意 | アイテムの色です。16進数コードではなく、色を表す単語や言葉を入力してください。(上限: 200文字)
      'size', # 任意 | 文字、記号、番号などによるサイズ表記です。例:「スモール」、「XL」、「12号」。 (上限: 200文字)
      'age_group', # 任意 | このアイテムの対象となる年齢層です。 | サポートされている値: adult; all ages; infant; kids; newborn; teen; toddler
      'material', # 任意 | 綿、デニム、革など、このアイテムの素材です。(上限:200文字)
      'pattern', # 任意 | The pattern or graphic print on the item. Character limit: 100.
      'shipping', # 任意 | アイテムの配送の詳細です。コロン(:)区切りで、「国:地域:配送業者:配送料金」形式で入力します。配送料金は3文字のISO通貨コードに続けて入力してください。広告で無料配送のオーバーレイを利用するには、価格に4217.0と入力してください。複数の地域や国に対応する場合は、コンマ(;)区切りで入力してください。配送の詳細は、その地域や国の居住者のみに表示されます。指定した国全体で同じ配送オプションの場合は、地域を省略することもできます。その場合は国名の後にコロンを0文字続けて入力(::)してください。
      'shipping_weight', # 任意 | アイテムの発送重量です。測定単位(lb、oz、g、kg)を入力してください。
      'style[0]', # 任意 | このアイテムのファッションスタイルを説明してください。
    ].freeze

    def initialize(item, variation)
      @item = item
      @variation = variation
    end

    # @return [Boolean]
    def published?
      @item.fetch('state') == 'public'
    end

    # Generate array for CSV row
    #
    # @return [Array]
    def to_a
      h = to_h
      HEADERS.map { h[_1.to_sym] }
    end

    # Generate hash for CSV row
    def to_h
      {
        id: @variation.fetch('id'),
        title: @item.fetch('name'),
        description: @item.fetch('description'),
        availability: availability,
        condition: 'new',
        price: "#{@variation['price']} JPY",
        link: "https://yuhiro8717.booth.pm/items/#{@item.fetch('id')}",
        image_link: image_link,
        brand: @variation.fetch('id'),
        # google_product_category: '',
        # fb_product_category: '',
        # quantity_to_sell_on_facebook: '',
        # sale_price: '',
        # sale_price_effective_date: '',
        item_group_id: item_group_id,
        # gender: '',
        # color: '',
        # size: '',
        # age_group: '',
        # material: '',
        # pattern: '',
        # shipping: '',
        # shipping_weight: '',
        # style[0]: ''
      }
    end

    private

    def item_group_id
      if @item['variations'].size > 1
        @item.fetch('id')
      else
        nil
      end
    end

    def availability
      if @item.fetch('preorder_enabled')
        'preorder'
      elsif @variation['stock'] == 0
        'out of stock'
      elsif @variation['stock'] > 0
        'in stock'
      end
      # 'available for order'
      # 'discontinued'
    end

    def image_link
      @item['images'][0]['file']['c_512x683']['url']
    end
  end
end
