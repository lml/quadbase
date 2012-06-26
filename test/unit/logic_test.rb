# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class LogicTest < ActiveSupport::TestCase

  test "basic" do
    assert_nothing_raised{FactoryGirl.create(:logic)}
  end

  test "reserved words not allowed" do
    assert_raise(ActiveRecord::RecordInvalid) {FactoryGirl.create(:logic, :variables => 'x, y, continue')}
  end
  
  test "start with letter or underscore" do
    assert_raise(ActiveRecord::RecordInvalid) {FactoryGirl.create(:logic, :variables => '9x')}
  end
   
  test "run" do
    Bullring.add_library("1", "(function() {Math.seedrandom = function(x){};})()")
    
    ll = FactoryGirl.create(:logic, :code => 'x = 3;', :variables => 'x')
    result = ll.run(:library_version_ids => ["1"])
    assert_equal 3, result.variables["x"]
  end


  test 'simple_random' do
    Bullring.add_library("1", "(function(j,i,g,m,k,n,o){function q(b){var e,f,a=this,c=b.length,d=0,h=a.i=a.j=a.m=0;a.S=[];a.c=[];for(c||(b=[c++]);d<g;)a.S[d]=d++;for(d=0;d<g;d++)e=a.S[d],h=h+e+b[d%c]&g-1,f=a.S[h],a.S[d]=f,a.S[h]=e;a.g=function(b){var c=a.S,d=a.i+1&g-1,e=c[d],f=a.j+e&g-1,h=c[f];c[d]=h;c[f]=e;for(var i=c[e+h&g-1];--b;)d=d+1&g-1,e=c[d],f=f+e&g-1,h=c[f],c[d]=h,c[f]=e,i=i*g+c[e+h&g-1];a.i=d;a.j=f;return i};a.g(g)}function p(b,e,f,a,c){f=[];c=typeof b;if(e&&c==\"object\")for(a in b)if(a.indexOf(\"S\")<5)try{f.push(p(b[a],e-1))}catch(d){}return f.length?f:b+(c!=\"string\"?\"\0\":\"\")}function l(b,e,f,a){b+=\"\";for(a=f=0;a<b.length;a++){var c=e,d=a&g-1,h=(f^=e[a&g-1]*19)+b.charCodeAt(a);c[d]=h&g-1}b=\"\";for(a in e)b+=String.fromCharCode(e[a]);return b}i.seedrandom=function(b,e){var f=[],a;b=l(p(e?[b,j]:arguments.length?b:[(new Date).getTime(),j,window],3),f);a=new q(f);l(a.S,j);i.random=function(){for(var c=a.g(m),d=o,b=0;c<k;)c=(c+b)*g,d*=g,b=a.g(1);for(;c>=n;)c/=2,d/=2,b>>>=1;return(c+b)/d};return b};o=i.pow(g,m);k=i.pow(2,k);n=k*2;l(i.random(),j)})([],Math,256,6,52);")
    
    ll = FactoryGirl.create(:logic, :code => 'x = Math.random();', :variables => 'x')
    result_s2_1 = ll.run(:seed => 2, :library_version_ids => ["1"])
    result_s2_2 = ll.run(:seed => 2, :library_version_ids => ["1"])
    result_s3_1 = ll.run(:seed => 3, :library_version_ids => ["1"])
    assert_equal result_s2_1.variables["x"], result_s2_2.variables["x"]
    assert_not_equal result_s3_1.variables["x"], result_s2_2.variables["x"]
  end

  test 'pass in old outputs' do
    Bullring.add_library("pioo", "(function() {Math.seedrandom = function(x){};})()")
    
    l1 = FactoryGirl.create(:logic, :code => 'x = 3;', :variables => 'x')
    
    result_l1 = l1.run({:library_version_ids => ["pioo"]})
    assert_equal 3, result_l1.variables["x"]
    
    l2 = FactoryGirl.create(:logic, :code => 'y = 2*x;', :variables => 'y')
  
    result_l2_1 = l2.run({:prior_output => result_l1, :library_version_ids => ["pioo"]})
    result_l2_2 = l2.run({:prior_output => result_l1, :library_version_ids => ["pioo"]})
    
    assert_equal 6, result_l2_1.variables["y"], "alpha"
    assert_equal 6, result_l2_2.variables["y"], "beta"
  end

end
