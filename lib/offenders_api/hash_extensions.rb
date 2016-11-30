module HashExtensions
  def symbolize_keys(hash)
    hash.each_with_object({}) { |(k,v), result| result[k.to_sym] = v }
  end
end
