module Api
  module V1
    class SolutionsController < ApiController      
      
      def index
        @question = Question.from_param(params[:question_id])
        raise SecurityTransgression unless @api_user.can_read?(@question)
        @solutions = Vote.order_by_votes(@question.valid_solutions_visible_for(@api_user))
      end

      def show
        @solution = Solution.find(params[:id])
        raise SecurityTransgression unless @api_user.can_read?(@solution)
      end
      
    end
  end
end