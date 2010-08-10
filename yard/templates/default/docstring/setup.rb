def init
  super
end

def private
  return unless object.has_tag?(:api) && ['private', 'plugin'].include?(object.tag(:api).text)
  erb(object.tag(:api).text.intern)
end
