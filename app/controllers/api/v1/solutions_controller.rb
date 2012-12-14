module Api
  module V1
    class SolutionsController < ApiController      
      
      def index
        # debugger
        @question = Question.from_param(params[:question_id])
        raise SecurityTransgression unless current_user.can_read?(@question)
        @solutions = Vote.order_by_votes(@question.valid_solutions_visible_for(current_user))
      end

      def show
        @solution = Solution.find(params[:id])
        raise SecurityTransgression unless current_user.can_read?(@solution)
      end
      
    end
  end
end