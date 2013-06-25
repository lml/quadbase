

class ChangeCollaboratorsInBulk

  def initialize(remove_old_collaborators = false)
    @new_collaborators = []
    @remove_old_collaborators = remove_old_collaborators
  end

  def add_collaborator(user, is_author, is_copyright_holder)
    @new_collaborators.push({user: user, is_author: is_author, is_copyright_holder: is_copyright_holder})
  end

  def run_on_list(list)
    Question.joins{list_questions}.where{list_questions.list_id == my{list}.id}.find_each do |question|
      run_on_question(question)
    end
  end

  def run_on_question(question)

    Question.transaction do 
      if @remove_old_collaborators
        question.question_collaborators.each do |qc|
          qc.is_author = false
          qc.is_copyright_holder = false
          qc.changes_ok_for_published_questions = true
          qc.save
          qc.destroy
        end
      end

      @new_collaborators.each do |new_collaborator|
        new_qc = QuestionCollaborator.new(:user => new_collaborator[:user], :question => question)
        new_qc.is_author = new_collaborator[:is_author]
        new_qc.is_copyright_holder = new_collaborator[:is_copyright_holder]
        new_qc.changes_ok_for_published_questions = true
        new_qc.save
      end
    end

  end





end