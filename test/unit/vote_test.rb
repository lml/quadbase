# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

require 'test_helper'

class VoteTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test "can't mass-assign votable and user" do
    user = Factory.create(:user)
    votable = Factory.create(:solution)
    v = Vote.new(:user => user, :votable => votable)
    assert v.user != user
    assert v.votable != votable
  end

  test "only one vote per user per votable" do
    v0 = Factory.create(:vote)
    v1 = Factory.build(:vote, :user => v0.user, :votable => v0.votable)
    assert !v1.save
  end

  test "order_by_votes" do
    q = Factory.create(:simple_question)

    s0 = Factory.create(:solution, :question => q)
    s1 = Factory.create(:solution, :question => q)
    s2 = Factory.create(:solution, :question => q)
    s3 = Factory.create(:solution, :question => q)
    s4 = Factory.create(:solution, :question => q)

    v0 = Factory.create(:vote, :votable => s0, :thumbs_up => false)
    v1 = Factory.create(:vote, :votable => s1, :thumbs_up => true)
    v2 = Factory.create(:vote, :votable => s2, :thumbs_up => true)
    v3 = Factory.create(:vote, :votable => s3, :thumbs_up => true)
    v4 = Factory.create(:vote, :votable => s4, :thumbs_up => true)
    v5 = Factory.create(:vote, :votable => s0, :thumbs_up => false)
    v6 = Factory.create(:vote, :votable => s1, :thumbs_up => false)
    v7 = Factory.create(:vote, :votable => s2, :thumbs_up => true)

    sa0 = q.solutions
    sa1 = Vote.order_by_votes(sa0)

    assert sa0[0] == s0
    assert sa0[1] == s1
    assert sa0[2] == s2
    assert sa0[3] == s3
    assert sa0[4] == s4

    assert sa1[0] == s2
    assert sa1[1] == s3
    assert sa1[2] == s4
    assert sa1[3] == s1
    assert sa1[4] == s0
  end

end
