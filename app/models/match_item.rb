class MatchItem < ActiveRecord::Base
  include ContentParseAndCache
  include AssetMethods
  
  belongs_to :question
  belongs_to :match, :class_name => 'MatchItem'

  attr_accessible :content, :match, :right_column
  validates_presence_of :question
  validate :matching_question
  
  validate :parse_succeeds
  before_save :cache_html
  
  validate :question_not_published
  before_destroy :question_not_published
  
  validate :question_not_changed, :on => :update
  
  attr_writer :variated_content_html
  
  def variated_content_html
    @variated_content_html || self.content_html
  end

  def content_copy(copy_match = true)
    kopy = Matching.new(:content => content, :right_column => right_column)
    return kopy if !copy_match || match.nil?
    kopy.match = match.content_copy(false)
    kopy.match.match = kopy
    kopy
  end
  
  def variate!(variator)
    @variated_content_html = variator.fill_in_variables(content_html)
  end
  
  def get_attachable
    question
  end

  protected

  def question_not_published
    return if !question.try(:is_published?)
    errors.add(:base, "Cannot modify a published question's matchings.")
    false
  end
  
  def question_not_changed
    return if !question_id_changed?
    errors.add(:base, "Cannot move a match item to another question.")
    false
  end
  
  def matching_question
    return if question.question_type == "MatchingQuestion"
    errors.add(:base, "Only matching questions can have match items.")
    false
  end
end
