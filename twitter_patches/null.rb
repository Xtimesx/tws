module Tws
  module TwitterPatches
    module Null
      def present?
        false
      end
 
      def nil?
        true
      end
    end
  end
end
