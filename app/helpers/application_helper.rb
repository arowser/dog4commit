module ApplicationHelper
  def btc_human amount, options = {}
    return nil unless amount
    nobr = options.has_key?(:nobr) ? options[:nobr] : true
    currency = options[:currency] || false
    btc = "%.8f DGC" % to_btc(amount)
    btc = "<span class='convert-from-btc' data-to='#{currency.upcase}'>#{btc}</span>" if currency
    btc = "<nobr>#{btc}</nobr>" if nobr
    btc.html_safe
  end

  def to_btc satoshies
    satoshies.to_d / DogecoinBalanceUpdater::COIN if satoshies
  end

  def transaction_url(txid)
    "http://http://block-explorer.com/tx/#{txid}"
  end
end
