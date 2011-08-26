class AddPartialNameToLicenses < ActiveRecord::Migration
  def self.up
    add_column :licenses, :agreement_partial_name, :string
  end

  def self.down
    remove_column :licenses, :agreement_partial_name
  end
end
