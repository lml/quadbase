# Copyright 2011-2012 Rice University. Licensed under the Affero General Public 
# License version 3 or later.  See the COPYRIGHT file for details.

module PracticeWidgetsHelper
  def confidence_labels
    #["Definitely Wrong", "Probably Wrong", "Possibly Wrong", "Possibly Right", "Probably Right", "Definitely Right"]
    ["Definitely_Wrong", "Probably_Wrong", "Maybe Wrong,_Maybe Right", "Probably_Right", "Definitely_Right"]
  end
  
  def choice_letter(index)
    ("a".ord + index).chr
  end
end
