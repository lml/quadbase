# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class WebsiteConfigurationTest < ActiveSupport::TestCase

  setup do
    @wc = FactoryGirl.create(:website_configuration)
  end

  test "can't mass-assign name and value_type" do
    name = "Some name"
    value_type = "boolean"
    wc  = WebsiteConfiguration.new(:name => name, :value_type => value_type)
    assert wc.name != name
    assert wc.value_type != value_type
  end

  test "duplicate names not allowed" do
    wc0 = FactoryGirl.build(:website_configuration, :name => @wc.name,
                                                :value => "Another value",
                                                :value_type => @wc.value_type)
    assert !wc0.save
    wc1 = FactoryGirl.build(:website_configuration, :name => "Another name",
                                                :value => "Another value",
                                                :value_type => @wc.value_type)
    wc1.save!
  end

  test "blank value_types not allowed" do
    wc = FactoryGirl.build(:website_configuration, :name => "Another name",
                                               :value => "Another value",
                                               :value_type => nil)
    assert !wc.save
  end

  test "get_value" do
    assert WebsiteConfiguration.get_value(@wc.name) == @wc.value

    FactoryGirl.create(:website_configuration, :name => "true0",
                                           :value => "Something",
                                           :value_type => "boolean")
    FactoryGirl.create(:website_configuration, :name => "true1",
                                           :value => "1",
                                           :value_type => "boolean")
    FactoryGirl.create(:website_configuration, :name => "true2",
                                           :value => "t",
                                           :value_type => "boolean")

    FactoryGirl.create(:website_configuration, :name => "false0",
                                           :value => nil,
                                           :value_type => "boolean")
    FactoryGirl.create(:website_configuration, :name => "false1",
                                           :value => "",
                                           :value_type => "boolean")
    FactoryGirl.create(:website_configuration, :name => "false2",
                                           :value => " ",
                                           :value_type => "boolean")
    FactoryGirl.create(:website_configuration, :name => "false3",
                                           :value => "0",
                                           :value_type => "boolean")
    FactoryGirl.create(:website_configuration, :name => "false4",
                                           :value => "f",
                                           :value_type => "boolean")

    assert WebsiteConfiguration.get_value("true0")
    assert WebsiteConfiguration.get_value("true1")
    assert WebsiteConfiguration.get_value("true2")

    assert !WebsiteConfiguration.get_value("false0")
    assert !WebsiteConfiguration.get_value("false1")
    assert !WebsiteConfiguration.get_value("false2")
    assert !WebsiteConfiguration.get_value("false3")
    assert !WebsiteConfiguration.get_value("false4")
  end

  test "defaults" do
    WebsiteConfiguration.defaults.each do |d|
      assert !WebsiteConfiguration.get_value(d[0]).nil?
    end
  end

end
