module Tws
  module TwitterPatches
    module Base
    
      def dataset
        raise NotImplementedError
      end 

      def save
        data = base_save 
        dataset.insert data
      end
 
      def collect_data
        data = {}
        fields.each do |field|
          data[field] = self.to_hash[field]
        end
        return data
      end

      def fields
        []
      end
   
      def find(id)
        dataset.where(id_field => id).first
      end

      def id_field
        :id
      end

      def present?
        true
      end
    end
  end
end
