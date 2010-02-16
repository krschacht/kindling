
class Gambit
  attr_accessor :campaign_key, :secret_key

  def self.[]( environment )
    @configs ||= {}
    @configs[environment] ||= Gambit.new
  end

  def self.respond_to?( m, *args )
    self[RAILS_ENV].respond_to?( m )
  end

  def self.method_missing( m, *args )
    self[RAILS_ENV].send( m )
  end

end

open "#{Rails.root}/config/gambit.yml" do |f|
  YAML.load( f ).each do |e,c|
    gambit = Gambit[e]
    gambit.campaign_key = c['campaign_key']
    gambit.secret_key   = c['secret_key']
  end
end

