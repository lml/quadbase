# Thanks to Brandon@stackoverflow
# http://stackoverflow.com/questions/4877931/how-to-return-an-empty-activerecord-relation

class ActiveRecord::Base
   def self.none
     where(arel_table[:id].eq(nil).and(arel_table[:id].not_eq(nil)))
   end
end
