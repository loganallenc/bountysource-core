# == Schema Information
#
# Table name: currencies
#
#  id         :integer          not null, primary key
#  type       :string(255)      not null
#  value      :decimal(, )      not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_currencies_on_type   (type)
#  index_currencies_on_value  (value)
#

class Currency < ActiveRecord::Base

  attr_accessible :type, :value

  validates :type, presence: true
  validates :value, numericality: { presence: true, greather_than_or_equal_to: 0 }

  def self.sync_all
    [
      Currency::Bitcoin,
      Currency::Mastercoin,
      Currency::Ripple
    ].each(&:sync)
  end

  def self.index
    currencies = {}
    pluck(:type).map(&:constantize).each do |klass|
      currencies[klass.display_name] = klass.first.value
    end
    currencies
  end

  def self.btc_rate
    Currency::Bitcoin.first.value
  end

  def self.bch_rate
    Currency::BitcoinCash.first.value
  end

  def self.msc_rate
    Currency::Mastercoin.first.value
  end

  def self.xrp_rate
    Currency::Ripple.first.value
  end

  # TODO For the love of god and all that is holy, give this some class.
  def self.convert(amount, from, to)
    amount ||= 0
    amount = amount.to_f if amount.is_a?(String)
    from ||= 'USD'
    return amount if from == to
    case from
    when 'USD'
      case to
      when 'BTC' # USD to BTC
        amount / btc_rate
      when 'BCH' # USD to BCH
        amount / bch_rate
      when 'MSC' # USD to MSC
        amount / msc_rate
      when 'XRP' # USD to XRP
        amount / xrp_rate
      end

    when 'BTC'
      case to
      when 'USD' # BTC to USD
        amount * btc_rate
      when 'MSC' # BTC to MSC
        btc_to_usd(amount) * msc_rate
      when 'XRP' # BTC to XRP
        btc_to_usd(amount) * xrp_rate
      when 'BCH' # BTC to BCH
        btc_to_usd(amount) * bch_rate
      end

    when 'BCH'
      case to
      when 'USD' # BCH to USD
        amount * bch_rate
      when 'MSC' # BCH to MSC
        bch_to_usd(amount) * msc_rate
      when 'XRP' # BCH to XRP
        bch_to_usd(amount) * xrp_rate
      when 'BTC' # BCH to BCH
        bch_to_usd(amount) * btc_rate
      end

    when 'MSC'
      case to
      when 'USD' # MSC to USD
        amount * msc_rate
      when 'BTC' # MSC to BTC
        msc_to_usd(amount) * btc_rate
      when 'XRP' # MSC to XRP
        msc_to_usd(amount) * xrp_rate
      when 'BCH' # MSC to BCH
        msc_to_usd(amount) * bch_rate
      end

    when 'XRP'
      case to
      when 'USD' # XRP to USD
        amount * xrp_rate
      when 'BTC' # XRP to BTC
        xrp_to_usd(amount) * btc_rate
      when 'MSC' # XRP to MSC
        xrp_to_usd(amount) * msc_rate
      when 'BCH' # XRP to BCH
        xrp_to_usd(amount) * bch_rate
      end
    end
  end

  def self.btc_to_usd(amount)
    convert(amount, 'BTC', 'USD')
  end

  def self.bch_to_usd(amount)
    convert(amount, 'BCH', 'USD')
  end

  def self.msc_to_usd amount
    convert(amount, 'MSC', 'USD')
  end

  def self.xrp_to_usd amount
    convert(amount, 'XRP', 'USD')
  end

  def self.usd_to_btc amount
    convert(amount, 'USD', 'BTC')
  end

  def self.usd_to_bch amount
    convert(amount, 'USD', 'BCH')
  end

  # Convert currency to USD
  def self.to_usd currency, amount
    convert(amount, 'USD', currency)
  end

end
