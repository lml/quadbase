module PracticeHelper

  def next_params(ids, index, part, embed)
    directional_params(ids, :next, index, part, embed)
  end

  def prev_params(ids, index, part, embed)
    directional_params(ids, :prev, index, part, embed)
  end

  def directional_params(ids, direction, index, part, embed)
    change = direction == :next ? 1 : -1

    params = {ids: ids, embed: embed ? 'true' : 'false'}
    if part.nil?
      params[:on] = index + change
    else
      params[:on] = index
      params[:part] = part + change
    end

    params
  end

  def choice_letter(index)
    ("a".ord + index).chr
  end

end
