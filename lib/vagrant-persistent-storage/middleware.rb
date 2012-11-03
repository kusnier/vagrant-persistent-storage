Dir[File.dirname(__FILE__) + '/middleware/**/*.rb'].each do |file|
  require file
end
