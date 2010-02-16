
class Sparechange
  attr_accessor :dev_id, :secret_key

  def self.[]( environment )
    @configs ||= {}
    @configs[environment] ||= Sparechange.new
  end

  def self.respond_to?( m, *args )
    self[RAILS_ENV].respond_to?( m )
  end

  def self.method_missing( m, *args )
    self[RAILS_ENV].send( m )
  end

end

open "#{Rails.root}/config/sparechange.yml" do |f|
  YAML.load( f ).each do |e,c|
    sparechange            = Sparechange[e]
    sparechange.dev_id     = c['dev_id']
    sparechange.secret_key = c['secret_key']
  end
end

