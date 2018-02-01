module Keisan
  class Util
    def self.underscore(str)
      str.to_s.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').downcase
    end

    def self.array_split(array, &block)
      array.inject([[]]) do |results, element|
        if yield(element)
          results << []
        else
          results.last << element
        end

        results
      end
    end
  end
end
