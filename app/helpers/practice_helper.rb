module PracticeHelper

  def next_params(ids, index, part)
    directional_params(ids, :next, index, part)
  end

  def prev_params(ids, index, part)
    directional_params(ids, :prev, index, part)
  end

  def directional_params(ids, direction, index, part)
    change = direction == :next ? 1 : -1

    params = {ids: ids}
    if part.nil?
      params[:on] = index + change
    else
      params[:on] = index
      params[:part] = part + change
    end

    params
  end

end
